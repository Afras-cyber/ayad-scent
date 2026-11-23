-- Storage buckets and policies
begin;

-- Create buckets
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('products', 'products', true, null, array['image/jpeg','image/png','image/webp','image/avif','image/gif']::text[]),
  ('banners', 'banners', true, null, array['image/jpeg','image/png','image/webp','image/avif','image/gif']::text[]),
  ('payment-slips', 'payment-slips', false, null, array['image/jpeg','image/png','image/webp','application/pdf']::text[]),
  ('invoices', 'invoices', false, null, array['application/pdf']::text[])
on conflict (id) do update set
  public = excluded.public,
  allowed_mime_types = excluded.allowed_mime_types;

-- Public read for public buckets
drop policy if exists "Public read products bucket" on storage.objects;
create policy "Public read products bucket"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'products');

drop policy if exists "Public read banners bucket" on storage.objects;
create policy "Public read banners bucket"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'banners');

-- Private buckets: no anon/authenticated read policies (service role bypasses RLS)
-- Explicitly ensure no permissive public policies exist for payment-slips/invoices by not creating them.

-- Optional: allow authenticated/admin writes in future via server/service role only.
-- (Service role bypasses storage RLS; keep direct client writes disabled.)

commit;
