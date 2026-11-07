-- Numaya MVP schema (PRD 05). Target: managed PostgreSQL with row-level security (Supabase is the
-- candidate; nothing here is Supabase-only except auth.uid(), which a plain Postgres deployment
-- replaces with its own session function).
--
-- STATUS: NOT APPLIED to any database. No project, credentials or environment exist yet
-- (docs/product/mvp-prd-v1/LIVE_BLOCKERS.md). Review with the backend owner before applying.
--
-- Principles
-- - Every business rule that moves money, credits or connection state runs server-side in the
--   transactional functions (0002), never as a direct client write. Clients get SELECT on their own
--   rows only; INSERT/UPDATE/DELETE on rule tables are revoked from `authenticated`.
-- - Phone, date of birth and coordinates live in users_private and are never readable by others.
-- - Timestamps are UTC (timestamptz). Day and week boundaries are Asia/Kolkata.
-- - Idempotency keys are unique per user; replaying a key returns the stored response.

create extension if not exists pgcrypto;

-- Accounts ---------------------------------------------------------------------------------------
create table users_private (
  user_id        uuid primary key references auth.users (id) on delete cascade,
  phone_e164     text not null unique,
  date_of_birth  date not null,
  -- Coarse location only: city-level point, never a trail.
  approx_lat     numeric(6, 3),
  approx_lng     numeric(6, 3),
  city           text,
  status         text not null default 'active'
                 check (status in ('active', 'paused', 'restricted', 'suspended', 'deleting')),
  created_at     timestamptz not null default now(),
  deleted_at     timestamptz
  -- 18+ is enforced by complete_onboarding() at write time (a CHECK must not depend on now()).
);

create table profiles (
  user_id        uuid primary key references users_private (user_id) on delete cascade,
  display_name   text not null check (char_length(display_name) between 1 and 30),
  gender         text not null check (gender in ('woman', 'man', 'nonbinary')),
  pronouns       text[] not null default '{}',
  intention      text not null check (intention in ('relationship', 'casual', 'figuring_out')),
  bio            text not null check (char_length(bio) between 1 and 300),
  -- Public age, derived and refreshed by job; DOB itself stays private.
  age            smallint not null check (age >= 18),
  city           text,
  discoverable   boolean not null default false,
  updated_at     timestamptz not null default now()
);

create table photos (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id) on delete cascade,
  position       smallint not null check (position between 0 and 5),
  storage_path   text not null,
  moderation     text not null default 'pending'
                 check (moderation in ('pending', 'approved', 'rejected')),
  deleted_at     timestamptz,
  created_at     timestamptz not null default now(),
  unique (user_id, position)
);

create table prompts (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id) on delete cascade,
  position       smallint not null check (position between 0 and 2),
  question       text not null,
  answer         text not null check (char_length(answer) between 1 and 150),
  deleted_at     timestamptz,
  unique (user_id, position)
);

create table preferences (
  user_id        uuid primary key references profiles (user_id) on delete cascade,
  genders        text[] not null default '{}',
  min_age        smallint not null default 18 check (min_age >= 18),
  max_age        smallint not null default 99,
  max_km         smallint not null default 50,
  -- Premium-only filters are stored even after expiry; only free filters execute without Premium.
  intentions     text[] not null default '{}',
  lifestyle      jsonb not null default '{}'::jsonb,
  check (min_age <= max_age)
);

-- Connections ------------------------------------------------------------------------------------
create table likes (
  sender         uuid not null references profiles (user_id) on delete cascade,
  recipient      uuid not null references profiles (user_id) on delete cascade,
  positive       boolean not null,
  ist_day        date not null,
  created_at     timestamptz not null default now(),
  primary key (sender, recipient),
  check (sender <> recipient)
);
create index likes_quota on likes (sender, ist_day) where positive;

