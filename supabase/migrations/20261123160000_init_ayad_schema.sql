-- AYAD Scent Lab - initial schema (Decisions v1, reset-ready)
-- Fresh project rebuild on Supabase (legacy MongoDB/API removed in app layer)

begin;

-- Extensions
create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- ===== Enums =====
do $$ begin
  create type order_status as enum (
    'pending', 'confirmed', 'processing', 'packed', 'shipped', 'delivered', 'cancelled', 'returned'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_method as enum ('cod', 'bank_transfer');
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_status as enum ('unpaid', 'pending_verification', 'paid', 'failed', 'refunded');
exception when duplicate_object then null; end $$;

do $$ begin
  create type notification_event as enum ('order_placed', 'payment_received');
exception when duplicate_object then null; end $$;

do $$ begin
  create type notification_status as enum ('pending', 'processing', 'sent', 'failed', 'skipped');
exception when duplicate_object then null; end $$;

do $$ begin
  create type review_status as enum ('pending', 'approved', 'rejected');
exception when duplicate_object then null; end $$;

do $$ begin
  create type admin_role as enum ('owner', 'manager', 'staff');
exception when duplicate_object then null; end $$;

do $$ begin
  create type product_type as enum ('attar', 'spray', 'gift_set');
exception when duplicate_object then null; end $$;

do $$ begin
  create type concentration_type as enum ('attar_oil', 'parfum', 'edp', 'edt');
exception when duplicate_object then null; end $$;

do $$ begin
  create type note_layer as enum ('top', 'heart', 'base');
exception when duplicate_object then null; end $$;

do $$ begin
  create type occasion_type as enum ('evening', 'party', 'wedding', 'date_night', 'office', 'everyday', 'festive');
exception when duplicate_object then null; end $$;

do $$ begin
  create type season_type as enum ('spring', 'summer', 'autumn', 'winter', 'all_year');
exception when duplicate_object then null; end $$;

-- ===== Sequences / helpers =====
create sequence if not exists order_code_seq start with 10001 increment by 1;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ===== Catalog =====
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  short_description text,
  description text,
  gender text check (gender in ('men','women','unisex')),
  product_type product_type not null default 'spray',
  concentration concentration_type,
  is_active boolean not null default true,
  is_featured boolean not null default false,
  is_trending boolean not null default false,
  trending_rank integer,
  price_from_lkr integer not null default 0 check (price_from_lkr >= 0),
  units_sold integer not null default 0 check (units_sold >= 0),
  rating_avg numeric(2,1) not null default 0,
  rating_count integer not null default 0 check (rating_count >= 0),
  longevity_score smallint check (longevity_score between 1 and 10),
  projection_score smallint check (projection_score between 1 and 10),
  sweetness_score smallint check (sweetness_score between 1 and 10),
  freshness_score smallint check (freshness_score between 1 and 10),
  longevity_min_hours smallint check (longevity_min_hours is null or longevity_min_hours >= 0),
  longevity_max_hours smallint check (longevity_max_hours is null or longevity_max_hours >= 0),
  occasions occasion_type[] not null default '{}'::occasion_type[],
  seasons season_type[] not null default '{}'::season_type[],
  scent_story text,
  search_vector tsvector generated always as (
    setweight(to_tsvector('simple', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(short_description, '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(description, '')), 'C')
  ) stored,
  seo_title text,
  seo_description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint products_longevity_hours_check check (
    longevity_min_hours is null or longevity_max_hours is null or longevity_max_hours >= longevity_min_hours
  )
);

create table if not exists product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  label text not null,
  size_ml integer check (size_ml is null or size_ml > 0),
  sku text unique,
  price_lkr integer not null check (price_lkr >= 0),
  compare_at_lkr integer check (compare_at_lkr is null or compare_at_lkr >= price_lkr),
  stock integer not null default 0 check (stock >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  variant_id uuid references product_variants(id) on delete set null,
  storage_path text,
  image_url text,
  alt_text text,
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  constraint product_images_path_or_url check (storage_path is not null or image_url is not null)
);

create table if not exists collections (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text,
  image_path text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists product_collections (
  product_id uuid not null references products(id) on delete cascade,
  collection_id uuid not null references collections(id) on delete cascade,
  primary key (product_id, collection_id)
);

create table if not exists notes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists product_notes (
  product_id uuid not null references products(id) on delete cascade,
  note_id uuid not null references notes(id) on delete cascade,
  layer note_layer not null default 'heart',
  intensity integer check (intensity between 1 and 5),
  primary key (product_id, note_id)
);

-- ===== Orders & commerce =====
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  code text not null unique default ('AYD-' || nextval('order_code_seq')::text),
  legacy_code text unique,
  customer_name text not null,
  phone_e164 text not null,
  email text,
  address_line text not null,
  city text not null,
  district text not null,
  notes text,
  whatsapp_opt_in boolean not null default false,
  whatsapp_opt_in_at timestamptz,
  payment_method payment_method not null,
  payment_status payment_status not null default 'unpaid',
  status order_status not null default 'pending',
  subtotal_lkr integer not null check (subtotal_lkr >= 0),
  delivery_fee_lkr integer not null check (delivery_fee_lkr >= 0),
  total_lkr integer not null check (total_lkr >= 0),
  idempotency_key text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  variant_id uuid references product_variants(id) on delete set null,
  product_id uuid references products(id) on delete set null,
  product_name text not null,
  variant_label text not null,
  unit_price_lkr integer not null check (unit_price_lkr >= 0),
  quantity integer not null check (quantity between 1 and 20),
  line_total_lkr integer not null check (line_total_lkr >= 0),
  created_at timestamptz not null default now()
);

create table if not exists order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  status order_status not null,
  note text,
  actor_admin_user_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  method payment_method not null,
  amount_lkr integer not null check (amount_lkr > 0),
  reference text,
  slip_path text,
  received_at timestamptz not null default now(),
  recorded_by uuid,
  created_at timestamptz not null default now()
);

create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  kind text not null check (kind in ('invoice','receipt')),
  number text not null unique,
  pdf_path text not null,
  sha256 text not null,
  created_at timestamptz not null default now(),
  unique (order_id, kind)
);

create table if not exists notification_outbox (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  event notification_event not null,
  channel text not null default 'whatsapp',
  status notification_status not null default 'pending',
  payload jsonb not null default '{}'::jsonb,
  attempts integer not null default 0 check (attempts >= 0),
  next_attempt_at timestamptz not null default now(),
  provider_message_id text,
  last_error text,
  sent_at timestamptz,
  created_at timestamptz not null default now(),
  unique (order_id, event, channel)
);

create table if not exists whatsapp_messages (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete set null,
  direction text not null check (direction in ('out','in')),
  provider_message_id text unique,
  phone_e164 text not null,
  template_name text,
  body_preview text,
  status text,
  raw jsonb,
  created_at timestamptz not null default now()
);

-- ===== Reviews, newsletter, content, settings, admin =====
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete set null,
  order_id uuid references orders(id) on delete set null,
  customer_name text not null,
  rating integer not null check (rating between 1 and 5),
  title text,
  body text not null,
  is_verified boolean not null default false,
  status review_status not null default 'pending',
  is_featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  is_active boolean not null default true,
  source text,
  subscribed_at timestamptz not null default now(),
  unsubscribed_at timestamptz
);

