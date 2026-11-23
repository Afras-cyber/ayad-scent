-- AYAD Scent Lab seed data (Decisions v1, reset-ready)
begin;

-- Delivery zones (Sri Lanka districts) - seed placeholders, admin-editable
insert into public.delivery_zones (district, fee_lkr, eta_min_days, eta_max_days, is_serviceable, is_active, sort_order)
values
  ('Ampara', 500, 2, 5, true, true, 1),
  ('Anuradhapura', 450, 2, 5, true, true, 2),
  ('Badulla', 450, 2, 5, true, true, 3),
  ('Batticaloa', 500, 3, 6, true, true, 4),
  ('Colombo', 300, 1, 2, true, true, 5),
  ('Galle', 350, 1, 4, true, true, 6),
  ('Gampaha', 300, 1, 3, true, true, 7),
  ('Hambantota', 450, 2, 5, true, true, 8),
  ('Jaffna', 550, 3, 6, true, true, 9),
  ('Kalutara', 300, 1, 3, true, true, 10),
  ('Kandy', 400, 2, 4, true, true, 11),
  ('Kegalle', 400, 2, 4, true, true, 12),
  ('Kilinochchi', 550, 3, 6, true, true, 13),
  ('Kurunegala', 400, 2, 4, true, true, 14),
  ('Mannar', 550, 3, 6, true, true, 15),
  ('Matale', 400, 2, 4, true, true, 16),
  ('Matara', 400, 2, 4, true, true, 17),
  ('Monaragala', 500, 2, 5, true, true, 18),
  ('Mullaitivu', 550, 3, 6, true, true, 19),
  ('Nuwara Eliya', 450, 2, 5, true, true, 20),
  ('Polonnaruwa', 450, 2, 5, true, true, 21),
  ('Puttalam', 450, 2, 5, true, true, 22),
  ('Ratnapura', 400, 2, 4, true, true, 23),
  ('Trincomalee', 500, 3, 6, true, true, 24),
  ('Vavuniya', 500, 3, 6, true, true, 25)
on conflict (district) do update set
  fee_lkr = excluded.fee_lkr,
  eta_min_days = excluded.eta_min_days,
  eta_max_days = excluded.eta_max_days,
  is_serviceable = excluded.is_serviceable,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order;

-- Site settings
insert into public.site_settings (key, value, is_public)
values
  ('store_name', to_jsonb('AYAD Scent Lab'::text), true),
  ('support_phone', to_jsonb('+94776756287'::text), true),
  ('whatsapp_number', to_jsonb('+94776756287'::text), true),
  ('free_delivery_threshold_lkr', to_jsonb(5000::int), true),
  ('delivery_fee_default_lkr', to_jsonb(350::int), true),
  ('currency', to_jsonb('LKR'::text), true),
  ('low_stock_threshold', to_jsonb(5::int), true),
  ('social_links', jsonb_build_object(
    'instagram', 'https://instagram.com/example',
    'facebook', 'https://facebook.com/example',
    'tiktok', 'https://tiktok.com/@example'
  ), true),
  ('bank_details', jsonb_build_object(
    'account_name', 'DEMO ACCOUNT',
    'bank_name', 'Demo Bank',
    'branch', 'Colombo',
    'account_number', '0000000000',
    'note', 'Admin should update in production'
  ), false)
on conflict (key) do update set
  value = excluded.value,
  is_public = excluded.is_public;

-- Collections (required slugs)
insert into public.collections (id, slug, name, description, is_active, sort_order)
values
  ('11111111-1111-4111-8111-111111111111', 'oud', 'Oud', 'Deep, luxurious oud blends with rich character.', true, 1),
  ('22222222-2222-4222-8222-222222222222', 'attar-oils', 'Attar Oils', 'Alcohol-free attar oils crafted for lasting wear.', true, 2),
  ('33333333-3333-4333-8333-333333333333', 'spray-perfumes', 'Spray Perfumes', 'Everyday and signature spray perfumes for every mood.', true, 3),
  ('44444444-4444-4444-8444-444444444444', 'musk-amber', 'Musk & Amber', 'Warm musk and amber compositions with soft depth.', true, 4),
  ('55555555-5555-4555-8555-555555555555', 'gift-sets', 'Gift Sets', 'Thoughtful fragrance sets for gifting and discovery.', true, 5)
on conflict (id) do update set
  slug = excluded.slug,
  name = excluded.name,
  description = excluded.description,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order;

-- Notes
insert into public.notes (id, slug, name, is_active)
values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'bergamot', 'Bergamot', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'saffron', 'Saffron', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'rose', 'Rose', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', 'jasmine', 'Jasmine', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 'oud', 'Oud', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'amber', 'Amber', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7', 'white-musk', 'White Musk', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'vanilla', 'Vanilla', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9', 'cedarwood', 'Cedarwood', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa10', 'pink-pepper', 'Pink Pepper', true)
on conflict (slug) do update set
  name = excluded.name,
  is_active = excluded.is_active;

