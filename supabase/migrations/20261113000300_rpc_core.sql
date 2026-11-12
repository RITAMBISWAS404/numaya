-- Transactional endpoints (PostgREST RPC: POST /rest/v1/rpc/<name>). The actor is always
-- auth.uid(); no function accepts an actor id. Errors are raised with SQLSTATE P0001 and a stable
-- code as the message (docs/backend/API_CONTRACT.md lists them).
-- Dev-fixture values are marked "FIXTURE"; owner-approved values come from AllowancePolicy.

-- ---------------------------------------------------------------------------------------------
-- Internal helpers
create or replace function private.fail(code text)
returns void language plpgsql set search_path = '' as $$
begin
  raise exception '%', code using errcode = 'P0001';
end $$;

create or replace function private.require_user()
returns uuid language plpgsql stable set search_path = '' as $$
declare uid uuid := auth.uid();
begin
  if uid is null then perform private.fail('not_authenticated'); end if;
  return uid;
end $$;

-- An active member (onboarded, not paused by moderation, not deleted).
create or replace function private.require_active()
returns uuid language plpgsql stable security definer set search_path = '' as $$
declare uid uuid := private.require_user(); st public.account_status;
begin
  select status into st from private.accounts where user_id = uid;
  if st is null then perform private.fail('account_missing'); end if;
  if st = 'onboarding' then perform private.fail('onboarding_incomplete'); end if;
  if st in ('suspended', 'underage') then perform private.fail('account_restricted'); end if;
  if st = 'deleted' then perform private.fail('account_deleted'); end if;
  return uid;
end $$;

create or replace function private.pair_lock(a uuid, b uuid)
returns void language sql set search_path = '' as $$
  select pg_advisory_xact_lock(hashtextextended(least(a, b)::text || greatest(a, b)::text, 0))
$$;

create or replace function private.rate_check(uid uuid, action text, max_count int, win interval)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if (select count(*) from private.rate_events r
      where r.user_id = uid and r.action = rate_check.action and r.at > now() - win) >= max_count then
    perform private.fail('rate_limited');
  end if;
  insert into private.rate_events (user_id, action) values (uid, rate_check.action);
end $$;

create or replace function private.balance(uid uuid, b public.credit_bucket)
returns int language sql stable security definer set search_path = '' as $$
  select coalesce(sum(delta), 0)::int from private.credit_ledger where user_id = uid and bucket = b
$$;