create table compliments (
  id             uuid primary key default gen_random_uuid(),
  sender         uuid not null references profiles (user_id) on delete cascade,
  recipient      uuid not null references profiles (user_id) on delete cascade,
  pair_low       uuid generated always as (least(sender, recipient)) stored,
  pair_high      uuid generated always as (greatest(sender, recipient)) stored,
  target_kind    text not null check (target_kind in ('photo', 'prompt')),
  photo_id       uuid references photos (id),
  prompt_id      uuid references prompts (id),
  body           text not null check (char_length(body) between 1 and 150),
  status         text not null default 'pending'
                 check (status in ('pending', 'replied', 'dismissed', 'converted', 'blocked')),
  credit_entry   uuid not null,
  created_at     timestamptz not null default now(),
  -- One lifetime introduction per unordered pair (MVP).
  unique (pair_low, pair_high),
  check ((target_kind = 'photo') = (photo_id is not null)),
  check ((target_kind = 'prompt') = (prompt_id is not null))
);

create table matches (
  id             uuid primary key default gen_random_uuid(),
  user_low       uuid not null references profiles (user_id) on delete cascade,
  user_high      uuid not null references profiles (user_id) on delete cascade,
  state          text not null default 'awaiting_first_message'
                 check (state in ('awaiting_first_message', 'active', 'expired',
                                  'reconnect_pending', 'blocked', 'unmatched')),
  matched_at     timestamptz not null default now(),
  first_deadline timestamptz not null,
  extended_by    uuid references profiles (user_id),
  first_message_at timestamptz,
  last_message_at  timestamptz,
  reopened_at    timestamptz,
  expired_at     timestamptz,
  expiry_kind    text check (expiry_kind in ('no_first_message', 'quiet')),
  check (user_low < user_high),
  unique (user_low, user_high)
);

create table conversations (
  id             uuid primary key default gen_random_uuid(),
  match_id       uuid not null unique references matches (id) on delete cascade
);

create table conversation_members (
  conversation_id uuid not null references conversations (id) on delete cascade,
  user_id        uuid not null references profiles (user_id) on delete cascade,
  muted          boolean not null default false,
  check_in_seen_for timestamptz,
  primary key (conversation_id, user_id)
);

create table messages (
  id             uuid primary key,                 -- client-generated UUID: retries never duplicate
  conversation_id uuid not null references conversations (id) on delete cascade,
  sender         uuid not null references profiles (user_id),
  body           text not null check (char_length(body) between 1 and 2000),
  accepted_at    timestamptz not null default now()
);
create index messages_thread on messages (conversation_id, accepted_at);

create table reconnect_requests (
  id             uuid primary key default gen_random_uuid(),
  match_id       uuid not null references matches (id) on delete cascade,
  requester      uuid not null references profiles (user_id),
  episode        timestamptz not null,             -- the expiry this request answers
  status         text not null default 'pending' check (status in ('pending', 'accepted', 'declined')),
  created_at     timestamptz not null default now(),
  responded_at   timestamptz,
  unique (match_id, episode)                       -- one request per pair per expiry episode
);

-- Safety -----------------------------------------------------------------------------------------
create table blocks (
  blocker        uuid not null references profiles (user_id) on delete cascade,
  blocked        uuid not null references profiles (user_id) on delete cascade,
  created_at     timestamptz not null default now(),
  primary key (blocker, blocked)
);

create table reports (
  id             uuid primary key default gen_random_uuid(),
  reporter       uuid not null references profiles (user_id),
  reported       uuid not null references profiles (user_id),
  reason         text not null,
  detail         text check (char_length(detail) <= 1000),
  message_ids    uuid[] not null default '{}',     -- only messages the reporter explicitly selected
  also_blocked   boolean not null default false,
  status         text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  created_at     timestamptz not null default now()
);

create table moderation_actions (
  id             uuid primary key default gen_random_uuid(),
  subject        uuid not null references profiles (user_id),
  report_id      uuid references reports (id),
  action         text not null,
  reason_public  text,                              -- what the member may be told
  actor          uuid not null,                     -- staff user; audited
  created_at     timestamptz not null default now()
);

create table admin_audit_log (
  id             bigserial primary key,
  actor          uuid not null,
  action         text not null,
  target         text not null,
  at             timestamptz not null default now()
);

create table support_tickets (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id) on delete cascade,
  topic          text not null,
  body           text not null,
  is_appeal      boolean not null default false,
  status         text not null default 'received' check (status in ('received', 'in_progress', 'resolved')),
  created_at     timestamptz not null default now()
);

