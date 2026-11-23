-- Enable RLS and define policies (fresh project)
begin;

-- Enable RLS on every table
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.product_images enable row level security;
alter table public.collections enable row level security;
alter table public.product_collections enable row level security;
alter table public.notes enable row level security;
alter table public.product_notes enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_events enable row level security;
alter table public.payments enable row level security;
alter table public.invoices enable row level security;
alter table public.notification_outbox enable row level security;
alter table public.whatsapp_messages enable row level security;
alter table public.reviews enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.banners enable row level security;
alter table public.delivery_zones enable row level security;
alter table public.site_settings enable row level security;
alter table public.admin_users enable row level security;

-- ===== Public (anon/authenticated) read access: active catalog data =====
-- Products
drop policy if exists "anon_read_active_products" on public.products;
create policy "anon_read_active_products"
  on public.products for select
  to anon, authenticated
  using (is_active = true);

-- Variants of active products
drop policy if exists "anon_read_active_product_variants" on public.product_variants;
create policy "anon_read_active_product_variants"
  on public.product_variants for select
  to anon, authenticated
  using (
    is_active = true
    and exists (
      select 1 from public.products p
      where p.id = product_variants.product_id and p.is_active = true
    )
  );

-- Images of active products
drop policy if exists "anon_read_active_product_images" on public.product_images;
create policy "anon_read_active_product_images"
  on public.product_images for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.products p
      where p.id = product_images.product_id and p.is_active = true
    )
  );

-- Collections
drop policy if exists "anon_read_active_collections" on public.collections;
create policy "anon_read_active_collections"
  on public.collections for select
  to anon, authenticated
  using (is_active = true);

-- Product-collection links for active products/collections
drop policy if exists "anon_read_active_product_collections" on public.product_collections;
create policy "anon_read_active_product_collections"
  on public.product_collections for select
  to anon, authenticated
  using (
    exists (select 1 from public.products p where p.id = product_collections.product_id and p.is_active = true)
    and exists (select 1 from public.collections c where c.id = product_collections.collection_id and c.is_active = true)
  );

-- Notes and product notes (catalog attributes)
drop policy if exists "anon_read_active_notes" on public.notes;
create policy "anon_read_active_notes"
  on public.notes for select
  to anon, authenticated
  using (is_active = true);

drop policy if exists "anon_read_active_product_notes" on public.product_notes;
create policy "anon_read_active_product_notes"
  on public.product_notes for select
  to anon, authenticated
  using (
    exists (select 1 from public.products p where p.id = product_notes.product_id and p.is_active = true)
    and exists (select 1 from public.notes n where n.id = product_notes.note_id and n.is_active = true)
  );

-- Banners (active and within schedule window when set)
drop policy if exists "anon_read_active_banners" on public.banners;
create policy "anon_read_active_banners"
  on public.banners for select
  to anon, authenticated
  using (
    is_active = true
    and (start_at is null or start_at <= now())
    and (end_at is null or end_at >= now())
  );

-- Delivery zones (active)
drop policy if exists "anon_read_active_delivery_zones" on public.delivery_zones;
create policy "anon_read_active_delivery_zones"
  on public.delivery_zones for select
  to anon, authenticated
  using (is_active = true);

-- Public site settings only
drop policy if exists "anon_read_public_site_settings" on public.site_settings;
create policy "anon_read_public_site_settings"
  on public.site_settings for select
  to anon, authenticated
  using (is_public = true);

-- Approved reviews only
drop policy if exists "anon_read_approved_reviews" on public.reviews;
create policy "anon_read_approved_reviews"
  on public.reviews for select
  to anon, authenticated
  using (status = 'approved');

-- ===== Sensitive tables: no anonymous access =====
-- No policies added for anon/authenticated on:
-- orders, order_items, order_events, payments, invoices, notification_outbox,
-- whatsapp_messages, admin_users, newsletter_subscribers.
-- RLS enabled + no permissive policies => denied for anon/authenticated.

-- Service role bypasses RLS by default in Supabase; admin/server operations should use service role or secured RPCs.

commit;