-- Premium weekly allowance: 3 a week, no rollover (granted lazily, idempotent per IST week).
create or replace function private.refresh_weekly(uid uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare wk date := private.ist_week_start(); bal int;
begin
  perform pg_advisory_xact_lock(hashtextextended('credits:' || uid::text, 0));
  bal := private.balance(uid, 'weekly');
  if bal > 0 and not exists (select 1 from private.credit_ledger
      where user_id = uid and source_key = 'weekly:' || wk) then
    insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
    values (uid, 'weekly', -bal, 'expiry', 'weekly-expiry:' || wk)
    on conflict (user_id, source_key) do nothing;
  end if;
  if private.is_premium(uid) then
    insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
    values (uid, 'weekly', 3, 'weekly', 'weekly:' || wk)
    on conflict (user_id, source_key) do nothing;
  end if;
end $$;

-- Spends one credit (weekly, then earned, then purchased). Returns the bucket, or null.
create or replace function private.spend_credit(uid uuid, source text)
returns public.credit_bucket language plpgsql security definer set search_path = '' as $$
declare b public.credit_bucket;
begin
  perform pg_advisory_xact_lock(hashtextextended('credits:' || uid::text, 0));
  foreach b in array array['weekly', 'earned', 'purchased']::public.credit_bucket[] loop
    if private.balance(uid, b) > 0 then
      insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
      values (uid, b, -1, 'spend', source);
      return b;
    end if;
  end loop;
  return null;
end $$;

-- Earned bucket grant with the cap of 5: an award at the cap is skipped and audited.
create or replace function private.grant_earned(uid uuid, amount int, why text, source text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare room int;
begin
  perform pg_advisory_xact_lock(hashtextextended('credits:' || uid::text, 0));
  if exists (select 1 from private.credit_ledger where user_id = uid and source_key = source) then
    return false;
  end if;
  room := greatest(0, 5 - private.balance(uid, 'earned'));
  if room = 0 then
    insert into private.audit_log (actor, action, subject, detail)
    values (null, 'credit_award_skipped_at_cap', uid, jsonb_build_object('source', source));
    return false;
  end if;
  insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
  values (uid, 'earned', least(amount, room), why, source);
  return true;
end $$;

-- Streak: a day qualifies with 3 distinct decisions or one message in a reciprocal conversation;
-- 7 consecutive qualifying days award 1 earned credit, once per (run start, cycle).
create or replace function private.record_activity(uid uuid, source text)
returns void language plpgsql security definer set search_path = '' as $$
declare d date := private.ist_day(); was boolean; qualifies boolean; run int := 0; probe date;
begin
  insert into private.daily_usage (user_id, day) values (uid, d) on conflict do nothing;
  -- Lock first, then count: the recount runs in a fresh snapshot that includes every concurrent
  -- decision committed before this lock was granted (READ COMMITTED).
  select qualified into was from private.daily_usage where user_id = uid and day = d for update;
  if was then return; end if;
  qualifies := source = 'message' or private.decisions_today(uid) >= 3;
  if not qualifies then return; end if;
  update private.daily_usage set qualified = true where user_id = uid and day = d;
  probe := d;
  while exists (select 1 from private.daily_usage where user_id = uid and day = probe and qualified) loop
    run := run + 1;
    probe := probe - 1;
  end loop;
  if run % 7 = 0 then
    perform private.grant_earned(uid, 1, 'streak',
      'streak:' || (d - run + 1)::text || ':' || (run / 7)::text);
  end if;
end $$;

create or replace function private.decisions_today(uid uuid)
returns int language sql stable security definer set search_path = '' as $$
  select count(*)::int from public.decisions
  where actor_id = uid and private.ist_day(created_at) = private.ist_day()
$$;

-- Mutual eligibility, checked by the feed AND again on every action (likes, Compliments):
-- gender openness both ways, age range both ways, and the viewer's distance limit.
create or replace function private.compatible(viewer uuid, target uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.profiles me
    join public.preferences mp on mp.user_id = me.user_id
    join private.accounts ma on ma.user_id = me.user_id
    join public.profiles p on p.user_id = target
    join public.preferences cp on cp.user_id = target
    join private.accounts a on a.user_id = target
    left join private.locations ml on ml.user_id = viewer
    left join private.locations l on l.user_id = target
    where me.user_id = viewer
      and (cardinality(me.open_to) = 0 or p.gender = any (me.open_to))
      and (cardinality(p.open_to) = 0 or me.gender = any (p.open_to))
      and private.age_years(a.birth_date) between mp.age_min and mp.age_max
      and private.age_years(ma.birth_date) between cp.age_min and cp.age_max
      and (ml.point is null or l.point is null
           or extensions.st_dwithin(ml.point, l.point, mp.max_distance_km * 1000.0))
  )
$$;

-- Public card for discovery and likes (no DOB, no coordinates, no private fields).
create or replace function private.profile_card(viewer uuid, uid uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'user_id', p.user_id,
    'first_name', p.first_name,
    'gender', p.gender,
    'age', private.age_years(a.birth_date),
    'verified', p.verified,
    'pronouns', case when p.show_pronouns then to_jsonb(p.pronouns) else '[]'::jsonb end,
    'interests', to_jsonb(p.interests),
    'looking_for', to_jsonb(p.looking_for),
    'bio', p.bio,
    'height_cm', p.height_cm,
    'city_label', p.city_label,
    'distance_bucket', (
      select case
        when d < 5000 then 'under_5_km' when d < 10000 then 'under_10_km'
        when d < 25000 then 'under_25_km' when d < 50000 then 'under_50_km'
        else 'over_50_km' end
      from (select extensions.st_distance(l1.point, l2.point) as d
            from private.locations l1, private.locations l2
            where l1.user_id = viewer and l2.user_id = uid) x),
    'prompts', coalesce((select jsonb_agg(jsonb_build_object('id', pr.id, 'question', pr.question,
        'answer', pr.answer) order by pr.position) from public.prompts pr where pr.user_id = uid), '[]'),
    'photos', coalesce((select jsonb_agg(jsonb_build_object('id', ph.id, 'path', ph.object_path,
        'position', ph.position) order by ph.position)
        from public.photos ph where ph.user_id = uid and ph.status = 'approved'), '[]')
  )
  from public.profiles p join private.accounts a on a.user_id = p.user_id
  where p.user_id = uid
$$;

-- ---------------------------------------------------------------------------------------------
-- Onboarding
create or replace function public.complete_onboarding(
  p_birth_date date, p_terms_version text, p_privacy_version text, p_community_version text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); acc private.accounts; p public.profiles; photo_count int;
begin
  select * into acc from private.accounts where user_id = uid for update;
  if acc.status in ('deleted', 'suspended') then perform private.fail('account_restricted'); end if;
  if acc.status = 'underage' then perform private.fail('underage'); end if;
  if acc.birth_date is not null and acc.birth_date <> p_birth_date then
    perform private.fail('birth_date_locked'); -- changes go through support
  end if;
  if p_birth_date is null or p_birth_date > private.ist_day() then perform private.fail('birth_date_invalid'); end if;
  if private.age_years(p_birth_date) < 18 then
    update private.accounts set status = 'underage', birth_date = p_birth_date where user_id = uid;
    insert into private.audit_log (actor, action, subject) values (uid, 'underage_signup_blocked', uid);
    return jsonb_build_object('result', 'underage');
  end if;
  if private.age_years(p_birth_date) > 100 then perform private.fail('birth_date_invalid'); end if;
  if coalesce(p_terms_version, '') = '' or coalesce(p_privacy_version, '') = ''
     or coalesce(p_community_version, '') = '' then
    perform private.fail('consent_required');
  end if;
  select * into p from public.profiles where user_id = uid;
  select count(*) into photo_count from public.photos
    where user_id = uid and status in ('pending', 'approved');
  if char_length(trim(p.first_name)) = 0 then perform private.fail('name_required'); end if;
  if p.gender is null then perform private.fail('gender_required'); end if;
  if char_length(trim(p.bio)) = 0 then perform private.fail('bio_required'); end if;
  if not exists (select 1 from public.prompts where user_id = uid) then perform private.fail('prompt_required'); end if;
  if photo_count < 2 then perform private.fail('photos_required'); end if;

  insert into public.consents (user_id, document, version) values
    (uid, 'terms', p_terms_version), (uid, 'privacy', p_privacy_version), (uid, 'community', p_community_version)
    on conflict do nothing;
  update private.accounts set birth_date = p_birth_date, status = 'active',
    onboarded_at = coalesce(onboarded_at, now()) where user_id = uid;
  update public.profiles set onboarding_complete = true where user_id = uid;
  perform private.grant_earned(uid, 3, 'welcome', 'welcome');
  return jsonb_build_object('result', 'active');
end $$;

create or replace function public.set_location(p_lat double precision, p_lng double precision, p_city text)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  if p_lat not between -90 and 90 or p_lng not between -180 and 180 then perform private.fail('location_invalid'); end if;
  perform private.rate_check(uid, 'location', 20, interval '1 hour');
  insert into private.locations (user_id, point, updated_at)
  values (uid, extensions.st_setsrid(extensions.st_makepoint(round(p_lng::numeric, 1)::float8,
          round(p_lat::numeric, 1)::float8), 4326)::extensions.geography, now())
  on conflict (user_id) do update set point = excluded.point, updated_at = now();
  update public.profiles set city_label = nullif(trim(p_city), '') where user_id = uid;
end $$;

-- ---------------------------------------------------------------------------------------------
-- Photos: the client uploads to its own folder in the private `photos` bucket, then registers the
-- object here. Six active photos at most, enforced under a per-member lock.
create or replace function public.register_photo(p_object_path text, p_position int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); obj record; active int; new_id uuid;
begin
  if split_part(p_object_path, '/', 1) <> uid::text then perform private.fail('forbidden'); end if;
  if p_position not between 1 and 6 then perform private.fail('position_invalid'); end if;
  perform pg_advisory_xact_lock(hashtextextended('photos:' || uid::text, 0));
  select o.metadata into obj from storage.objects o
    where o.bucket_id = 'photos' and o.name = p_object_path;
  if not found then perform private.fail('object_missing'); end if;
  if coalesce(obj.metadata ->> 'mimetype', '') not in ('image/jpeg', 'image/png', 'image/webp') then
    perform private.fail('type_not_allowed');
  end if;
  if coalesce((obj.metadata ->> 'size')::int, 0) not between 1 and 10485760 then
    perform private.fail('size_not_allowed');
  end if;
  select count(*) into active from public.photos where user_id = uid and status in ('pending', 'approved');
  if active >= 6 then perform private.fail('photo_limit'); end if;
  if exists (select 1 from public.photos where object_path = p_object_path) then
    perform private.fail('already_registered');
  end if;
  insert into public.photos (user_id, object_path, position, bytes)
  values (uid, p_object_path, p_position, (obj.metadata ->> 'size')::int)
  returning id into new_id;
  insert into private.outbox (kind, recipient, payload, dedupe_key)
  values ('photo_review', null, jsonb_build_object('photo_id', new_id), 'photo_review:' || new_id);
  return jsonb_build_object('photo_id', new_id, 'status', 'pending');
exception when exclusion_violation then
  perform private.fail('position_taken');
end $$;

create or replace function public.remove_photo(p_photo uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  update public.photos set status = 'removed' where id = p_photo and user_id = uid
    and status in ('pending', 'approved');
  if not found then perform private.fail('not_found'); end if;
end $$;

create or replace function public.reorder_photos(p_photo_ids uuid[])
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  perform pg_advisory_xact_lock(hashtextextended('photos:' || uid::text, 0));
  if (select count(*) from public.photos where user_id = uid and status in ('pending', 'approved'))
     <> cardinality(p_photo_ids)
     or exists (select 1 from unnest(p_photo_ids) i where not exists (
       select 1 from public.photos ph where ph.id = i and ph.user_id = uid and ph.status in ('pending', 'approved'))) then
    perform private.fail('photo_set_mismatch');
  end if;
  set constraints public.photos_active_position deferred;
  update public.photos ph set position = x.pos
  from unnest(p_photo_ids) with ordinality as x(id, pos) where ph.id = x.id;
end $$;

-- ---------------------------------------------------------------------------------------------
-- Discovery
create or replace function public.discovery_feed(p_limit int default 10)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active();
begin
  perform private.rate_check(uid, 'feed', 120, interval '1 hour'); -- FIXTURE
  return coalesce((
    select jsonb_agg(private.profile_card(uid, c.user_id) order by c.ord)
    from (
      select p.user_id, md5(p.user_id::text || uid::text || private.ist_day()::text) as ord
      from public.profiles p
      where p.user_id <> uid
        and private.is_discoverable(p.user_id)
        and not private.is_blocked(uid, p.user_id)
        and not exists (select 1 from public.decisions d where d.actor_id = uid and d.target_id = p.user_id)
        and not exists (select 1 from public.conversations cv
                        where cv.user_a = least(uid, p.user_id) and cv.user_b = greatest(uid, p.user_id))
        and private.compatible(uid, p.user_id)
      order by 2
      limit least(greatest(p_limit, 1), 20)
    ) c), '[]'::jsonb);
end $$;

-- ---------------------------------------------------------------------------------------------
-- Decisions: like or pass, idempotent per key, quota-checked, atomic reciprocal match.
create or replace function public.decide(p_target uuid, p_kind text, p_key text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); prior public.decisions; kind public.decision_kind;
  d date := private.ist_day(); used int; lim int; conv public.conversations; result text := 'recorded';
  cid uuid; comp public.compliments;
begin
  if p_kind not in ('like', 'pass') then perform private.fail('kind_invalid'); end if;
  kind := p_kind::public.decision_kind;
  select * into prior from public.decisions where actor_id = uid and idempotency_key = p_key;
  if found then
    if prior.target_id = p_target and prior.kind = kind then
      return jsonb_build_object('result', prior.result, 'conversation_id', prior.conversation_id, 'replayed', true);
    end if;
    perform private.fail('idempotency_conflict');
  end if;
  if p_target = uid then perform private.fail('self_action'); end if;
  perform private.rate_check(uid, 'decide', 120, interval '1 minute'); -- FIXTURE
  perform private.pair_lock(uid, p_target);
  if exists (select 1 from public.decisions where actor_id = uid and target_id = p_target) then
    perform private.fail('already_decided');
  end if;
  if private.is_blocked(uid, p_target) or not private.is_discoverable(p_target)
     or not private.compatible(uid, p_target) then
    perform private.fail('unavailable');
  end if;

  if kind = 'like' then
    insert into private.daily_usage (user_id, day) values (uid, d) on conflict do nothing;
    select likes into used from private.daily_usage where user_id = uid and day = d for update;
    lim := case when private.is_premium(uid) then 15 else 5 end;
    if used >= lim then perform private.fail('quota_exhausted'); end if;
    update private.daily_usage set likes = likes + 1 where user_id = uid and day = d;

    select * into conv from public.conversations
      where user_a = least(uid, p_target) and user_b = greatest(uid, p_target);
    if found then
      if conv.status = 'compliment_pending' then
        -- Their pending Compliment to me becomes message one of an open match (MVP-D07).
        select * into comp from public.compliments where conversation_id = conv.id;
        if comp.recipient_id = uid then
          update public.conversations set status = 'open', matched_at = now() where id = conv.id;
          update public.compliments set status = 'accepted', decided_at = now() where id = comp.id;
          result := 'matched'; cid := conv.id;
        end if;
      elsif conv.status in ('blocked', 'unmatched', 'closed') then
        perform private.fail('unavailable');
      end if;
    elsif exists (select 1 from public.decisions
                  where actor_id = p_target and target_id = uid and kind = 'like') then
      insert into public.conversations (user_a, user_b, status, origin, matched_at, match_deadline)
      values (least(uid, p_target), greatest(uid, p_target), 'open', 'like', now(), now() + interval '24 hours')
      returning id into cid;
      result := 'matched';
    end if;
    if result = 'matched' then
      insert into private.outbox (kind, recipient, payload, dedupe_key) values
        ('match', p_target, jsonb_build_object('conversation_id', cid), 'match:' || cid || ':' || p_target),
        ('match', uid, jsonb_build_object('conversation_id', cid), 'match:' || cid || ':' || uid);
    end if;
  end if;

  insert into public.decisions (actor_id, target_id, kind, idempotency_key, result, conversation_id)
  values (uid, p_target, kind, p_key, result, cid);
  perform private.record_activity(uid, 'decision');
  return jsonb_build_object('result', result, 'conversation_id', cid,
    'likes_left', case when kind = 'like' then lim - used - 1 end);
end $$;

-- ---------------------------------------------------------------------------------------------
-- Compliments: one per pair; credit debit, request and message in one transaction.
create or replace function public.send_compliment(
  p_target uuid, p_target_kind text, p_target_ref uuid, p_body text, p_key text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); hash text; prior public.compliments; conv public.conversations;
  ctx jsonb; cid uuid; comp_id uuid := gen_random_uuid(); bucket public.credit_bucket; mutual boolean;
begin
  if p_target_kind not in ('photo', 'prompt') then perform private.fail('target_invalid'); end if;
  if p_body is null or char_length(trim(p_body)) not between 1 and 150 then perform private.fail('body_invalid'); end if;
  hash := md5(p_target::text || p_target_kind || p_target_ref::text || p_body);
  select * into prior from public.compliments where sender_id = uid and idempotency_key = p_key;
  if found then
    if prior.payload_hash = hash then
      return jsonb_build_object('result', 'sent', 'conversation_id', prior.conversation_id, 'replayed', true);
    end if;
    perform private.fail('idempotency_conflict');
  end if;
  if p_target = uid then perform private.fail('self_action'); end if;
  perform private.rate_check(uid, 'compliment', 20, interval '1 hour'); -- FIXTURE
  perform private.pair_lock(uid, p_target);
  if private.is_blocked(uid, p_target) or not private.is_discoverable(p_target)
     or not private.compatible(uid, p_target) then
    perform private.fail('unavailable');
  end if;
  select * into conv from public.conversations
    where user_a = least(uid, p_target) and user_b = greatest(uid, p_target);
  if found then
    if conv.status = 'open' then perform private.fail('already_matched'); end if;
    if exists (select 1 from public.compliments where conversation_id = conv.id and recipient_id = uid
               and status = 'pending') then perform private.fail('reply_instead'); end if;
    perform private.fail(case when conv.status in ('compliment_pending', 'dismissed')
                              then 'already_sent' else 'unavailable' end);
  end if;
  if exists (select 1 from public.decisions where actor_id = uid and target_id = p_target) then
    perform private.fail('already_decided');
  end if;
  -- Validate the target before any debit.
  if p_target_kind = 'photo' then
    select jsonb_build_object('kind', 'photo', 'photo_id', id, 'object_path', object_path) into ctx
      from public.photos where id = p_target_ref and user_id = p_target and status = 'approved';
  else
    select jsonb_build_object('kind', 'prompt', 'prompt_id', id, 'question', question, 'answer', answer) into ctx
      from public.prompts where id = p_target_ref and user_id = p_target;
  end if;
  if ctx is null then perform private.fail('target_unavailable'); end if;

  perform private.refresh_weekly(uid);
  bucket := private.spend_credit(uid, 'compliment:' || comp_id);
  if bucket is null then perform private.fail('no_credits'); end if;

  mutual := exists (select 1 from public.decisions where actor_id = p_target and target_id = uid and kind = 'like');
  insert into public.conversations (user_a, user_b, status, origin, matched_at, first_message_at, last_message_at, next_seq)
  values (least(uid, p_target), greatest(uid, p_target),
          case when mutual then 'open' else 'compliment_pending' end::public.conversation_status,
          'compliment', case when mutual then now() end, now(), now(), 2)
  returning id into cid;
  insert into public.compliments (id, conversation_id, sender_id, recipient_id, target_kind, target_ref,
    body, status, idempotency_key, payload_hash, decided_at)
  values (comp_id, cid, uid, p_target, p_target_kind::public.compliment_target, p_target_ref, trim(p_body),
    case when mutual then 'accepted' else 'pending' end::public.compliment_status, p_key, hash,
    case when mutual then now() end);
  insert into public.messages (conversation_id, seq, sender_id, client_message_id, kind, body, context)
  values (cid, 1, uid, comp_id, 'compliment', trim(p_body), ctx);
  insert into public.decisions (actor_id, target_id, kind, idempotency_key, result, conversation_id)
  values (uid, p_target, 'compliment', 'c:' || p_key, case when mutual then 'matched' else 'sent' end, cid);
  insert into private.outbox (kind, recipient, payload, dedupe_key)
  values ('compliment', p_target, jsonb_build_object('conversation_id', cid), 'compliment:' || comp_id);
  perform private.record_activity(uid, 'decision');
  return jsonb_build_object('result', case when mutual then 'matched' else 'sent' end,
    'conversation_id', cid, 'spent_from', bucket);
end $$;

create or replace function public.reply_compliment(p_conversation uuid, p_client_message_id uuid, p_body text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); conv public.conversations; comp public.compliments; s bigint;
begin
  if p_body is null or char_length(trim(p_body)) not between 1 and 1000 then perform private.fail('body_invalid'); end if;
  select * into conv from public.conversations where id = p_conversation for update;
  if not found or uid not in (conv.user_a, conv.user_b) then perform private.fail('not_found'); end if;
  if exists (select 1 from public.messages where sender_id = uid and client_message_id = p_client_message_id) then
    return jsonb_build_object('result', 'replied', 'conversation_id', conv.id, 'replayed', true);
  end if;
  select * into comp from public.compliments where conversation_id = conv.id;
  if comp.recipient_id <> uid then perform private.fail('forbidden'); end if;
  if conv.status <> 'compliment_pending' or comp.status <> 'pending' then perform private.fail('not_pending'); end if;
  if private.is_blocked(conv.user_a, conv.user_b) then perform private.fail('unavailable'); end if;
  s := conv.next_seq;
  insert into public.messages (conversation_id, seq, sender_id, client_message_id, kind, body)
  values (conv.id, s, uid, p_client_message_id, 'text', trim(p_body));
  update public.conversations set status = 'open', matched_at = now(), next_seq = s + 1,
    last_message_at = now() where id = conv.id;
  update public.compliments set status = 'accepted', decided_at = now() where id = comp.id;
  insert into private.outbox (kind, recipient, payload, dedupe_key)
  values ('message', comp.sender_id, jsonb_build_object('conversation_id', conv.id, 'seq', s),
          'message:' || conv.id || ':' || s);
  perform private.record_activity(uid, 'message');
  return jsonb_build_object('result', 'replied', 'conversation_id', conv.id, 'seq', s);
end $$;

create or replace function public.dismiss_compliment(p_conversation uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); comp public.compliments;
begin
  select * into comp from public.compliments where conversation_id = p_conversation for update;
  if not found or comp.recipient_id <> uid then perform private.fail('not_found'); end if;
  if comp.status <> 'pending' then perform private.fail('not_pending'); end if;
  update public.compliments set status = 'dismissed', decided_at = now() where id = comp.id;
  update public.conversations set status = 'dismissed' where id = p_conversation;
  return jsonb_build_object('result', 'dismissed'); -- no refund (owner rule); the sender is not told
end $$;

-- ---------------------------------------------------------------------------------------------
-- Messages: durable insert first; ordered by a locked per-conversation sequence; idempotent per
-- (sender, client message id).
create or replace function public.send_message(p_conversation uuid, p_client_message_id uuid, p_body text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); conv public.conversations; existing public.messages;
  other uuid; s bigint;
begin
  select * into existing from public.messages where sender_id = uid and client_message_id = p_client_message_id;
  if found then
    if existing.conversation_id <> p_conversation then perform private.fail('idempotency_conflict'); end if;
    return jsonb_build_object('result', 'sent', 'message_id', existing.id, 'seq', existing.seq,
      'created_at', existing.created_at, 'replayed', true);
  end if;
  if p_body is null or char_length(trim(p_body)) not between 1 and 1000 then perform private.fail('body_invalid'); end if;
  select * into conv from public.conversations where id = p_conversation for update;
  if not found or uid not in (conv.user_a, conv.user_b) then perform private.fail('not_found'); end if;
  other := case when conv.user_a = uid then conv.user_b else conv.user_a end;
  if conv.status = 'compliment_pending' then perform private.fail('awaiting_reply'); end if;
  if conv.status <> 'open' or private.is_blocked(uid, other) then perform private.fail('unavailable'); end if;
  if conv.first_message_at is null and conv.match_deadline < now() then perform private.fail('match_expired'); end if;
  perform private.rate_check(uid, 'message', 30, interval '1 minute'); -- FIXTURE
  s := conv.next_seq;
  insert into public.messages (conversation_id, seq, sender_id, client_message_id, kind, body)
  values (conv.id, s, uid, p_client_message_id, 'text', trim(p_body))
  returning * into existing;
  -- A new message also revives an archived conversation (archive is derived, never deletion).
  update public.conversations set next_seq = s + 1, last_message_at = now(),
    first_message_at = coalesce(first_message_at, now()) where id = conv.id;
  insert into private.outbox (kind, recipient, payload, dedupe_key)
  values ('message', other, jsonb_build_object('conversation_id', conv.id, 'seq', s),
          'message:' || conv.id || ':' || s);
  perform private.record_activity(uid, 'message');
  return jsonb_build_object('result', 'sent', 'message_id', existing.id, 'seq', s, 'created_at', existing.created_at);
end $$;

create or replace function public.mark_read(p_conversation uuid, p_seq bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active();
begin
  if not private.can_see_conversation(p_conversation) then perform private.fail('not_found'); end if;
  insert into public.conversation_reads (conversation_id, user_id, last_read_seq)
  values (p_conversation, uid, greatest(p_seq, 0))
  on conflict (conversation_id, user_id) do update
    set last_read_seq = greatest(public.conversation_reads.last_read_seq, excluded.last_read_seq);
end $$;

-- One extension per match (+24 h to the current deadline); free: one per IST week; Premium: one
-- per IST day (MVP-D10).
create or replace function public.extend_match(p_conversation uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); conv public.conversations; since timestamptz;
begin
  select * into conv from public.conversations where id = p_conversation for update;
  if not found or uid not in (conv.user_a, conv.user_b) or conv.status <> 'open' then perform private.fail('not_found'); end if;
  if conv.first_message_at is not null then perform private.fail('already_started'); end if;
  if conv.match_deadline < now() then perform private.fail('match_expired'); end if;
  if conv.extended then perform private.fail('already_extended'); end if;
  since := case when private.is_premium(uid)
                then (private.ist_day()::timestamp at time zone 'Asia/Kolkata')
                else (private.ist_week_start()::timestamp at time zone 'Asia/Kolkata') end;
  if exists (select 1 from private.extensions_used where user_id = uid and used_at >= since) then
    perform private.fail('extension_allowance_used');
  end if;
  insert into private.extensions_used (user_id, conversation_id) values (uid, conv.id);
  update public.conversations set extended = true, match_deadline = match_deadline + interval '24 hours'
    where id = conv.id;
  return jsonb_build_object('result', 'extended', 'deadline', conv.match_deadline + interval '24 hours');
end $$;

-- Messages list rows: one per pair, with the derived state the UI shows.
create or replace function public.list_conversations()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active();
begin
  return coalesce((
    select jsonb_agg(row_to_json(x) order by x.sort_at desc)
    from (
      select c.id as conversation_id,
        o.user_id as other_id,
        o.first_name as other_name,
        o.verified as other_verified,
        (select ph.object_path from public.photos ph where ph.user_id = o.user_id and ph.status = 'approved'
          order by ph.position limit 1) as other_photo_path,
        case
          when c.status = 'compliment_pending' and cm.recipient_id = uid then 'pending_incoming'
          when c.status in ('compliment_pending', 'dismissed') then 'pending_outgoing'
          when c.first_message_at is null and c.match_deadline <= now() then 'expired'
          when c.first_message_at is null then 'new_match'
          when c.last_message_at < now() - interval '7 days' then 'archived'
          else 'active' end as state,
        c.match_deadline as deadline,
        c.extended,
        (select jsonb_build_object('seq', m.seq, 'mine', m.sender_id = uid, 'kind', m.kind,
           'preview', left(m.body, 80), 'at', m.created_at)
         from public.messages m where m.conversation_id = c.id order by m.seq desc limit 1) as last_message,
        (select count(*) from public.messages m where m.conversation_id = c.id and m.sender_id <> uid
           and m.seq > coalesce((select r.last_read_seq from public.conversation_reads r
                                 where r.conversation_id = c.id and r.user_id = uid), 0)) as unread,
        case when cm.id is null then null else jsonb_build_object('id', cm.id, 'target_kind', cm.target_kind,
          'from_me', cm.sender_id = uid,
          'status', case when cm.sender_id = uid and cm.status = 'dismissed' then 'pending' else cm.status::text end)
        end as compliment,
        coalesce(c.last_message_at, c.matched_at, c.created_at) as sort_at
      from public.conversations c
      join public.profiles o on o.user_id = case when c.user_a = uid then c.user_b else c.user_a end
      left join public.compliments cm on cm.conversation_id = c.id
      where uid in (c.user_a, c.user_b) and private.can_see_conversation(c.id)
    ) x), '[]'::jsonb);
end $$;


-- One member's public card: only a counterpart, or someone discoverable to the caller, never
-- across a block. Same safe projection as the feed (no DOB, no coordinates).
create or replace function public.member_card(p_user uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active();
begin
  if p_user = uid then return private.profile_card(uid, uid); end if;
  if private.is_blocked(uid, p_user)
     or not (private.is_counterpart(p_user)
             or (private.is_discoverable(p_user) and private.compatible(uid, p_user))) then
    perform private.fail('not_found');
  end if;
  return private.profile_card(uid, p_user);
end $$;

-- ---------------------------------------------------------------------------------------------
-- Likes and wallet
create or replace function public.likes_summary()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); people uuid[]; premium boolean := private.is_premium(uid);
begin
  select coalesce(array_agg(d.actor_id order by d.created_at desc), '{}') into people
  from public.decisions d
  where d.target_id = uid and d.kind = 'like'
    and not exists (select 1 from public.decisions m where m.actor_id = uid and m.target_id = d.actor_id)
    and not exists (select 1 from public.conversations c
                    where c.user_a = least(uid, d.actor_id) and c.user_b = greatest(uid, d.actor_id))
    and not private.is_blocked(uid, d.actor_id)
    and private.is_discoverable(d.actor_id);
  return jsonb_build_object('count', cardinality(people), 'premium', premium,
    -- Who liked you is a Premium feature: free members get the count only, never identities.
    'people', case when premium then coalesce((select jsonb_agg(private.profile_card(uid, p)) from unnest(people) p), '[]')
                   else null end);
end $$;

create or replace function public.my_wallet()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); run int := 0; probe date := private.ist_day(); today boolean;
begin
  perform private.refresh_weekly(uid);
  select coalesce(qualified, false) into today from private.daily_usage where user_id = uid and day = probe;
  if not coalesce(today, false) then probe := probe - 1; end if;
  while exists (select 1 from private.daily_usage where user_id = uid and day = probe and qualified) loop
    run := run + 1; probe := probe - 1;
  end loop;
  return jsonb_build_object(
    'weekly', private.balance(uid, 'weekly'), 'earned', private.balance(uid, 'earned'),
    'purchased', private.balance(uid, 'purchased'),
    'total', private.balance(uid, 'weekly') + private.balance(uid, 'earned') + private.balance(uid, 'purchased'),
    'premium', private.is_premium(uid),
    'likes_left_today', (case when private.is_premium(uid) then 15 else 5 end) - coalesce(
      (select likes from private.daily_usage where user_id = uid and day = private.ist_day()), 0),
    'streak', jsonb_build_object('run', run, 'today_qualified', coalesce(today, false),
      'decisions_today', private.decisions_today(uid), 'cycle_progress', case when run = 0 then 0 else ((run - 1) % 7) + 1 end));
end $$;

-- ---------------------------------------------------------------------------------------------
-- Safety: always free.
create or replace function public.unmatch(p_conversation uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  update public.conversations set status = 'unmatched'
    where id = p_conversation and uid in (user_a, user_b) and status in ('open', 'compliment_pending', 'dismissed');
  if not found then perform private.fail('not_found'); end if;
  update public.compliments set status = 'closed' where conversation_id = p_conversation and status = 'pending';
end $$;

create or replace function public.block_member(p_other uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  if p_other = uid then perform private.fail('self_action'); end if;
  perform private.pair_lock(uid, p_other);
  insert into public.blocks (blocker_id, blocked_id) values (uid, p_other) on conflict do nothing;
  update public.conversations set status = 'blocked'
    where user_a = least(uid, p_other) and user_b = greatest(uid, p_other);
  update public.compliments set status = 'blocked'
    where status = 'pending' and ((sender_id = uid and recipient_id = p_other) or (sender_id = p_other and recipient_id = uid));
end $$;

create or replace function public.unblock_member(p_other uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  delete from public.blocks where blocker_id = uid and blocked_id = p_other;
  -- The conversation stays blocked: unblocking never reopens a chat.
end $$;

create or replace function public.report_member(
  p_subject uuid, p_category text, p_note text, p_conversation uuid default null, p_message uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); ev jsonb := '{}'; rid uuid;
begin
  perform private.rate_check(uid, 'report', 20, interval '1 day'); -- FIXTURE
  if p_subject = uid then perform private.fail('self_action'); end if;
  if p_conversation is not null then
    if not exists (select 1 from public.conversations where id = p_conversation and uid in (user_a, user_b)
                   and p_subject in (user_a, user_b)) then
      perform private.fail('not_found');
    end if;
    -- Evidence: the reported message, or the subject's last 20 messages in this conversation.
    ev := jsonb_build_object('messages', coalesce((select jsonb_agg(jsonb_build_object('seq', m.seq,
        'sender', m.sender_id, 'kind', m.kind, 'body', m.body, 'at', m.created_at) order by m.seq)
      from (select * from public.messages m where m.conversation_id = p_conversation
              and ((p_message is not null and m.id = p_message)
                   or (p_message is null and m.sender_id = p_subject))
            order by m.seq desc limit 20) m), '[]'));
  end if;
  insert into public.reports (reporter_id, subject_id, conversation_id, message_id, category, note, evidence)
  values (uid, p_subject, p_conversation, p_message, p_category, nullif(trim(p_note), ''), ev)
  returning id into rid;
  insert into private.outbox (kind, payload, dedupe_key)
  values ('report_triage', jsonb_build_object('report_id', rid), 'report:' || rid);
  return jsonb_build_object('result', 'reported', 'report_id', rid);
end $$;

create or replace function public.register_device(p_platform text, p_token text)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  insert into public.devices (user_id, platform, push_token)
  values (uid, p_platform, p_token)
  on conflict (push_token) do update set user_id = uid, platform = excluded.platform, revoked = false,
    last_seen = now();
end $$;

-- ---------------------------------------------------------------------------------------------
-- Privacy
create or replace function public.request_export()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); out jsonb;
begin
  perform private.rate_check(uid, 'export', 5, interval '1 day');
  insert into public.privacy_requests (user_id, kind, status, completed_at) values (uid, 'export', 'completed', now());
  select jsonb_build_object(
    'account', (select jsonb_build_object('status', status, 'birth_date', birth_date, 'created_at', created_at)
                from private.accounts where user_id = uid),
    'profile', (select to_jsonb(p) from public.profiles p where p.user_id = uid),
    'preferences', (select to_jsonb(p) from public.preferences p where p.user_id = uid),
    'prompts', (select coalesce(jsonb_agg(to_jsonb(p)), '[]') from public.prompts p where p.user_id = uid),
    'photos', (select coalesce(jsonb_agg(jsonb_build_object('id', id, 'position', position, 'status', status,
               'created_at', created_at)), '[]') from public.photos where user_id = uid),
    'consents', (select coalesce(jsonb_agg(to_jsonb(c)), '[]') from public.consents c where c.user_id = uid),
    'decisions_made', (select count(*) from public.decisions where actor_id = uid),
    -- Only messages this member wrote: other members' words are their data.
    'messages_sent', (select coalesce(jsonb_agg(jsonb_build_object('conversation_id', conversation_id,
               'seq', seq, 'kind', kind, 'body', body, 'at', created_at) order by created_at), '[]')
               from public.messages where sender_id = uid),
    'credit_ledger', (select coalesce(jsonb_agg(jsonb_build_object('bucket', bucket, 'delta', delta,
               'reason', reason, 'at', created_at) order by id), '[]') from private.credit_ledger where user_id = uid),
    'blocks', (select count(*) from public.blocks where blocker_id = uid),
    'exported_at', now()) into out;
  return out;
end $$;

-- Hides the account at once. It can be restored for 28 days (approved B-75/F27); after that, or
-- at once with purge_account(), the worker (tools/backend/scripts/privacy_worker.mjs, secret
-- key) deletes storage objects and the auth user (which revokes every session).
create or replace function public.request_account_deletion()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); rid uuid;
begin
  update private.accounts set status = 'deleted', deleted_at = now() where user_id = uid;
  update public.profiles set paused = true where user_id = uid;
  update public.conversations set status = 'closed' where uid in (user_a, user_b) and status <> 'blocked';
  update public.compliments set status = 'closed' where (sender_id = uid or recipient_id = uid) and status = 'pending';
  update public.devices set revoked = true where user_id = uid;
  insert into private.deletion_tombstones (user_id) values (uid)
    on conflict (user_id) do update set requested_at = now(), purge_after = now() + interval '28 days',
      completed_at = null;
  insert into public.privacy_requests (user_id, kind) values (uid, 'delete') returning id into rid;
  insert into private.audit_log (actor, action, subject) values (uid, 'account_deletion_requested', uid);
  return jsonb_build_object('result', 'deletion_scheduled', 'request_id', rid);
end $$;


create or replace function public.account_state()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); acc private.accounts; t private.deletion_tombstones;
begin
  select * into acc from private.accounts where user_id = uid;
  select * into t from private.deletion_tombstones where user_id = uid and completed_at is null;
  -- The member's own birth date (their data; never returned for anyone else).
  return jsonb_build_object('status', acc.status, 'has_profile', acc.onboarded_at is not null,
    'birth_date', acc.birth_date,
    'restorable_until', case when acc.status = 'deleted' and t.purge_after > now() then t.purge_after end);
end $$;

-- Restores a deleted account inside the window. Closed conversations stay closed.
create or replace function public.restore_account()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); t private.deletion_tombstones;
begin
  select * into t from private.deletion_tombstones where user_id = uid and completed_at is null for update;
  if not found or t.purge_after <= now() then perform private.fail('not_restorable'); end if;
  update private.accounts set status = case when onboarded_at is null then 'onboarding' else 'active' end::public.account_status,
    deleted_at = null where user_id = uid and status = 'deleted';
  update public.profiles set paused = false where user_id = uid;
  delete from private.deletion_tombstones where user_id = uid;
  update public.privacy_requests set status = 'failed', completed_at = now()
    where user_id = uid and kind = 'delete' and status = 'pending';
  insert into private.audit_log (actor, action, subject) values (uid, 'account_restored', uid);
  return jsonb_build_object('result', 'restored');
end $$;

-- "Delete for good": the worker purges at its next run.
create or replace function public.purge_account()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  update private.deletion_tombstones set purge_after = now() where user_id = uid and completed_at is null;
  if not found then perform private.fail('not_found'); end if;
  return jsonb_build_object('result', 'purge_scheduled');
end $$;

-- ---------------------------------------------------------------------------------------------
-- Staff (moderator role provisioned out of band; every action audited; no chat browsing)
create or replace function public.staff_photo_queue(p_limit int default 20)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  insert into private.audit_log (actor, action) values (auth.uid(), 'staff_photo_queue_viewed');
  return coalesce((select jsonb_agg(jsonb_build_object('photo_id', id, 'user_id', user_id,
      'object_path', object_path, 'created_at', created_at) order by created_at)
    from (select * from public.photos where status = 'pending' order by created_at limit least(p_limit, 50)) q), '[]');
end $$;

create or replace function public.staff_decide_photo(p_photo uuid, p_approve boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  update public.photos set status = case when p_approve then 'approved' else 'rejected' end::public.photo_status,
    reject_reason = case when p_approve then null else p_reason end, decided_at = now()
  where id = p_photo and status = 'pending';
  if not found then perform private.fail('not_found'); end if;
  insert into private.audit_log (actor, action, subject, detail)
  values (auth.uid(), case when p_approve then 'photo_approved' else 'photo_rejected' end, p_photo,
          jsonb_build_object('reason', p_reason));
end $$;

create or replace function public.staff_report_queue(p_limit int default 20)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  insert into private.audit_log (actor, action) values (auth.uid(), 'staff_report_queue_viewed');
  return coalesce((select jsonb_agg(jsonb_build_object('report_id', id, 'subject_id', subject_id,
      'category', category, 'note', note, 'evidence', evidence, 'created_at', created_at) order by created_at)
    from (select * from public.reports where status = 'open' order by created_at limit least(p_limit, 50)) q), '[]');
end $$;

create or replace function public.staff_resolve_report(p_report uuid, p_action text, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.reports;
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  if p_action not in ('dismiss', 'suspend') then perform private.fail('action_invalid'); end if;
  select * into r from public.reports where id = p_report and status = 'open' for update;
  if not found then perform private.fail('not_found'); end if;
  update public.reports set status = case when p_action = 'dismiss' then 'dismissed' else 'actioned' end::public.report_status,
    resolved_at = now(), resolution = p_note where id = p_report;
  if p_action = 'suspend' then
    update private.accounts set status = 'suspended' where user_id = r.subject_id;
  end if;
  insert into private.audit_log (actor, action, subject, detail)
  values (auth.uid(), 'report_' || p_action, r.subject_id, jsonb_build_object('report_id', p_report, 'note', p_note));
end $$;

-- ---------------------------------------------------------------------------------------------
-- Execute grants: only authenticated, only these entrypoints.
do $$
declare f record;
begin
  for f in select p.oid::regprocedure as sig from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where n.nspname = 'public' and p.prokind = 'f'
             and p.proname in ('complete_onboarding', 'set_location', 'register_photo', 'remove_photo',
               'reorder_photos', 'discovery_feed', 'decide', 'send_compliment', 'reply_compliment',
               'dismiss_compliment', 'send_message', 'mark_read', 'extend_match', 'list_conversations', 'member_card',
               'likes_summary', 'my_wallet', 'unmatch', 'block_member', 'unblock_member', 'report_member',
               'register_device', 'request_export', 'request_account_deletion', 'account_state', 'restore_account', 'purge_account', 'staff_photo_queue',
               'staff_decide_photo', 'staff_report_queue', 'staff_resolve_report')
  loop
    execute format('revoke all on function %s from public, anon', f.sig);
    execute format('grant execute on function %s to authenticated', f.sig);
  end loop;
end $$;
revoke all on all functions in schema private from public, anon;
grant execute on function private.is_blocked(uuid, uuid), private.is_staff(text),
  private.is_premium(uuid), private.is_discoverable(uuid), private.can_see_conversation(uuid),
  private.is_counterpart(uuid), private.can_read_photo_object(text), private.ist_day(timestamptz)
  to authenticated;
