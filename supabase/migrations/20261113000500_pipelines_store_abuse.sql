-- Backend V1 continuation: server-side media pipeline (photos and chat media), outbox claiming
-- with retries and dead letters, push preferences and device lifecycle, asynchronous privacy
-- export, store purchase state with entitlement lifecycle, abuse controls and operational health.
-- Workers (tools/backend/worker) call the private.* job functions through the database owner
-- connection; members never can.

-- ---------------------------------------------------------------------------------------------
-- Settings (server-only key/value; deployment-specific values)
create table private.settings (key text primary key, value text not null);
insert into private.settings (key, value) values
  ('store_environment', 'production'),     -- which store environment may grant benefits
  ('report_hold_threshold', '3'),          -- FIXTURE: distinct reporters in 24 h -> review hold
  ('max_unanswered_messages', '10')        -- mirrors kMaxUnansweredMessages in the app
on conflict do nothing;

create or replace function private.setting(k text)
returns text language sql stable security definer set search_path = '' as $$
  select value from private.settings where key = k
$$;

-- ---------------------------------------------------------------------------------------------
-- Photo pipeline: upload (quarantine) -> processing -> ready (metadata stripped, re-encoded) ->
-- moderator decision. Other members only ever read the processed object of an approved photo.
create or replace function private.can_read_photo_object(object_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.photos ph
    where (ph.object_path = object_name or ph.processed_path = object_name)
      and (
        ph.user_id = auth.uid()
        or (
          ph.status = 'approved' and ph.processing = 'ready' and ph.processed_path = object_name
          and not private.is_blocked(auth.uid(), ph.user_id)
          and (private.is_discoverable(ph.user_id) or private.is_counterpart(ph.user_id))
        )
      )
  )
$$;

-- Approved and processed photos only count towards discoverability.
create or replace function private.is_discoverable(uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from private.accounts a
    join public.profiles p on p.user_id = a.user_id
    where a.user_id = uid
      and a.status = 'active'
      and not a.review_hold
      and p.onboarding_complete
      and not p.paused
      and char_length(p.bio) > 0
      and (select count(*) from public.photos ph where ph.user_id = uid and ph.status = 'approved'
             and ph.processing = 'ready') >= 2
      and exists (select 1 from public.prompts pr where pr.user_id = uid)
  )
$$;

-- Worker: claim photos to process (also reclaims jobs a crashed worker left for 10 minutes).
create or replace function private.claim_photo_jobs(lim int default 10)
returns setof public.photos language plpgsql security definer set search_path = '' as $$
begin
  return query
  update public.photos ph set processing = 'processing', processing_started_at = now(), attempts = ph.attempts + 1
  where ph.id in (
    select id from public.photos
    where status = 'pending' and (processing = 'uploaded'
      or (processing = 'processing' and processing_started_at < now() - interval '10 minutes'))
    order by created_at limit lim for update skip locked)
  returning ph.*;
end $$;

create or replace function private.complete_photo_job(p_id uuid, p_processed_path text, p_width int, p_height int)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.photos set processing = 'ready', processed_path = p_processed_path, width = p_width,
    height = p_height, failure_reason = null
  where id = p_id and processing = 'processing';
end $$;

