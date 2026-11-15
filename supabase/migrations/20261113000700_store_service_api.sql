-- Service-only entry points for the store Edge Functions (called with the secret/service key).
-- Members and anonymous callers cannot execute them.

create or replace function public.service_apply_purchase_state(
  p_user uuid, p_store text, p_key text, p_product text, p_env text, p_state text,
  p_expires timestamptz, p_event_at timestamptz)
returns text language sql security definer set search_path = '' as $$
  select private.apply_purchase_state(p_user, p_store, p_key, p_product, p_env, p_state, p_expires, p_event_at)
$$;

-- Records a store notification id; false when it was already processed (replay).
create or replace function public.service_record_store_event(p_store text, p_event_id text)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  insert into private.store_events (store, event_id) values (p_store, p_event_id);
  return true;
exception when unique_violation then
  return false;
end $$;

-- The existing purchase for a key (voided notifications carry no product id).
create or replace function public.service_purchase_by_key(p_store text, p_key text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('user_id', user_id, 'product_id', product_id, 'environment', environment)
  from private.store_purchases where store = p_store and purchase_key = p_key
$$;

revoke all on function public.service_apply_purchase_state(uuid, text, text, text, text, text, timestamptz, timestamptz),
  public.service_record_store_event(text, text), public.service_purchase_by_key(text, text)
  from public, anon, authenticated;
grant execute on function public.service_apply_purchase_state(uuid, text, text, text, text, text, timestamptz, timestamptz),
  public.service_record_store_event(text, text), public.service_purchase_by_key(text, text) to service_role;
