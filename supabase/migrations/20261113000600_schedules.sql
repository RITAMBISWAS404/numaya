-- Database-only schedules (pg_cron, available on hosted Supabase). Jobs that need the secret key
-- or a provider (media processing, push, purge, export, store reconciliation) run in the Node
-- worker (tools/backend/worker), scheduled outside the database (ACTIVATION_RUNBOOK).

create or replace function private.housekeeping()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare rate_rows int; stale_devices int; expired int;
begin
  delete from private.rate_events where at < now() - interval '2 days';
  get diagnostics rate_rows = row_count;
  -- FCM treats tokens unused for a long time as stale; revoke after 270 days without a refresh.
  update public.devices set revoked = true where not revoked and last_seen < now() - interval '270 days';
  get diagnostics stale_devices = row_count;
  expired := private.expire_store_entitlements();
  -- Expired exports are no longer downloadable (the worker removes the objects).
  update public.privacy_requests set status = 'completed' where kind = 'export' and status = 'completed'
    and expires_at < now();
  return jsonb_build_object('rate_events_deleted', rate_rows, 'devices_revoked', stale_devices,
    'store_purchases_expired', expired, 'at', now());
end $$;
revoke all on function private.housekeeping() from public, anon, authenticated;

create extension if not exists pg_cron;
select cron.schedule('numaya-housekeeping', '17 * * * *', $$select private.housekeeping()$$);