-- Commerce, credits and streaks --------------------------------------------------------------------
create table credit_ledger (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id) on delete cascade,
  idempotency_key text not null,
  kind           text not null check (kind in ('grant', 'spend', 'expiry', 'reversal')),
  bucket         text not null check (bucket in ('weekly', 'earned', 'purchased')),
  amount         integer not null check (amount <> 0),
  source         text not null,
  ref_entry      uuid references credit_ledger (id),
  at             timestamptz not null default now(),
  unique (user_id, idempotency_key)
);
-- Append-only: no UPDATE or DELETE for anyone but the deletion job.
create rule credit_ledger_no_update as on update to credit_ledger do instead nothing;

create table subscriptions (
  user_id        uuid primary key references profiles (user_id) on delete cascade,
  product_id     text not null,
  activated_at   timestamptz not null,               -- anchors weekly credits
  paid_through   timestamptz not null,
  auto_renew     boolean not null default true,
  store          text not null check (store in ('google_play', 'app_store'))
);

create table purchases (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id),
  store          text not null,
  store_txn_id   text not null unique,               -- replay-resistant
  product_id     text not null,
  state          text not null check (state in ('pending', 'verified', 'refunded', 'void')),
  verified_at    timestamptz,
  raw_receipt    jsonb not null
);

create table streak_days (
  user_id        uuid not null references profiles (user_id) on delete cascade,
  ist_day        date not null,
  decisions      integer not null default 0,
  messages       integer not null default 0,
  review_done    boolean not null default false,
  repaired       boolean not null default false,
  primary key (user_id, ist_day)
);

create table reward_cycles (
  user_id        uuid not null references profiles (user_id) on delete cascade,
  run_start      date not null,
  cycle          integer not null,
  result         text not null check (result in ('granted', 'skipped_at_cap')),
  ledger_entry   uuid references credit_ledger (id),
  at             timestamptz not null default now(),
  primary key (user_id, run_start, cycle)          -- award unique per (user, cycle)
);

create table recovery_events (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles (user_id),
  missed_day     date not null,
  purchase_id    uuid references purchases (id),
  outcome        text not null check (outcome in ('repaired', 'refused_not_charged')),
  at             timestamptz not null default now()
);

create table idempotency (
  user_id        uuid not null,
  key            text not null,
  endpoint       text not null,
  response       jsonb not null,
  at             timestamptz not null default now(),
  primary key (user_id, key)
);

-- Notifications and analytics -----------------------------------------------------------------------
create table notifications_outbox (
  id             bigserial primary key,
  user_id        uuid not null references profiles (user_id) on delete cascade,
  kind           text not null check (kind in ('message', 'match', 'check_in', 'reward', 'request')),
  payload        jsonb not null,                    -- minimal: ids only, never message text
  created_at     timestamptz not null default now(),
  sent_at        timestamptz
);

create table analytics_events (
  id             bigserial primary key,
  pseudonymous_id uuid not null,
  name           text not null,
  at             timestamptz not null default now(),
  props          jsonb not null default '{}'::jsonb  -- never OTP, message bodies or coordinates
);

create table profile_exposures_daily (
  viewer_pseudonym uuid not null,
  profile_id     uuid not null references profiles (user_id) on delete cascade,
  ist_day        date not null,
  primary key (viewer_pseudonym, profile_id, ist_day)  -- deduplicated per viewer/profile/day
);

create table insights_daily (
  user_id        uuid not null references profiles (user_id) on delete cascade,
  ist_day        date not null,
  exposures      integer not null default 0,
  likes          integer not null default 0,
  matches        integer not null default 0,
  conversations  integer not null default 0,
  primary key (user_id, ist_day)
);

-- Row-level security --------------------------------------------------------------------------------
alter table users_private enable row level security;
alter table profiles enable row level security;
alter table photos enable row level security;
alter table prompts enable row level security;
alter table preferences enable row level security;
alter table likes enable row level security;
alter table compliments enable row level security;
alter table matches enable row level security;
alter table conversations enable row level security;
alter table conversation_members enable row level security;
alter table messages enable row level security;
alter table reconnect_requests enable row level security;
alter table blocks enable row level security;
alter table reports enable row level security;
alter table moderation_actions enable row level security;
alter table admin_audit_log enable row level security;
alter table support_tickets enable row level security;
alter table credit_ledger enable row level security;
alter table subscriptions enable row level security;
alter table purchases enable row level security;
alter table streak_days enable row level security;
alter table reward_cycles enable row level security;
alter table recovery_events enable row level security;
alter table idempotency enable row level security;
alter table notifications_outbox enable row level security;
alter table analytics_events enable row level security;
alter table profile_exposures_daily enable row level security;
alter table insights_daily enable row level security;