create table if not exists banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  image_path text,
  image_url text,
  mobile_image_path text,
  mobile_image_url text,
  link_url text,
  button_text text,
  placement text not null default 'home_hero',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  start_at timestamptz,
  end_at timestamptz,
  background_color text,
  text_color text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists delivery_zones (
  district text primary key,
  fee_lkr integer not null check (fee_lkr >= 0),
  eta_min_days integer check (eta_min_days is null or eta_min_days >= 0),
  eta_max_days integer check (eta_max_days is null or eta_max_days >= 0),
  is_serviceable boolean not null default true,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now(),
  constraint delivery_zones_eta_check check (
    eta_min_days is null or eta_max_days is null or eta_max_days >= eta_min_days
  )
);

create table if not exists site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  is_public boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists admin_users (
  id uuid primary key, -- matches auth.users.id
  email text not null unique,
  full_name text,
  role admin_role not null default 'staff',
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ===== Indexes =====
create index if not exists idx_products_active on products(is_active);
create index if not exists idx_products_featured on products(is_featured);
create index if not exists idx_products_trending on products(is_trending, trending_rank nulls last, units_sold desc);
create index if not exists idx_products_type_gender on products(product_type, gender);
create index if not exists idx_products_price_from on products(price_from_lkr);
create index if not exists idx_products_created on products(created_at desc);
create index if not exists idx_products_search_vector on products using gin(search_vector);
create index if not exists idx_products_name_trgm on products using gin(name gin_trgm_ops);
create index if not exists idx_product_variants_product on product_variants(product_id);
create index if not exists idx_product_variants_active on product_variants(product_id, is_active);
create index if not exists idx_product_variants_size on product_variants(size_ml);
create index if not exists idx_product_images_product_sort on product_images(product_id, sort_order);
create index if not exists idx_product_images_variant on product_images(variant_id);
create index if not exists idx_collections_active on collections(is_active, sort_order);
create index if not exists idx_notes_slug on notes(slug);
create index if not exists idx_product_notes_note on product_notes(note_id);
create index if not exists idx_product_notes_layer on product_notes(product_id, layer);
create index if not exists idx_orders_status_created on orders(status, created_at desc);
create index if not exists idx_orders_phone on orders(phone_e164);
create index if not exists idx_orders_created on orders(created_at desc);
create index if not exists idx_order_items_order on order_items(order_id);
create index if not exists idx_order_events_order_created on order_events(order_id, created_at desc);
create index if not exists idx_payments_order on payments(order_id);
create index if not exists idx_invoices_order on invoices(order_id);
create index if not exists idx_outbox_status_next on notification_outbox(status, next_attempt_at);
create index if not exists idx_outbox_order on notification_outbox(order_id);
create index if not exists idx_whatsapp_messages_order on whatsapp_messages(order_id);
create index if not exists idx_whatsapp_messages_phone on whatsapp_messages(phone_e164);
create index if not exists idx_reviews_product_status on reviews(product_id, status, created_at desc);
create index if not exists idx_reviews_status_created on reviews(status, created_at desc);
create index if not exists idx_newsletter_active on newsletter_subscribers(is_active);
create index if not exists idx_banners_active_sort on banners(is_active, placement, sort_order);
create index if not exists idx_delivery_zones_active on delivery_zones(is_active, sort_order);
create index if not exists idx_admin_users_active on admin_users(is_active);

-- ===== Triggers =====
drop trigger if exists trg_products_updated_at on products;
create trigger trg_products_updated_at before update on products for each row execute function public.set_updated_at();
drop trigger if exists trg_product_variants_updated_at on product_variants;
create trigger trg_product_variants_updated_at before update on product_variants for each row execute function public.set_updated_at();
drop trigger if exists trg_collections_updated_at on collections;
create trigger trg_collections_updated_at before update on collections for each row execute function public.set_updated_at();
drop trigger if exists trg_orders_updated_at on orders;
create trigger trg_orders_updated_at before update on orders for each row execute function public.set_updated_at();
drop trigger if exists trg_reviews_updated_at on reviews;
create trigger trg_reviews_updated_at before update on reviews for each row execute function public.set_updated_at();
drop trigger if exists trg_banners_updated_at on banners;
create trigger trg_banners_updated_at before update on banners for each row execute function public.set_updated_at();
drop trigger if exists trg_delivery_zones_updated_at on delivery_zones;
create trigger trg_delivery_zones_updated_at before update on delivery_zones for each row execute function public.set_updated_at();
drop trigger if exists trg_site_settings_updated_at on site_settings;
create trigger trg_site_settings_updated_at before update on site_settings for each row execute function public.set_updated_at();
drop trigger if exists trg_admin_users_updated_at on admin_users;
create trigger trg_admin_users_updated_at before update on admin_users for each row execute function public.set_updated_at();

-- Maintain products.price_from_lkr from lowest active variant price
create or replace function public.sync_product_price_from_lkr()
returns trigger
language plpgsql
as $$
declare
  v_product_id uuid;
  v_price integer;
begin
  v_product_id := coalesce(new.product_id, old.product_id);
  select coalesce(min(price_lkr), 0)
    into v_price
  from public.product_variants
  where product_id = v_product_id
    and is_active = true;

  update public.products
  set price_from_lkr = v_price
  where id = v_product_id;

  return null;
end;
$$;

drop trigger if exists trg_variants_sync_price_from_insert on product_variants;
create trigger trg_variants_sync_price_from_insert
after insert on product_variants
for each row execute function public.sync_product_price_from_lkr();
drop trigger if exists trg_variants_sync_price_from_update on product_variants;
create trigger trg_variants_sync_price_from_update
after update of price_lkr, is_active, product_id on product_variants
for each row execute function public.sync_product_price_from_lkr();
drop trigger if exists trg_variants_sync_price_from_delete on product_variants;
create trigger trg_variants_sync_price_from_delete
after delete on product_variants
for each row execute function public.sync_product_price_from_lkr();

commit;
