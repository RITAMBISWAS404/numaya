-- Numaya core schema (backend V1). Supabase Postgres; actor = auth.uid() from the verified JWT.
-- Deny by default: RLS on every exposed table, explicit grants, sensitive data in schema `private`
-- (not exposed through the Data API). Day boundaries are IST (Asia/Kolkata), computed from UTC.
-- Policy numbers come from apps/numaya_mobile/lib/features/commerce/domain/catalog.dart
-- (AllowancePolicy) and docs/product/mvp-prd-v1/DECISIONS.md; see docs/backend/DATA_DICTIONARY.md.

create extension if not exists postgis with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------
-- Enumerations
create type public.gender as enum ('woman', 'man', 'nonbinary');
create type public.photo_status as enum ('pending', 'approved', 'rejected', 'removed');
create type public.decision_kind as enum ('like', 'pass', 'compliment');
create type public.conversation_status as enum (
  'compliment_pending', -- a Compliment waits for the recipient; only it is visible
  'open',               -- matched (by mutual like or an accepted Compliment)
  'dismissed',          -- the recipient said "Not now"; hidden from the recipient
  'unmatched',          -- either member unmatched; no further access
  'blocked',            -- a block between the pair; no further access
  'closed'              -- a member deleted their account
);
create type public.message_kind as enum ('text', 'compliment', 'image', 'voice');
create type public.compliment_status as enum ('pending', 'accepted', 'dismissed', 'blocked', 'closed');
create type public.compliment_target as enum ('photo', 'prompt');
create type public.account_status as enum ('onboarding', 'active', 'paused', 'underage', 'suspended', 'deleted');
create type public.credit_bucket as enum ('weekly', 'earned', 'purchased');
create type public.report_status as enum ('open', 'actioned', 'dismissed');

-- ---------------------------------------------------------------------------------------------
-- Private account data (never exposed through the Data API)
create table private.accounts (
  user_id uuid primary key references auth.users (id) on delete cascade,
  status public.account_status not null default 'onboarding',
  birth_date date,
  created_at timestamptz not null default now(),
  onboarded_at timestamptz,
  deleted_at timestamptz,
  review_hold boolean not null default false, -- abuse control: out of discovery pending staff review
  constraint birth_date_sane check (birth_date is null or birth_date > date '1900-01-01')
);

create table private.locations (
  user_id uuid primary key references auth.users (id) on delete cascade,
  -- Rounded to 0.1 degree (about 11 km) before storage; raw coordinates are never kept.
  point extensions.geography(point, 4326) not null,
  updated_at timestamptz not null default now()
);
create index locations_point_idx on private.locations using gist (point);

create table private.staff_members (
  user_id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('moderator', 'admin')),
  granted_by text not null, -- provisioned out of band (SQL by the owner), never self-assigned
  granted_at timestamptz not null default now()
);

create table private.entitlements (
  user_id uuid not null references auth.users (id) on delete cascade,
  product text not null check (product in ('premium')),
  active_until timestamptz not null,
  source text not null, -- 'store:<transaction>' when billing exists; 'staff_test' for dev only
  created_at timestamptz not null default now(),
  primary key (user_id, product, source)
);

create table private.credit_ledger (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  bucket public.credit_bucket not null,
  delta integer not null check (delta <> 0),
  reason text not null check (reason in ('welcome', 'streak', 'weekly', 'purchase', 'spend', 'expiry', 'reversal')),
  source_key text not null,
  created_at timestamptz not null default now(),
  unique (user_id, source_key)
);
create index credit_ledger_user_idx on private.credit_ledger (user_id, bucket);

create table private.daily_usage (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null, -- IST calendar day
  likes integer not null default 0,
  qualified boolean not null default false,
  primary key (user_id, day)
);

create table private.extensions_used (
  user_id uuid not null references auth.users (id) on delete cascade,
  conversation_id uuid not null,
  used_at timestamptz not null default now(),
  primary key (user_id, conversation_id)
);