-- Helper: true when either user blocked the other.
create or replace function is_blocked(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from blocks where (blocker = a and blocked = b) or (blocker = b and blocked = a));
$$;

-- users_private: only the owner, read-only (writes via onboarding functions).
create policy own_private_read on users_private for select using (user_id = auth.uid());

-- profiles: discoverable, non-blocked profiles are readable; the owner can always read their own.
create policy profile_read on profiles for select using (
  user_id = auth.uid()
  or (discoverable and not is_blocked(auth.uid(), user_id))
  or exists (select 1 from matches m
             where auth.uid() in (m.user_low, m.user_high)
               and user_id in (m.user_low, m.user_high)
               and m.state not in ('blocked'))
);
create policy profile_write on profiles for update using (user_id = auth.uid());

create policy photos_read on photos for select using (
  deleted_at is null and (user_id = auth.uid() or (moderation = 'approved'
    and exists (select 1 from profiles p where p.user_id = photos.user_id and p.discoverable)
    and not is_blocked(auth.uid(), user_id)))
);
create policy prompts_read on prompts for select using (
  deleted_at is null and (user_id = auth.uid() or not is_blocked(auth.uid(), user_id))
);
create policy prefs_own on preferences for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- likes: a sender sees what they sent; incoming likes are served by a Premium-checked function only.
create policy likes_own on likes for select using (sender = auth.uid());

create policy compliments_parties on compliments for select using (
  (sender = auth.uid() or (recipient = auth.uid() and status = 'pending'))
  and not is_blocked(sender, recipient)
);

create policy matches_members on matches for select using (auth.uid() in (user_low, user_high));
create policy conversations_members on conversations for select using (
  exists (select 1 from conversation_members cm where cm.conversation_id = id and cm.user_id = auth.uid())
);
create policy members_own on conversation_members for select using (user_id = auth.uid());
-- Messages require membership and a non-terminal match (history stays readable after expiry).
create policy messages_members on messages for select using (
  exists (
    select 1 from conversation_members cm
    join conversations c on c.id = cm.conversation_id
    join matches m on m.id = c.match_id
    where cm.conversation_id = messages.conversation_id
      and cm.user_id = auth.uid()
      and m.state not in ('blocked', 'unmatched')
  )
);
create policy reconnect_parties on reconnect_requests for select using (
  exists (select 1 from matches m where m.id = match_id and auth.uid() in (m.user_low, m.user_high))
);

create policy blocks_own on blocks for select using (blocker = auth.uid());
-- Reports: the reporter sees their own receipt; the reported person never sees the reporter.
create policy reports_own on reports for select using (reporter = auth.uid());
create policy tickets_own on support_tickets for select using (user_id = auth.uid());
create policy ledger_own on credit_ledger for select using (user_id = auth.uid());
create policy subs_own on subscriptions for select using (user_id = auth.uid());
create policy purchases_own on purchases for select using (user_id = auth.uid());
create policy streak_own on streak_days for select using (user_id = auth.uid());
create policy rewards_own on reward_cycles for select using (user_id = auth.uid());
create policy recovery_own on recovery_events for select using (user_id = auth.uid());
create policy insights_own on insights_daily for select using (user_id = auth.uid());
-- moderation_actions, admin_audit_log, idempotency, notifications_outbox, analytics_events and
-- profile_exposures_daily have no client policies: service role and staff tooling only.

-- Clients never write rule tables directly; the transactional functions (0002) do.
revoke insert, update, delete on
  users_private, likes, compliments, matches, conversations, conversation_members, messages,
  reconnect_requests, blocks, reports, moderation_actions, support_tickets, credit_ledger,
  subscriptions, purchases, streak_days, reward_cycles, recovery_events, idempotency,
  notifications_outbox, analytics_events, profile_exposures_daily, insights_daily
from authenticated, anon;
