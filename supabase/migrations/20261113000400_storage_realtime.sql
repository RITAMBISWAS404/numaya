-- Private photo storage and realtime delivery.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Upload only into your own folder: photos/<auth uid>/<file>.
create policy photos_upload_own on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Read: the owner, or an approved photo of a visible, unblocked member (signed URLs are issued
-- only when this passes; already-issued URLs live until their short expiry).
create policy photos_read on storage.objects for select to authenticated
  using (bucket_id = 'photos' and private.can_read_photo_object(name));

-- Delete: your own objects that no live photo row references (remove_photo first).
create policy photos_delete_own on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text
         and not exists (select 1 from public.photos ph where ph.object_path = name
                         and ph.status in ('pending', 'approved')));

-- Realtime (postgres_changes honours RLS per subscriber).
alter publication supabase_realtime add table public.messages, public.conversations;