-- A retryable failure goes back to the queue (5 attempts at most); a content failure rejects.
create or replace function private.fail_photo_job(p_id uuid, p_reason text, p_retryable boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.photos set
    processing = case when p_retryable and attempts < 5 then 'uploaded' else 'failed' end,
    status = case when p_retryable and attempts < 5 then status else 'rejected' end::public.photo_status,
    reject_reason = case when p_retryable and attempts < 5 then reject_reason else p_reason end,
    failure_reason = p_reason
  where id = p_id and processing = 'processing';
end $$;

-- Staff see only processed photos; they decide on what members would actually see.
create or replace function public.staff_photo_queue(p_limit int default 20)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  insert into private.audit_log (actor, action) values (auth.uid(), 'staff_photo_queue_viewed');
  return coalesce((select jsonb_agg(jsonb_build_object('photo_id', id, 'user_id', user_id,
      'object_path', processed_path, 'width', width, 'height', height, 'created_at', created_at) order by created_at)
    from (select * from public.photos where status = 'pending' and processing = 'ready'
          order by created_at limit least(p_limit, 50)) q), '[]');
end $$;

create or replace function public.staff_decide_photo(p_photo uuid, p_approve boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  update public.photos set status = case when p_approve then 'approved' else 'rejected' end::public.photo_status,
    reject_reason = case when p_approve then null else p_reason end, decided_at = now()
  where id = p_photo and status = 'pending' and processing = 'ready';
  if not found then perform private.fail('not_found'); end if;
  insert into private.audit_log (actor, action, subject, detail)
  values (auth.uid(), case when p_approve then 'photo_approved' else 'photo_rejected' end, p_photo,
          jsonb_build_object('reason', p_reason));
end $$;

-- Staff need to view the processed object for review (read only, audited by queue view).
create or replace function private.staff_can_read_object(object_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.is_staff() and exists (
    select 1 from public.photos where processed_path = object_name and status = 'pending' and processing = 'ready')
$$;
grant execute on function private.staff_can_read_object(text) to authenticated;
create policy photos_staff_review on storage.objects for select to authenticated
  using (bucket_id = 'photos' and private.staff_can_read_object(name));

-- ---------------------------------------------------------------------------------------------
-- Chat media: images and voice notes (video is not in the MVP and is refused).
create table public.attachments (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  uploader_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('image', 'voice')),
  object_path text not null unique,
  mime text not null,
  bytes integer not null check (bytes between 1 and 15728640),
  duration_ms integer check (duration_ms is null or duration_ms between 1 and 120000),
  processing text not null default 'uploaded' check (processing in ('uploaded', 'processing', 'ready', 'failed')),
  processed_path text unique,
  attempts integer not null default 0,
  processing_started_at timestamptz,
  failure_reason text,
  used_by uuid unique,
  created_at timestamptz not null default now()
);
alter table public.attachments enable row level security;
grant select on public.attachments to authenticated;
create policy attachments_select on public.attachments for select to authenticated
  using (private.can_see_conversation(conversation_id));

alter table public.messages add column attachment_id uuid references public.attachments (id) on delete set null;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('chat-media', 'chat-media', false, 15728640,
  array['image/jpeg', 'image/png', 'image/webp', 'audio/mp4', 'audio/aac', 'audio/x-m4a', 'audio/mpeg', 'audio/ogg'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Upload path: <conversation id>/<uploader id>/<file>, only into a conversation you can write in.
create or replace function private.can_upload_chat_object(object_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.conversations c
    where c.id::text = split_part(object_name, '/', 1)
      and split_part(object_name, '/', 2) = auth.uid()::text
      and auth.uid() in (c.user_a, c.user_b)
      and c.status = 'open'
      and not private.is_blocked(c.user_a, c.user_b)
  )
$$;

create or replace function private.can_read_chat_object(object_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.attachments at
    where (at.object_path = object_name and at.uploader_id = auth.uid())
       or (at.processed_path = object_name and at.processing = 'ready'
           and private.can_see_conversation(at.conversation_id))
  )
$$;
grant execute on function private.can_upload_chat_object(text), private.can_read_chat_object(text) to authenticated;

create policy chat_media_upload on storage.objects for insert to authenticated
  with check (bucket_id = 'chat-media' and private.can_upload_chat_object(name));
create policy chat_media_read on storage.objects for select to authenticated
  using (bucket_id = 'chat-media' and private.can_read_chat_object(name));

create or replace function public.register_attachment(
  p_conversation uuid, p_object_path text, p_kind text, p_duration_ms int default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); obj record; mime text; size int; new_id uuid;
begin
  if p_kind not in ('image', 'voice') then perform private.fail('kind_not_supported'); end if;
  if split_part(p_object_path, '/', 1) <> p_conversation::text or split_part(p_object_path, '/', 2) <> uid::text then
    perform private.fail('forbidden');
  end if;
  if not exists (select 1 from public.conversations c where c.id = p_conversation and uid in (c.user_a, c.user_b)
                 and c.status = 'open' and not private.is_blocked(c.user_a, c.user_b)) then
    perform private.fail('unavailable');
  end if;
  perform private.rate_check(uid, 'attachment', 30, interval '1 hour'); -- FIXTURE
  select o.metadata into obj from storage.objects o where o.bucket_id = 'chat-media' and o.name = p_object_path;
  if not found then perform private.fail('object_missing'); end if;
  mime := coalesce(obj.metadata ->> 'mimetype', '');
  size := coalesce((obj.metadata ->> 'size')::int, 0);
  if p_kind = 'image' and mime not in ('image/jpeg', 'image/png', 'image/webp') then perform private.fail('type_not_allowed'); end if;
  if p_kind = 'voice' and mime not in ('audio/mp4', 'audio/aac', 'audio/x-m4a', 'audio/mpeg', 'audio/ogg') then
    perform private.fail('type_not_allowed');
  end if;
  if size not between 1 and (case when p_kind = 'image' then 10485760 else 15728640 end) then
    perform private.fail('size_not_allowed');
  end if;
  if p_kind = 'voice' and (p_duration_ms is null or p_duration_ms not between 1 and 120000) then
    perform private.fail('duration_not_allowed');
  end if;
  insert into public.attachments (conversation_id, uploader_id, kind, object_path, mime, bytes, duration_ms)
  values (p_conversation, uid, p_kind, p_object_path, mime, size, case when p_kind = 'voice' then p_duration_ms end)
  returning id into new_id;
  return jsonb_build_object('attachment_id', new_id, 'processing', 'uploaded');
exception when unique_violation then
  perform private.fail('already_registered');
end $$;

create or replace function public.attachment_status(p_attachment uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); at public.attachments;
begin
  select * into at from public.attachments where id = p_attachment and uploader_id = uid;
  if not found then perform private.fail('not_found'); end if;
  return jsonb_build_object('processing', at.processing, 'failure_reason', at.failure_reason);
end $$;

-- Sends a ready attachment as a message (with an optional caption). Same ordering and
-- idempotency as send_message; one attachment is used once.
create or replace function public.send_attachment(
  p_conversation uuid, p_client_message_id uuid, p_attachment uuid, p_caption text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_active(); conv public.conversations; existing public.messages;
  at public.attachments; other uuid; s bigint;
begin
  select * into existing from public.messages where sender_id = uid and client_message_id = p_client_message_id;
  if found then
    if existing.conversation_id <> p_conversation or existing.attachment_id is distinct from p_attachment then
      perform private.fail('idempotency_conflict');
    end if;
    return jsonb_build_object('result', 'sent', 'message_id', existing.id, 'seq', existing.seq, 'replayed', true);
  end if;
  if p_caption is not null and char_length(p_caption) > 1000 then perform private.fail('body_invalid'); end if;
  select * into conv from public.conversations where id = p_conversation for update;
  if not found or uid not in (conv.user_a, conv.user_b) then perform private.fail('not_found'); end if;
  other := case when conv.user_a = uid then conv.user_b else conv.user_a end;
  if conv.status <> 'open' or private.is_blocked(uid, other) then perform private.fail('unavailable'); end if;
  if conv.first_message_at is null and conv.match_deadline < now() then perform private.fail('match_expired'); end if;
  select * into at from public.attachments where id = p_attachment for update;
  if not found or at.uploader_id <> uid or at.conversation_id <> conv.id then perform private.fail('not_found'); end if;
  if at.processing <> 'ready' then perform private.fail('attachment_not_ready'); end if;
  if at.used_by is not null then perform private.fail('already_used'); end if;
  if private.unanswered_run(conv.id, uid) >= private.setting('max_unanswered_messages')::int then
    perform private.fail('too_many_unanswered');
  end if;
  perform private.rate_check(uid, 'message', 30, interval '1 minute'); -- FIXTURE
  s := conv.next_seq;
  insert into public.messages (conversation_id, seq, sender_id, client_message_id, kind, body, attachment_id)
  values (conv.id, s, uid, p_client_message_id, case when at.kind = 'image' then 'image' else 'voice' end::public.message_kind,
          nullif(trim(coalesce(p_caption, '')), ''), at.id)
  returning * into existing;
  update public.attachments set used_by = existing.id where id = at.id;
  update public.conversations set next_seq = s + 1, last_message_at = now(),
    first_message_at = coalesce(first_message_at, now()) where id = conv.id;
  insert into private.outbox (kind, recipient, payload, dedupe_key)
  values ('message', other, jsonb_build_object('conversation_id', conv.id, 'seq', s), 'message:' || conv.id || ':' || s);
  perform private.record_activity(uid, 'message');
  return jsonb_build_object('result', 'sent', 'message_id', existing.id, 'seq', s, 'created_at', existing.created_at);
end $$;

create or replace function private.claim_attachment_jobs(lim int default 10)
returns setof public.attachments language plpgsql security definer set search_path = '' as $$
begin
  return query
  update public.attachments a set processing = 'processing', processing_started_at = now(), attempts = a.attempts + 1
  where a.id in (
    select id from public.attachments
    where processing = 'uploaded'
       or (processing = 'processing' and processing_started_at < now() - interval '10 minutes')
    order by created_at limit lim for update skip locked)
  returning a.*;
end $$;

create or replace function private.complete_attachment_job(p_id uuid, p_processed_path text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.attachments set processing = 'ready', processed_path = p_processed_path, failure_reason = null
  where id = p_id and processing = 'processing';
end $$;

create or replace function private.fail_attachment_job(p_id uuid, p_reason text, p_retryable boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.attachments set
    processing = case when p_retryable and attempts < 5 then 'uploaded' else 'failed' end,
    failure_reason = p_reason
  where id = p_id and processing = 'processing';
end $$;

-- ---------------------------------------------------------------------------------------------
-- Outbox: claimed with SKIP LOCKED, retried with exponential backoff, dead-lettered after 8.
alter table private.outbox drop constraint outbox_status_check;
alter table private.outbox add constraint outbox_status_check
  check (status in ('pending', 'processing', 'sent', 'failed', 'dead', 'skipped'));
alter table private.outbox add column last_error text, add column claimed_at timestamptz;
create index outbox_ready_idx on private.outbox (status, available_at);

create or replace function private.claim_outbox(kinds text[], lim int default 50)
returns setof private.outbox language plpgsql security definer set search_path = '' as $$
begin
  return query
  update private.outbox o set status = 'processing', claimed_at = now(), attempts = o.attempts + 1
  where o.id in (
    select id from private.outbox
    where kind = any (kinds)
      and ((status = 'pending' and available_at <= now())
           or (status = 'processing' and claimed_at < now() - interval '10 minutes'))
    order by id limit lim for update skip locked)
  returning o.*;
end $$;

create or replace function private.finish_outbox(p_id bigint, p_status text, p_error text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare o private.outbox;
begin
  select * into o from private.outbox where id = p_id for update;
  if not found then return; end if;
  if p_status = 'retry' then
    update private.outbox set
      status = case when o.attempts >= 8 then 'dead' else 'pending' end,
      available_at = now() + make_interval(secs => least(3600, 15 * power(2, o.attempts))),
      last_error = left(p_error, 300)
    where id = p_id;
  else
    update private.outbox set status = p_status, last_error = left(p_error, 300) where id = p_id;
  end if;
end $$;

-- ---------------------------------------------------------------------------------------------
-- Push: per-category preferences (default on), device lifecycle.
create table private.notification_prefs (
  user_id uuid primary key references auth.users (id) on delete cascade,
  matches boolean not null default true,
  messages boolean not null default true,
  compliments boolean not null default true
);

create or replace function public.set_notification_prefs(p_matches boolean, p_messages boolean, p_compliments boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  insert into private.notification_prefs (user_id, matches, messages, compliments)
  values (uid, p_matches, p_messages, p_compliments)
  on conflict (user_id) do update set matches = excluded.matches, messages = excluded.messages,
    compliments = excluded.compliments;
end $$;

create or replace function public.unregister_device(p_token text)
returns void language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user();
begin
  update public.devices set revoked = true where push_token = p_token and user_id = uid;
end $$;

-- Worker: devices to notify for one outbox row, honouring preferences and blocks.
create or replace function private.push_targets(p_outbox bigint)
returns table (device_id uuid, platform text, push_token text, category text)
language sql stable security definer set search_path = '' as $$
  select d.id, d.platform, d.push_token,
    case o.kind when 'match' then 'matches' when 'message' then 'messages' else 'compliments' end
  from private.outbox o
  join public.devices d on d.user_id = o.recipient and not d.revoked
  left join private.notification_prefs np on np.user_id = o.recipient
  join private.accounts a on a.user_id = o.recipient and a.status = 'active'
  where o.id = p_outbox
    and case o.kind when 'match' then coalesce(np.matches, true)
                    when 'message' then coalesce(np.messages, true)
                    when 'compliment' then coalesce(np.compliments, true) else false end
$$;

create or replace function private.revoke_device(p_device uuid)
returns void language sql security definer set search_path = '' as $$
  update public.devices set revoked = true where id = p_device
$$;

-- ---------------------------------------------------------------------------------------------
-- Privacy export: asynchronous, private expiring download of the member's own data.
alter table public.privacy_requests add column object_path text, add column expires_at timestamptz;
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('exports', 'exports', false, 52428800, array['application/json'])
on conflict (id) do nothing;
create policy exports_read_own on storage.objects for select to authenticated
  using (bucket_id = 'exports' and (storage.foldername(name))[1] = (select auth.uid())::text
         and exists (select 1 from public.privacy_requests r where r.object_path = name
                     and r.user_id = auth.uid() and r.status = 'completed' and r.expires_at > now()));


-- The member's own data (no other member's words, no other member's private fields).
create or replace function private.build_export(uid uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
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
    'messages_sent', (select coalesce(jsonb_agg(jsonb_build_object('conversation_id', conversation_id,
               'seq', seq, 'kind', kind, 'body', body, 'at', created_at) order by created_at), '[]')
               from public.messages where sender_id = uid),
    'credit_ledger', (select coalesce(jsonb_agg(jsonb_build_object('bucket', bucket, 'delta', delta,
               'reason', reason, 'at', created_at) order by id), '[]') from private.credit_ledger where user_id = uid),
    'notification_prefs', (select to_jsonb(n) from private.notification_prefs n where n.user_id = uid),
    'blocks', (select count(*) from public.blocks where blocker_id = uid),
    'exported_at', now())
$$;

-- Requires a recent sign-in (amr timestamp within 15 minutes) before releasing personal data.
create or replace function private.recently_authenticated(max_age interval default interval '15 minutes')
returns boolean language sql stable set search_path = '' as $$
  select coalesce((
    select max((m ->> 'timestamp')::bigint)
    from jsonb_array_elements(coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'amr', '[]')) m
  ) >= extract(epoch from now() - max_age)::bigint, false)
$$;

create or replace function public.request_export()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare uid uuid := private.require_user(); rid uuid;
begin
  if not private.recently_authenticated() then perform private.fail('reauth_required'); end if;
  perform private.rate_check(uid, 'export', 5, interval '1 day');
  select id into rid from public.privacy_requests where user_id = uid and kind = 'export' and status = 'pending';
  if rid is null then
    insert into public.privacy_requests (user_id, kind) values (uid, 'export') returning id into rid;
    insert into private.outbox (kind, recipient, payload, dedupe_key)
    values ('privacy_export', uid, jsonb_build_object('request_id', rid), 'export:' || rid);
  end if;
  return jsonb_build_object('result', 'export_scheduled', 'request_id', rid);
end $$;

create or replace function private.complete_export(p_request uuid, p_object_path text)
returns void language sql security definer set search_path = '' as $$
  update public.privacy_requests set status = 'completed', completed_at = now(), object_path = p_object_path,
    expires_at = now() + interval '7 days'
  where id = p_request and kind = 'export' and status = 'pending'
$$;

-- ---------------------------------------------------------------------------------------------
-- Abuse controls

-- Distinct reporters in 24 h at or above the threshold put the subject on a quiet review hold
-- (out of discovery, nothing else changes) until staff resolve it.
create or replace function private.after_report()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select count(distinct reporter_id) from public.reports
      where subject_id = new.subject_id and status = 'open' and created_at > now() - interval '24 hours')
     >= private.setting('report_hold_threshold')::int then
    update private.accounts set review_hold = true where user_id = new.subject_id and not review_hold;
    if found then
      insert into private.audit_log (actor, action, subject) values (null, 'review_hold_applied', new.subject_id);
    end if;
  end if;
  return new;
end $$;
create trigger reports_after_insert after insert on public.reports
  for each row execute function private.after_report();

create or replace function public.staff_clear_hold(p_user uuid, p_note text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  update private.accounts set review_hold = false where user_id = p_user;
  insert into private.audit_log (actor, action, subject, detail)
  values (auth.uid(), 'review_hold_cleared', p_user, jsonb_build_object('note', p_note));
end $$;

-- One-sided messaging guard, server-side: at most N messages in a row without a reply.
create or replace function private.unanswered_run(conv uuid, uid uuid)
returns int language sql stable security definer set search_path = '' as $$
  select count(*)::int from public.messages m
  where m.conversation_id = conv and m.sender_id = uid
    and m.seq > coalesce((select max(seq) from public.messages x where x.conversation_id = conv and x.sender_id <> uid), 0)
$$;

-- ---------------------------------------------------------------------------------------------
-- Store purchases and entitlement lifecycle (verification happens in the store functions).
create table private.store_purchases (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  store text not null check (store in ('google_play', 'app_store')),
  product_id text not null,
  purchase_key text not null,           -- Play purchase token hash / App Store originalTransactionId
  environment text not null check (environment in ('production', 'sandbox')),
  state text not null check (state in ('active', 'grace', 'pending', 'expired', 'refunded', 'revoked')),
  expires_at timestamptz,
  last_event_at timestamptz not null,
  verified_at timestamptz not null default now(),
  unique (store, purchase_key)
);

create table private.store_events (
  store text not null,
  event_id text not null,
  received_at timestamptz not null default now(),
  primary key (store, event_id)
);

-- Applies a VERIFIED store state. Idempotent; older events never overwrite newer state; only the
-- configured environment grants benefits; consumable packs grant once and reverse once.
create or replace function private.apply_purchase_state(
  p_user uuid, p_store text, p_key text, p_product text, p_env text, p_state text,
  p_expires timestamptz, p_event_at timestamptz)
returns text language plpgsql security definer set search_path = '' as $$
declare cur private.store_purchases; grants_benefit boolean; bal int; outcome text := 'applied';
begin
  perform pg_advisory_xact_lock(hashtextextended('store:' || p_store || ':' || p_key, 0));
  select * into cur from private.store_purchases where store = p_store and purchase_key = p_key;
  if found then
    if cur.user_id <> p_user then return 'account_mismatch'; end if;
    if p_event_at < cur.last_event_at then return 'stale_event'; end if;
    update private.store_purchases set state = p_state, expires_at = p_expires, last_event_at = p_event_at,
      verified_at = now(), product_id = p_product where id = cur.id;
  else
    insert into private.store_purchases (user_id, store, product_id, purchase_key, environment, state, expires_at, last_event_at)
    values (p_user, p_store, p_product, p_key, p_env, p_state, p_expires, p_event_at);
  end if;
  grants_benefit := p_env = private.setting('store_environment');
  if not grants_benefit then outcome := 'environment_not_granting'; end if;

  if p_product like 'numaya_premium_%' then
    if grants_benefit and p_state in ('active', 'grace') and p_expires > now() then
      insert into private.entitlements (user_id, product, active_until, source)
      values (p_user, 'premium', p_expires, 'store:' || p_store || ':' || p_key)
      on conflict (user_id, product, source) do update set active_until = excluded.active_until;
    else
      update private.entitlements set active_until = least(active_until, now())
      where user_id = p_user and source = 'store:' || p_store || ':' || p_key;
    end if;
  elsif p_product = 'numaya_compliments_3' and grants_benefit then
    if p_state = 'active' then
      insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
      values (p_user, 'purchased', 3, 'purchase', 'purchase:' || p_store || ':' || p_key)
      on conflict (user_id, source_key) do nothing;
    elsif p_state in ('refunded', 'revoked') and exists (select 1 from private.credit_ledger
          where user_id = p_user and source_key = 'purchase:' || p_store || ':' || p_key) then
      perform pg_advisory_xact_lock(hashtextextended('credits:' || p_user::text, 0));
      bal := private.balance(p_user, 'purchased');
      if least(3, bal) > 0 then
        insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
        values (p_user, 'purchased', -least(3, bal), 'reversal', 'refund:' || p_store || ':' || p_key)
        on conflict (user_id, source_key) do nothing;
      end if;
      if bal < 3 then
        insert into private.audit_log (action, subject, detail)
        values ('refund_after_spend', p_user, jsonb_build_object('purchase', p_key, 'unrecovered', 3 - greatest(bal, 0)));
      end if;
    end if;
  end if;
  return outcome;
end $$;

-- Daily sweep: subscriptions past expiry without a renewal event lose the benefit.
create or replace function private.expire_store_entitlements()
returns int language sql security definer set search_path = '' as $$
  with x as (
    update private.store_purchases set state = 'expired'
    where state in ('active', 'grace') and expires_at is not null and expires_at < now() - interval '1 hour'
    returning 1)
  select count(*)::int from x
$$;

-- ---------------------------------------------------------------------------------------------
-- Operational health (staff): queue ages and backlogs, no personal data.
create or replace function public.staff_ops_health()
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_staff() then perform private.fail('forbidden'); end if;
  return jsonb_build_object(
    'photos_waiting_processing', (select count(*) from public.photos where status = 'pending' and processing in ('uploaded', 'processing')),
    'photos_waiting_review', (select count(*) from public.photos where status = 'pending' and processing = 'ready'),
    'oldest_review_minutes', (select extract(epoch from now() - min(created_at)) / 60 from public.photos where status = 'pending' and processing = 'ready'),
    'photos_failed_24h', (select count(*) from public.photos where processing = 'failed' and created_at > now() - interval '1 day'),
    'attachments_waiting', (select count(*) from public.attachments where processing in ('uploaded', 'processing')),
    'outbox_pending', (select coalesce(jsonb_object_agg(kind, n), '{}') from (select kind, count(*) n from private.outbox where status in ('pending', 'processing') group by kind) x),
    'outbox_dead', (select count(*) from private.outbox where status = 'dead'),
    'open_reports', (select count(*) from public.reports where status = 'open'),
    'oldest_report_hours', (select extract(epoch from now() - min(created_at)) / 3600 from public.reports where status = 'open'),
    'review_holds', (select count(*) from private.accounts where review_hold),
    'deletions_overdue', (select count(*) from private.deletion_tombstones where completed_at is null and purge_after < now() - interval '1 day'),
    'exports_pending', (select count(*) from public.privacy_requests where kind = 'export' and status = 'pending'),
    'checked_at', now());
end $$;

-- ---------------------------------------------------------------------------------------------
-- Grants for the new member and staff entry points.
do $$
declare f record;
begin
  for f in select p.oid::regprocedure as sig from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where n.nspname = 'public' and p.prokind = 'f'
             and p.proname in ('register_attachment', 'attachment_status', 'send_attachment',
               'set_notification_prefs', 'unregister_device', 'request_export', 'staff_clear_hold',
               'staff_ops_health', 'staff_photo_queue', 'staff_decide_photo')
  loop
    execute format('revoke all on function %s from public, anon', f.sig);
    execute format('grant execute on function %s to authenticated', f.sig);
  end loop;
end $$;
revoke all on function private.claim_photo_jobs(int), private.complete_photo_job(uuid, text, int, int),
  private.fail_photo_job(uuid, text, boolean), private.claim_attachment_jobs(int),
  private.complete_attachment_job(uuid, text), private.fail_attachment_job(uuid, text, boolean),
  private.claim_outbox(text[], int), private.finish_outbox(bigint, text, text), private.push_targets(bigint),
  private.revoke_device(uuid), private.complete_export(uuid, text), private.build_export(uuid),
  private.apply_purchase_state(uuid, text, text, text, text, text, timestamptz, timestamptz),
  private.expire_store_entitlements() from public, anon, authenticated;
