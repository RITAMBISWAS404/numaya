-- Numaya MVP transactional functions (PRD 05). NOT APPLIED; see 0001 status note.
-- 2026-11-08: archive lifecycle (R01/R02); request_reconnect / respond_reconnect removed.
--
-- Each endpoint: authenticated (auth.uid()), idempotent on (user, key), validates, performs the
-- debit and state transition in one transaction, stores a durable response and writes an outbox
-- event. Deadlines are evaluated on write, so a delayed job never extends anything.
-- Retries reuse the same key. Error codes are stable strings the app maps to copy.

create or replace function ist_today() returns date
language sql stable as $$ select (now() at time zone 'Asia/Kolkata')::date $$;

create or replace function _replay(p_key text, p_endpoint text) returns jsonb
language sql stable security definer set search_path = public as $$
  select response from idempotency where user_id = auth.uid() and key = p_key and endpoint = p_endpoint
$$;

create or replace function _remember(p_key text, p_endpoint text, p_response jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  insert into idempotency (user_id, key, endpoint, response) values (auth.uid(), p_key, p_endpoint, p_response)
  on conflict (user_id, key) do nothing;
  return p_response;
end $$;

create or replace function is_premium(p_user uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from subscriptions where user_id = p_user and paid_through > now())
$$;

-- Creates the match (and its conversation) for a pair, converting a pending Compliment into the
-- first message of that same conversation. Returns the match id.
create or replace function _create_match(a uuid, b uuid) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_match uuid;
  v_conv uuid;
  v_intro compliments%rowtype;
begin
  insert into matches (user_low, user_high, first_deadline)
  values (least(a, b), greatest(a, b), now() + interval '24 hours')
  on conflict (user_low, user_high) do nothing
  returning id into v_match;
  if v_match is null then
    select id into v_match from matches where user_low = least(a, b) and user_high = greatest(a, b);
    return v_match;
  end if;
  insert into conversations (match_id) values (v_match) returning id into v_conv;
  insert into conversation_members (conversation_id, user_id) values (v_conv, a), (v_conv, b);
  select * into v_intro from compliments
   where pair_low = least(a, b) and pair_high = greatest(a, b) and status = 'pending' for update;
  if found then
    insert into messages (id, conversation_id, sender, body, accepted_at)
    values (gen_random_uuid(), v_conv, v_intro.sender, v_intro.body, v_intro.created_at);
    update compliments set status = 'converted' where id = v_intro.id;
    update matches set state = 'active', first_message_at = v_intro.created_at,
                       last_message_at = v_intro.created_at where id = v_match;
  end if;
  insert into notifications_outbox (user_id, kind, payload)
  values (a, 'match', jsonb_build_object('match', v_match)), (b, 'match', jsonb_build_object('match', v_match));
  return v_match;
end $$;

-- submitLike: idempotent per (sender, recipient); quota debit and mutual-match creation atomic.
create or replace function submit_like(p_key text, p_recipient uuid, p_positive boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  v_prev jsonb := _replay(p_key, 'submit_like');
  v_limit int;
  v_used int;
  v_match uuid;
begin
  if v_prev is not null then return v_prev; end if;
  if me is null then raise exception 'unauthenticated'; end if;
  if is_blocked(me, p_recipient) or not exists (
       select 1 from profiles p join users_private u using (user_id)
       where p.user_id = p_recipient and p.discoverable and u.status = 'active') then
    return _remember(p_key, 'submit_like', jsonb_build_object('error', 'recipient_unavailable'));
  end if;
  if exists (select 1 from likes where sender = me and recipient = p_recipient) then
    return _remember(p_key, 'submit_like', jsonb_build_object('result', 'already_decided'));
  end if;
  if p_positive then
    v_limit := case when is_premium(me) then 15 else 5 end;
    perform pg_advisory_xact_lock(hashtext(me::text || ist_today()::text));
    select count(*) into v_used from likes where sender = me and positive and ist_day = ist_today();
    if v_used >= v_limit then
      return _remember(p_key, 'submit_like', jsonb_build_object('error', 'out_of_likes',
        'resets_at', ((ist_today() + 1)::timestamp at time zone 'Asia/Kolkata')));
    end if;
  end if;
  insert into likes (sender, recipient, positive, ist_day) values (me, p_recipient, p_positive, ist_today());
  insert into streak_days (user_id, ist_day, decisions) values (me, ist_today(), 1)
  on conflict (user_id, ist_day) do update set decisions = streak_days.decisions + 1;
  if p_positive and (
       exists (select 1 from likes where sender = p_recipient and recipient = me and positive)
       or exists (select 1 from compliments where sender = p_recipient and recipient = me and status = 'pending')) then
    v_match := _create_match(me, p_recipient);
    return _remember(p_key, 'submit_like', jsonb_build_object('result', 'matched', 'match', v_match));
  end if;
  return _remember(p_key, 'submit_like',
    jsonb_build_object('result', case when p_positive then 'liked' else 'passed' end));
end $$;

-- Spends one credit (weekly, then earned, then purchased). Raises 'insufficient_credits'.
create or replace function _spend_credit(p_user uuid, p_key text, p_source text) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_bucket text;
  v_id uuid;
begin
  perform pg_advisory_xact_lock(hashtext('ledger:' || p_user::text));
  select b into v_bucket from (values ('weekly', 1), ('earned', 2), ('purchased', 3)) as o(b, ord)
   where (select coalesce(sum(amount), 0) from credit_ledger where user_id = p_user and bucket = o.b) > 0
   order by ord limit 1;
  if v_bucket is null then raise exception 'insufficient_credits'; end if;
  insert into credit_ledger (user_id, idempotency_key, kind, bucket, amount, source)
  values (p_user, p_key, 'spend', v_bucket, -1, p_source) returning id into v_id;
  return v_id;
end $$;

-- sendCompliment: one lifetime introduction per pair; credit spent only on an accepted send.
create or replace function send_compliment(
  p_key text, p_recipient uuid, p_target_kind text, p_target uuid, p_body text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  v_prev jsonb := _replay(p_key, 'send_compliment');
  v_entry uuid;
  v_id uuid;
begin
  if v_prev is not null then return v_prev; end if;
  if char_length(trim(p_body)) not between 1 and 150 then
    return _remember(p_key, 'send_compliment', jsonb_build_object('error', 'invalid_length'));
  end if;
  if is_blocked(me, p_recipient) then
    return _remember(p_key, 'send_compliment', jsonb_build_object('error', 'recipient_unavailable'));
  end if;
  if exists (select 1 from compliments where pair_low = least(me, p_recipient) and pair_high = greatest(me, p_recipient))
     or exists (select 1 from matches where user_low = least(me, p_recipient) and user_high = greatest(me, p_recipient)) then
    return _remember(p_key, 'send_compliment', jsonb_build_object('error', 'pair_already_introduced'));
  end if;
  begin
    v_entry := _spend_credit(me, 'compliment:' || p_key, 'compliment:' || p_key);
  exception when raise_exception then
    return _remember(p_key, 'send_compliment', jsonb_build_object('error', 'insufficient_credits'));
  end;
  insert into compliments (sender, recipient, target_kind, photo_id, prompt_id, body, credit_entry)
  values (me, p_recipient, p_target_kind,
          case when p_target_kind = 'photo' then p_target end,
          case when p_target_kind = 'prompt' then p_target end,
          trim(p_body), v_entry)
  returning id into v_id;
  insert into notifications_outbox (user_id, kind, payload)
  values (p_recipient, 'request', jsonb_build_object('compliment', v_id));
  return _remember(p_key, 'send_compliment', jsonb_build_object('result', 'sent', 'compliment', v_id));
end $$;

-- replyToRequest: free; creates the reciprocal conversation atomically.
create or replace function reply_to_request(p_key text, p_compliment uuid, p_message_id uuid, p_body text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  v_prev jsonb := _replay(p_key, 'reply_to_request');
  v_c compliments%rowtype;
  v_match uuid;
  v_conv uuid;
begin
  if v_prev is not null then return v_prev; end if;
  select * into v_c from compliments where id = p_compliment and recipient = me for update;
  if not found or v_c.status <> 'pending' or is_blocked(me, v_c.sender) then
    return _remember(p_key, 'reply_to_request', jsonb_build_object('error', 'request_unavailable'));
  end if;
  v_match := _create_match(me, v_c.sender);           -- converts the compliment into message 1
  select id into v_conv from conversations where match_id = v_match;
  insert into messages (id, conversation_id, sender, body) values (p_message_id, v_conv, me, trim(p_body))
  on conflict (id) do nothing;
  update matches set state = 'active', last_message_at = now() where id = v_match;
  update compliments set status = 'replied' where id = p_compliment;
  return _remember(p_key, 'reply_to_request', jsonb_build_object('result', 'opened', 'match', v_match));
end $$;

-- Evaluates and persists a match's phase now (used on every write and by the lifecycle job).
-- awaiting_first_message -> expired (terminal) at first_deadline; active <-> archived after 7 days
-- without an accepted message. System notices are not messages, so they never move last_message_at.
create or replace function refresh_match(p_match uuid) returns text
language plpgsql security definer set search_path = public as $$
declare
  m matches%rowtype;
begin
  select * into m from matches where id = p_match for update;
  if m.state in ('blocked', 'unmatched', 'expired') then return m.state; end if;
  if m.first_message_at is null then
    if now() >= m.first_deadline then
      update matches set state = 'expired', expired_at = m.first_deadline where id = p_match;
      return 'expired';
    end if;
    return 'awaiting_first_message';
  end if;
  if now() >= m.last_message_at + interval '7 days' then
    if m.state <> 'archived' then
      update matches set state = 'archived', archived_at = m.last_message_at + interval '7 days'
       where id = p_match;
    end if;
    return 'archived';
  end if;
  return 'active';
end $$;

-- sendMessage: client UUID makes retries idempotent. An initial match accepts it only before the
-- deadline; an archived chat accepts it and becomes active again for both people.
create or replace function send_message(p_message_id uuid, p_conversation uuid, p_body text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  v_match uuid;
  v_state text;
  v_other uuid;
  v_run int;
begin
  if exists (select 1 from messages where id = p_message_id) then
    return jsonb_build_object('result', 'accepted', 'duplicate', true);
  end if;
  select c.match_id into v_match from conversations c
    join conversation_members cm on cm.conversation_id = c.id and cm.user_id = me
   where c.id = p_conversation;
  if v_match is null then return jsonb_build_object('error', 'not_a_member'); end if;
  v_state := refresh_match(v_match);
  if v_state not in ('awaiting_first_message', 'active', 'archived') then
    return jsonb_build_object('error', 'chat_closed', 'state', v_state);
  end if;
  select user_id into v_other from conversation_members where conversation_id = p_conversation and user_id <> me;
  if is_blocked(me, v_other) then return jsonb_build_object('error', 'chat_closed'); end if;
  -- One-sided spam guard: at most 10 consecutive unanswered messages.
  select count(*) into v_run from (
    select sender from messages where conversation_id = p_conversation
     and accepted_at > coalesce((select max(accepted_at) from messages
                                  where conversation_id = p_conversation and sender <> me), '-infinity')
  ) t;
  if v_run >= 10 then return jsonb_build_object('error', 'wait_for_reply'); end if;
  insert into messages (id, conversation_id, sender, body) values (p_message_id, p_conversation, me, trim(p_body));
  update matches set state = 'active', archived_at = null,
         first_message_at = coalesce(first_message_at, now()), last_message_at = now()
   where id = v_match;
  insert into streak_days (user_id, ist_day, messages) values (me, ist_today(), 1)
  on conflict (user_id, ist_day) do update set messages = streak_days.messages + 1;
  -- Notification failure never reverses the message: the outbox is drained separately.
  insert into notifications_outbox (user_id, kind, payload)
  select v_other, 'message', jsonb_build_object('conversation', p_conversation)
   where not exists (select 1 from conversation_members where conversation_id = p_conversation
                       and user_id = v_other and muted);
  return jsonb_build_object('result', 'accepted');
end $$;

-- extendMatch: one per match; free one per IST week (Monday), Premium one per IST day.
create or replace function extend_match(p_key text, p_match uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  v_prev jsonb := _replay(p_key, 'extend_match');
  m matches%rowtype;
  v_used boolean;
begin
  if v_prev is not null then return v_prev; end if;
  if refresh_match(p_match) <> 'awaiting_first_message' then
    return _remember(p_key, 'extend_match', jsonb_build_object('error', 'not_extendable'));
  end if;
  select * into m from matches where id = p_match and me in (user_low, user_high) for update;
  if m.extended_by is not null then
    return _remember(p_key, 'extend_match', jsonb_build_object('error', 'already_extended'));
  end if;
  select exists (select 1 from matches where extended_by = me and (
           case when is_premium(me)
                then (first_deadline - interval '24 hours') at time zone 'Asia/Kolkata' >= ist_today()::timestamp
                else date_trunc('week', (first_deadline - interval '24 hours') at time zone 'Asia/Kolkata')
                     = date_trunc('week', now() at time zone 'Asia/Kolkata') end))
    into v_used;
  -- NOTE: production should record extension uses in their own table (extension_uses) rather
  -- than inferring them from deadlines; kept inline here for review.
  if v_used then
    return _remember(p_key, 'extend_match', jsonb_build_object('error',
      case when is_premium(me) then 'used_today' else 'needs_premium' end));
  end if;
  update matches set first_deadline = first_deadline + interval '24 hours', extended_by = me where id = p_match;
  return _remember(p_key, 'extend_match', jsonb_build_object('result', 'extended'));
end $$;

-- claimRecovery and verifyPurchase need store receipt verification (Google Play Developer API)
-- and run as an Edge Function with the service role: see backend/functions/CONTRACTS.md.

grant execute on function submit_like, send_compliment, reply_to_request, send_message,
  extend_match to authenticated;
