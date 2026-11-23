-- AYAD initial schema (fresh Supabase project)
-- Includes: enums, tables, constraints, indexes, order code sequence, helper triggers

begin;

create extension if not exists pgcrypto;

-- ===== Enums =====
do $$ begin
  create type order_status as enum ('pending','confirmed','packed','dispatched','delivered','cancelled','returned');
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_method as enum ('cod','bank_transfer');
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_status as enum ('unpaid','awaiting_verification','paid','refunded');
exception when duplicate_object then null; end $$;

do $$ begin
  create type notification_event as enum ('order_placed','payment_received','order_dispatched','order_delivered','order_cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type notification_status as enum ('pending','processing','sent','delivered','read','failed','skipped');
exception when duplicate_object then null; end $$;

do $$ begin
  create type review_status as enum ('pending','approved','rejected');
exception when duplicate_object then null; end $$;

do $$ begin
  create type admin_role as enum ('admin','staff');
exception when duplicate_object then null; end $$;

-- ===== Sequences =====
create sequence if not exists order_code_seq start 10001;

-- ===== Catalog =====
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  short_description text,
  description text,
  gender text check (gender in ('men','women','unisex')),
  is_active boolean not null default true,
  is_featured boolean not null default false,
  rating_avg numeric(2,1) not null default 0,
  rating_count integer not null default 0 check (rating_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  label text not null,
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
  note_type text check (note_type in ('top','middle','base','general')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists product_notes (
  product_id uuid not null references products(id) on delete cascade,
  note_id uuid not null references notes(id) on delete cascade,
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
  id uuid primary key default gen_random_uuid(),
  district text not null unique,
  province text,
  fee_lkr integer not null default 0 check (fee_lkr >= 0),
  estimated_days_min integer check (estimated_days_min is null or estimated_days_min >= 0),
  estimated_days_max integer check (estimated_days_max is null or estimated_days_max >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  description text,
  is_public boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists admin_users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  name text not null,
  password_hash text,
  role admin_role not null default 'staff',
  is_active boolean not null default true,
  phone text,
  avatar_url text,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ===== Indexes =====
create index if not exists idx_product_variants_product_id on product_variants(product_id);
create index if not exists idx_product_variants_active on product_variants(product_id, is_active);
create index if not exists idx_product_images_product_id on product_images(product_id, sort_order);
create index if not exists idx_products_active_featured on products(is_active, is_featured);
create index if not exists idx_products_slug on products(slug);
create index if not exists idx_collections_active on collections(is_active, sort_order);
create index if not exists idx_orders_phone_e164 on orders(phone_e164);
create index if not exists idx_orders_status_created_at on orders(status, created_at desc);
create index if not exists idx_orders_code on orders(code);
create index if not exists idx_orders_legacy_code on orders(legacy_code);
create index if not exists idx_order_items_order_id on order_items(order_id);
create index if not exists idx_order_events_order_id on order_events(order_id, created_at);
create index if not exists idx_payments_order_id on payments(order_id, received_at desc);
create index if not exists idx_invoices_order_id on invoices(order_id);
create index if not exists idx_notification_outbox_status_next on notification_outbox(status, next_attempt_at);
create index if not exists idx_whatsapp_messages_order_id on whatsapp_messages(order_id, created_at desc);
create index if not exists idx_reviews_product_status on reviews(product_id, status);
create index if not exists idx_reviews_status_featured on reviews(status, is_featured);
create index if not exists idx_banners_active_sort on banners(is_active, placement, sort_order);
create index if not exists idx_delivery_zones_active on delivery_zones(is_active, district);

-- ===== updated_at helper =====
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$ begin
  create trigger trg_products_updated_at before update on products for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_product_variants_updated_at before update on product_variants for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_collections_updated_at before update on collections for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_orders_updated_at before update on orders for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_reviews_updated_at before update on reviews for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_banners_updated_at before update on banners for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_delivery_zones_updated_at before update on delivery_zones for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_site_settings_updated_at before update on site_settings for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;
do $$ begin
  create trigger trg_admin_users_updated_at before update on admin_users for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

commit;