-- Products (Decisions v1 fields)
insert into public.products (
  id, slug, name, short_description, description, gender, product_type, concentration,
  is_active, is_featured, is_trending, trending_rank, units_sold,
  longevity_score, projection_score, sweetness_score, freshness_score,
  longevity_min_hours, longevity_max_hours, occasions, seasons, scent_story,
  seo_title, seo_description
)
values
  (
    '10000000-0000-4000-8000-000000000001', 'oud-royale', 'Oud Royale',
    'Regal oud with saffron and amber.',
    'A regal oud composition blending saffron warmth with deep amber and smooth woods. Designed for evenings and special occasions.',
    'unisex', 'spray', 'edp', true, true, true, 1, 48,
    9, 8, 5, 3, 8, 12,
    array['evening','wedding','date_night','festive']::occasion_type[],
    array['autumn','winter','all_year']::season_type[],
    'A bold opening of saffron settles into rose and oud, finishing with a warm amber trail that lingers through the night.',
    'Oud Royale | AYAD Scent Lab', 'Shop Oud Royale by AYAD Scent Lab in Sri Lanka.'
  ),
  (
    '10000000-0000-4000-8000-000000000002', 'midnight-saffron', 'Midnight Saffron',
    'Bold saffron, rose, and amber.',
    'An intense saffron-led fragrance wrapped in rose, amber, and a soft vanilla trail for a confident signature.',
    'women', 'spray', 'edp', true, true, true, 2, 36,
    8, 7, 6, 3, 7, 10,
    array['evening','party','date_night']::occasion_type[],
    array['autumn','winter']::season_type[],
    'Spiced saffron and floral rose glow over a warm amber-vanilla base for a magnetic evening scent.',
    'Midnight Saffron | AYAD Scent Lab', 'Discover Midnight Saffron by AYAD Scent Lab.'
  ),
  (
    '10000000-0000-4000-8000-000000000003', 'white-musk-attar', 'White Musk Attar',
    'Clean, soft white musk attar.',
    'A clean and comforting white musk attar with gentle floral nuances and lasting softness on skin.',
    'unisex', 'attar', 'attar_oil', true, true, true, 3, 52,
    7, 5, 4, 6, 6, 10,
    array['everyday','office','date_night']::occasion_type[],
    array['all_year']::season_type[],
    'Soft musk and delicate florals create a clean, skin-close aura that feels effortless in any setting.',
    'White Musk Attar | AYAD Scent Lab', 'Pure White Musk Attar from AYAD Scent Lab.'
  ),
  (
    '10000000-0000-4000-8000-000000000004', 'amber-nights', 'Amber Nights',
    'Warm amber, cedarwood, and vanilla.',
    'Warm amber and cedarwood layered with vanilla for a smooth, inviting scent that lingers beautifully.',
    'men', 'spray', 'edp', true, false, false, null, 24,
    8, 6, 6, 2, 7, 11,
    array['evening','everyday','office']::occasion_type[],
    array['autumn','winter','all_year']::season_type[],
    'Golden amber and smooth cedarwood wrapped in vanilla for a refined, comforting warmth.',
    'Amber Nights | AYAD Scent Lab', 'Experience Amber Nights by AYAD Scent Lab.'
  )
on conflict (id) do update set
  slug = excluded.slug,
  name = excluded.name,
  short_description = excluded.short_description,
  description = excluded.description,
  gender = excluded.gender,
  product_type = excluded.product_type,
  concentration = excluded.concentration,
  is_active = excluded.is_active,
  is_featured = excluded.is_featured,
  is_trending = excluded.is_trending,
  trending_rank = excluded.trending_rank,
  units_sold = excluded.units_sold,
  longevity_score = excluded.longevity_score,
  projection_score = excluded.projection_score,
  sweetness_score = excluded.sweetness_score,
  freshness_score = excluded.freshness_score,
  longevity_min_hours = excluded.longevity_min_hours,
  longevity_max_hours = excluded.longevity_max_hours,
  occasions = excluded.occasions,
  seasons = excluded.seasons,
  scent_story = excluded.scent_story,
  seo_title = excluded.seo_title,
  seo_description = excluded.seo_description;

-- Variants (with size_ml; price_from_lkr maintained by trigger)
insert into public.product_variants (id, product_id, label, size_ml, sku, price_lkr, compare_at_lkr, stock, is_active)
values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', '30 ml', 30, 'AYD-OR-30', 6500, 7200, 25, true),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', '50 ml', 50, 'AYD-OR-50', 9500, null, 18, true),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', '30 ml', 30, 'AYD-MS-30', 6200, 6800, 30, true),
  ('20000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', '50 ml', 50, 'AYD-MS-50', 8900, null, 20, true),
  ('20000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000003', '6 ml', 6, 'AYD-WMA-6', 3500, null, 40, true),
  ('20000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000003', '12 ml', 12, 'AYD-WMA-12', 5900, 6400, 22, true),
  ('20000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000004', '30 ml', 30, 'AYD-AN-30', 5800, null, 28, true),
  ('20000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000004', '50 ml', 50, 'AYD-AN-50', 8400, 9000, 15, true)
