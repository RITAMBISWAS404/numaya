-- Helpers, row-level security and sign-up bootstrap.
-- Every security-definer function has an empty search_path and fully qualified names.

create or replace function private.ist_day(ts timestamptz default now())
returns date language sql stable set search_path = '' as $$
  select (ts at time zone 'Asia/Kolkata')::date
$$;

-- Monday of the IST week containing ts.
create or replace function private.ist_week_start(ts timestamptz default now())
returns date language sql stable set search_path = '' as $$
  select private.ist_day(ts) - (extract(isodow from private.ist_day(ts))::int - 1)
$$;

create or replace function private.age_years(birth date, on_day date default null)
returns int language sql stable set search_path = '' as $$
  select extract(year from age(coalesce(on_day, private.ist_day()), birth))::int
$$;

create or replace function private.is_blocked(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  )
$$;

create or replace function private.is_staff(role_needed text default 'moderator')
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from private.staff_members s
    where s.user_id = auth.uid()
      and (role_needed = 'moderator' or s.role = 'admin')
  )
$$;

create or replace function private.is_premium(uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from private.entitlements e
    where e.user_id = uid and e.product = 'premium' and e.active_until > now()
  )
$$;

-- Visible in discovery: active, onboarded, not paused, two approved photos, a bio and a prompt.
create or replace function private.is_discoverable(uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from private.accounts a
    join public.profiles p on p.user_id = a.user_id
    where a.user_id = uid
      and a.status = 'active'
      and p.onboarding_complete
      and not p.paused
      and char_length(p.bio) > 0
      and (select count(*) from public.photos ph where ph.user_id = uid and ph.status = 'approved') >= 2
      and exists (select 1 from public.prompts pr where pr.user_id = uid)
  )
$$;

-- The caller may see this conversation and its messages.
create or replace function private.can_see_conversation(conv uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.conversations c
    where c.id = conv
      and auth.uid() in (c.user_a, c.user_b)
      and (
        c.status in ('compliment_pending', 'open')
        or (c.status = 'dismissed' and exists (
              select 1 from public.compliments m
              where m.conversation_id = c.id and m.sender_id = auth.uid()))
      )
  )
$$;

-- The caller has a visible conversation with this member (chat header, profile from a chat).
create or replace function private.is_counterpart(other uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.conversations c
    where ((c.user_a = auth.uid() and c.user_b = other) or (c.user_b = auth.uid() and c.user_a = other))
      and private.can_see_conversation(c.id)
  )
$$;

-- Photo objects: the owner, or anyone signed in when the photo is approved, its owner is
-- discoverable or a counterpart, and there is no block between the two.
create or replace function private.can_read_photo_object(object_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.photos ph
    where ph.object_path = object_name
      and (
        ph.user_id = auth.uid()
        or (
          ph.status = 'approved'
          and not private.is_blocked(auth.uid(), ph.user_id)
          and (private.is_discoverable(ph.user_id) or private.is_counterpart(ph.user_id))
        )
      )
  )
$$;

revoke all on all functions in schema private from public, anon, authenticated;
grant usage on schema private to authenticated;
grant execute on function private.is_blocked(uuid, uuid), private.is_staff(text),
  private.is_premium(uuid), private.is_discoverable(uuid), private.can_see_conversation(uuid),
  private.is_counterpart(uuid), private.can_read_photo_object(text), private.ist_day(timestamptz)
  to authenticated;
-- Note: `usage` on schema private lets policies call these helpers; the schema is not exposed by
-- the Data API and its tables carry no grants for authenticated.

-- ---------------------------------------------------------------------------------------------
-- Policies
create policy profiles_select on public.profiles for select to authenticated
  using (user_id = auth.uid() or (private.is_counterpart(user_id) and not private.is_blocked(auth.uid(), user_id)));
create policy profiles_update on public.profiles for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy preferences_own on public.preferences for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy prompts_select on public.prompts for select to authenticated
  using (user_id = auth.uid() or (private.is_counterpart(user_id) and not private.is_blocked(auth.uid(), user_id)));
create policy prompts_insert on public.prompts for insert to authenticated
  with check (user_id = auth.uid());
create policy prompts_update on public.prompts for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy prompts_delete on public.prompts for delete to authenticated
  using (user_id = auth.uid());

create policy photos_select on public.photos for select to authenticated
  using (user_id = auth.uid()
    or (status = 'approved' and private.is_counterpart(user_id) and not private.is_blocked(auth.uid(), user_id)));

create policy conversations_select on public.conversations for select to authenticated
  using (private.can_see_conversation(id));

create policy messages_select on public.messages for select to authenticated
  using (private.can_see_conversation(conversation_id));

create policy reads_own on public.conversation_reads for select to authenticated
  using (user_id = auth.uid());

-- Compliment rows are read through RPCs only (a sender must not learn "dismissed").
create policy blocks_own on public.blocks for select to authenticated
  using (blocker_id = auth.uid());
create policy consents_own on public.consents for select to authenticated
  using (user_id = auth.uid());
create policy devices_own_select on public.devices for select to authenticated
  using (user_id = auth.uid());
create policy devices_own_delete on public.devices for delete to authenticated
  using (user_id = auth.uid());
create policy privacy_own on public.privacy_requests for select to authenticated
  using (user_id = auth.uid());

-- ---------------------------------------------------------------------------------------------
-- Sign-up bootstrap: one account, profile and preferences row per auth user.
create or replace function private.on_auth_user_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into private.accounts (user_id) values (new.id) on conflict do nothing;
  insert into public.profiles (user_id) values (new.id) on conflict do nothing;
  insert into public.preferences (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.on_auth_user_created();

create or replace function private.touch_profile()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;
create trigger profiles_touch before update on public.profiles
  for each row execute function private.touch_profile();