create table private.audit_log (
  id bigint generated always as identity primary key,
  actor uuid,
  action text not null,
  subject uuid,
  detail jsonb not null default '{}',
  at timestamptz not null default now()
);

create table private.outbox (
  id bigint generated always as identity primary key,
  kind text not null,
  recipient uuid,
  payload jsonb not null default '{}', -- ids only: never message bodies, phones or coordinates
  dedupe_key text not null unique,
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed', 'dead')),
  attempts integer not null default 0,
  available_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table private.deletion_tombstones (
  user_id uuid primary key,
  requested_at timestamptz not null default now(),
  -- Approved restore window (B-75, F27): 28 days, unless the member deletes for good.
  purge_after timestamptz not null default now() + interval '28 days',
  completed_at timestamptz
);

create table private.rate_events (
  user_id uuid not null,
  action text not null,
  at timestamptz not null default now()
);
create index rate_events_idx on private.rate_events (user_id, action, at);

-- ---------------------------------------------------------------------------------------------
-- Member-visible data (RLS)
create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  first_name text not null default '' check (char_length(first_name) <= 30),
  gender public.gender,
  pronouns text[] not null default '{}' check (cardinality(pronouns) <= 4),
  show_pronouns boolean not null default false,
  open_to public.gender[] not null default '{}',
  looking_for text[] not null default '{}' check (cardinality(looking_for) <= 2
    and looking_for <@ array['longTerm', 'open', 'casual']),
  interests text[] not null default '{}' check (cardinality(interests) <= 5),
  bio text not null default '' check (char_length(bio) <= 300),
  height_cm smallint check (height_cm is null or height_cm between 90 and 250),
  city_label text check (city_label is null or char_length(city_label) <= 60),
  -- Server-owned (no client UPDATE grant on these columns):
  verified boolean not null default false,
  onboarding_complete boolean not null default false,
  paused boolean not null default false,
  updated_at timestamptz not null default now()
);

create table public.preferences (
  user_id uuid primary key references auth.users (id) on delete cascade,
  age_min smallint not null default 18 check (age_min between 18 and 100),
  age_max smallint not null default 100 check (age_max between 18 and 100),
  max_distance_km smallint not null default 50 check (max_distance_km between 1 and 500),
  constraint age_range check (age_min <= age_max)
);

create table public.prompts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  position smallint not null check (position between 1 and 3),
  question text not null check (char_length(question) between 1 and 120),
  answer text not null check (char_length(answer) between 1 and 150),
  created_at timestamptz not null default now(),
  unique (user_id, position)
);

create table public.photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  object_path text not null unique,
  position smallint not null check (position between 1 and 6),
  status public.photo_status not null default 'pending',
  reject_reason text,
  bytes integer check (bytes is null or bytes between 1 and 10485760),
  -- Server-side pipeline: uploaded (quarantine) -> processing -> ready (re-encoded, no metadata)
  processing text not null default 'uploaded' check (processing in ('uploaded', 'processing', 'ready', 'failed')),
  processed_path text unique,
  width integer,
  height integer,
  attempts integer not null default 0,
  processing_started_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default now(),
  decided_at timestamptz
);
-- At most one active (non-removed, non-rejected) photo per position. Deferrable so a reorder can
-- swap positions inside one transaction.
alter table public.photos add constraint photos_active_position
  exclude using btree (user_id with =, position with =)
  where (status in ('pending', 'approved')) deferrable initially immediate;