on conflict (id) do update set
  product_id = excluded.product_id,
  label = excluded.label,
  size_ml = excluded.size_ml,
  sku = excluded.sku,
  price_lkr = excluded.price_lkr,
  compare_at_lkr = excluded.compare_at_lkr,
  stock = excluded.stock,
  is_active = excluded.is_active;

-- Product images (placeholder storage paths)
insert into public.product_images (id, product_id, variant_id, storage_path, alt_text, sort_order, is_primary)
values
  ('30000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', null, 'products/oud-royale/main.jpg', 'Oud Royale bottle', 1, true),
  ('30000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', null, 'products/oud-royale/detail.jpg', 'Oud Royale detail', 2, false),
  ('30000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', null, 'products/midnight-saffron/main.jpg', 'Midnight Saffron bottle', 1, true),
  ('30000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', null, 'products/midnight-saffron/detail.jpg', 'Midnight Saffron detail', 2, false),
  ('30000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000003', null, 'products/white-musk-attar/main.jpg', 'White Musk Attar bottle', 1, true),
  ('30000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000003', null, 'products/white-musk-attar/detail.jpg', 'White Musk Attar detail', 2, false),
  ('30000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000004', null, 'products/amber-nights/main.jpg', 'Amber Nights bottle', 1, true),
  ('30000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000004', null, 'products/amber-nights/detail.jpg', 'Amber Nights detail', 2, false)
on conflict (id) do update set
  product_id = excluded.product_id,
  variant_id = excluded.variant_id,
  storage_path = excluded.storage_path,
  alt_text = excluded.alt_text,
  sort_order = excluded.sort_order,
  is_primary = excluded.is_primary;

-- Product <> collections
insert into public.product_collections (product_id, collection_id)
values
  ('10000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111'), -- oud
  ('10000000-0000-4000-8000-000000000001', '33333333-3333-4333-8333-333333333333'), -- spray-perfumes
  ('10000000-0000-4000-8000-000000000002', '33333333-3333-4333-8333-333333333333'), -- spray-perfumes
  ('10000000-0000-4000-8000-000000000003', '22222222-2222-4222-8222-222222222222'), -- attar-oils
  ('10000000-0000-4000-8000-000000000003', '44444444-4444-4444-8444-444444444444'), -- musk-amber
  ('10000000-0000-4000-8000-000000000004', '33333333-3333-4333-8333-333333333333'), -- spray-perfumes
  ('10000000-0000-4000-8000-000000000004', '44444444-4444-4444-8444-444444444444')  -- musk-amber
on conflict do nothing;

-- Product <> notes with layers (top/heart/base)
insert into public.product_notes (product_id, note_id, layer, intensity)
values
  -- Oud Royale
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'top', 5),
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'heart', 4),
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 'heart', 5),
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'base', 4),
  -- Midnight Saffron
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'top', 5),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'heart', 4),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'base', 4),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'base', 3),
  -- White Musk Attar
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'top', 3),
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', 'heart', 3),
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7', 'base', 5),
  -- Amber Nights
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'top', 3),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'heart', 5),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9', 'base', 4),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'base', 3)
on conflict do nothing;

-- Sample banners (admin-editable; config fallback in app)
insert into public.banners (
  id, title, subtitle, image_path, mobile_image_path, link_url, sort_order, is_active, start_at, end_at, placement
)
values
  ('40000000-0000-4000-8000-000000000001', 'Discover Oud Royale', 'A regal signature for every occasion', 'banners/oud-royale-hero.jpg', 'banners/oud-royale-hero-mobile.jpg', '/product/oud-royale', 1, true, null, null, 'home_hero'),
  ('40000000-0000-4000-8000-000000000002', 'Midnight Saffron', 'Bold warmth, unforgettable trail', 'banners/midnight-saffron-hero.jpg', 'banners/midnight-saffron-hero-mobile.jpg', '/product/midnight-saffron', 2, true, null, null, 'home_hero')
on conflict (id) do update set
  title = excluded.title,
  subtitle = excluded.subtitle,
  image_path = excluded.image_path,
  mobile_image_path = excluded.mobile_image_path,
  link_url = excluded.link_url,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  start_at = excluded.start_at,
  end_at = excluded.end_at,
  placement = excluded.placement;

-- Sample approved reviews (no fabricated aggregates; UI must compute from DB)
insert into public.reviews (id, product_id, customer_name, rating, title, body, status, is_verified, is_featured)
values
  ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Nimal', 5, 'Luxurious and long-lasting', 'Beautiful oud profile with a smooth dry down. Lasts all evening.', 'approved', true, true),
  ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000003', 'Shalini', 5, 'So clean and soft', 'Perfect everyday musk attar. Gentle and comforting.', 'approved', true, true),
  ('50000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'Ahamed', 4, 'Warm and confident', 'Great saffron opening and nice projection for evenings.', 'approved', true, false)
on conflict (id) do update set
  product_id = excluded.product_id,
  customer_name = excluded.customer_name,
  rating = excluded.rating,
  title = excluded.title,
  body = excluded.body,
  status = excluded.status,
  is_verified = excluded.is_verified,
  is_featured = excluded.is_featured;

commit;