create table public.decisions (
  actor_id uuid not null references auth.users (id) on delete cascade,
  target_id uuid not null references auth.users (id) on delete cascade,
  kind public.decision_kind not null,
  idempotency_key text not null check (char_length(idempotency_key) between 8 and 80),
  result text not null,
  conversation_id uuid,
  created_at timestamptz not null default now(),
  primary key (actor_id, target_id),
  unique (actor_id, idempotency_key),
  constraint no_self check (actor_id <> target_id)
);
create index decisions_target_idx on public.decisions (target_id, kind);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references auth.users (id) on delete cascade,
  user_b uuid not null references auth.users (id) on delete cascade,
  status public.conversation_status not null,
  origin text not null check (origin in ('like', 'compliment')),
  matched_at timestamptz,
  match_deadline timestamptz,
  extended boolean not null default false,
  first_message_at timestamptz,
  last_message_at timestamptz,
  next_seq bigint not null default 1,
  created_at timestamptz not null default now(),
  constraint ordered_pair check (user_a < user_b),
  unique (user_a, user_b) -- one thread per pair, ever (no rematch after unmatch/block)
);
create index conversations_a_idx on public.conversations (user_a, status);
create index conversations_b_idx on public.conversations (user_b, status);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  seq bigint not null,
  sender_id uuid not null references auth.users (id) on delete cascade,
  client_message_id uuid not null,
  kind public.message_kind not null default 'text',
  body text check (body is null or char_length(body) between 1 and 1000),
  context jsonb, -- Compliment context snapshot (target kind, question or photo id, text)
  created_at timestamptz not null default now(),
  unique (conversation_id, seq),
  unique (sender_id, client_message_id)
);

create table public.conversation_reads (
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  last_read_seq bigint not null default 0,
  primary key (conversation_id, user_id)
);

create table public.compliments (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null unique references public.conversations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  recipient_id uuid not null references auth.users (id) on delete cascade,
  target_kind public.compliment_target not null,
  target_ref uuid not null,
  body text not null check (char_length(body) between 1 and 150),
  status public.compliment_status not null default 'pending',
  idempotency_key text not null,
  payload_hash text not null,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (sender_id, idempotency_key)
);

create table public.blocks (
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint no_self_block check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users (id) on delete set null,
  subject_id uuid references auth.users (id) on delete set null,
  conversation_id uuid references public.conversations (id) on delete set null,
  message_id uuid,
  category text not null check (category in ('fake', 'harassment', 'inappropriate', 'scam', 'underage', 'safety', 'other')),
  note text check (note is null or char_length(note) <= 1000),
  -- Evidence is copied at report time, so it survives unmatch, block or deletion (retention: DECISIONS_REQUIRED).
  evidence jsonb not null default '{}',
  status public.report_status not null default 'open',
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolution text
);

create table public.consents (
  user_id uuid not null references auth.users (id) on delete cascade,
  document text not null check (document in ('terms', 'privacy', 'community')),
  version text not null check (char_length(version) between 1 and 20),
  accepted_at timestamptz not null default now(),
  primary key (user_id, document, version)
);

create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios')),
  push_token text not null check (char_length(push_token) <= 4096),
  revoked boolean not null default false,
  last_seen timestamptz not null default now(),
  unique (push_token)
);

create table public.privacy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  kind text not null check (kind in ('export', 'delete')),
  status text not null default 'pending' check (status in ('pending', 'completed', 'failed')),
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

-- ---------------------------------------------------------------------------------------------
-- Grants: nothing for anon; authenticated gets only what RLS then narrows. Writes that carry
-- business rules go through security-definer RPCs (next migration), not table grants.
revoke all on all tables in schema public from anon, authenticated;
revoke all on all tables in schema private from anon, authenticated;

grant select on public.profiles, public.preferences, public.prompts, public.photos,
  public.conversations, public.messages, public.conversation_reads, public.compliments,
  public.blocks, public.consents, public.devices, public.privacy_requests to authenticated;

grant update (first_name, gender, pronouns, show_pronouns, open_to, looking_for, interests, bio,
  height_cm, city_label, paused) on public.profiles to authenticated;
grant insert, update (age_min, age_max, max_distance_km) on public.preferences to authenticated;
grant insert, update, delete on public.prompts to authenticated;
grant delete on public.devices to authenticated;

alter table public.profiles enable row level security;
alter table public.preferences enable row level security;
alter table public.prompts enable row level security;
alter table public.photos enable row level security;
alter table public.decisions enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.conversation_reads enable row level security;
alter table public.compliments enable row level security;
alter table public.blocks enable row level security;
alter table public.reports enable row level security;
alter table public.consents enable row level security;
alter table public.devices enable row level security;
alter table public.privacy_requests enable row level security;
