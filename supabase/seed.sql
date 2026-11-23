-- AYAD Scent Lab seed data (fresh start)
-- Aligned to deployed schema in supabase/migrations.
begin;

-- Delivery zones (Sri Lanka districts) - sample fees in whole LKR
insert into public.delivery_zones (district, fee_lkr, is_active)
values
  ('Ampara', 500, true),
  ('Anuradhapura', 450, true),
  ('Badulla', 450, true),
  ('Batticaloa', 500, true),
  ('Colombo', 300, true),
  ('Galle', 350, true),
  ('Gampaha', 300, true),
  ('Hambantota', 450, true),
  ('Jaffna', 550, true),
  ('Kalutara', 300, true),
  ('Kandy', 400, true),
  ('Kegalle', 400, true),
  ('Kilinochchi', 550, true),
  ('Kurunegala', 400, true),
  ('Mannar', 550, true),
  ('Matale', 400, true),
  ('Matara', 400, true),
  ('Monaragala', 500, true),
  ('Mullaitivu', 550, true),
  ('Nuwara Eliya', 450, true),
  ('Polonnaruwa', 450, true),
  ('Puttalam', 450, true),
  ('Ratnapura', 400, true),
  ('Trincomalee', 500, true),
  ('Vavuniya', 500, true)
on conflict (district) do update set
  fee_lkr = excluded.fee_lkr,
  is_active = excluded.is_active;

-- Site settings (public-safe demo values; secrets/config managed elsewhere)
insert into public.site_settings (key, value, is_public)
values
  ('store_name', to_jsonb('AYAD Scent Lab'::text), true),
  ('support_phone', to_jsonb('+94776756287'::text), true),
  ('whatsapp_number', to_jsonb('+94776756287'::text), true),
  ('free_delivery_threshold_lkr', to_jsonb(5000::int), true),
  ('delivery_fee_default_lkr', to_jsonb(350::int), true),
  ('currency', to_jsonb('LKR'::text), true),
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

-- Collections
insert into public.collections (id, slug, name, description, is_active, sort_order)
values
  ('11111111-1111-4111-8111-111111111111', 'signature-collection', 'Signature Collection', 'Timeless bestsellers crafted for everyday luxury.', true, 1),
  ('22222222-2222-4222-8222-222222222222', 'oud-collection', 'Oud Collection', 'Rich oud blends with depth and warmth.', true, 2),
  ('33333333-3333-4333-8333-333333333333', 'fresh-musk', 'Fresh & Musk', 'Clean, soft, and effortlessly wearable scents.', true, 3)
on conflict (id) do update set
  slug = excluded.slug,
  name = excluded.name,
  description = excluded.description,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order;

-- Notes
insert into public.notes (id, slug, name, note_type, is_active)
values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'bergamot', 'Bergamot', 'top', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 'saffron', 'Saffron', 'top', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 'rose', 'Rose', 'middle', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', 'jasmine', 'Jasmine', 'middle', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 'oud', 'Oud', 'base', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 'amber', 'Amber', 'base', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7', 'white-musk', 'White Musk', 'base', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 'vanilla', 'Vanilla', 'base', true),
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9', 'cedarwood', 'Cedarwood', 'base', true)
on conflict (slug) do update set
  name = excluded.name,
  note_type = excluded.note_type,
  is_active = excluded.is_active;

-- Products
insert into public.products (
  id, slug, name, description, short_description, gender, is_active, is_featured,
  featured, concentration, seo_title, seo_description
)
values
  ('10000000-0000-4000-8000-000000000001', 'oud-royale', 'Oud Royale', 'A regal oud composition blending saffron warmth with deep amber and smooth woods. Designed for evenings and special occasions.', 'Regal oud with saffron and amber.', 'unisex', true, true, true, 'Eau de Parfum', 'Oud Royale | AYAD Scent Lab', 'Shop Oud Royale by AYAD Scent Lab in Sri Lanka.'),
  ('10000000-0000-4000-8000-000000000002', 'midnight-saffron', 'Midnight Saffron', 'An intense saffron-led fragrance wrapped in rose, amber, and a soft vanilla trail for a confident signature.', 'Bold saffron, rose, and amber.', 'unisex', true, true, true, 'Eau de Parfum', 'Midnight Saffron | AYAD Scent Lab', 'Discover Midnight Saffron by AYAD Scent Lab.'),
  ('10000000-0000-4000-8000-000000000003', 'white-musk-attar', 'White Musk Attar', 'A clean and comforting white musk attar with gentle floral nuances and lasting softness on skin.', 'Clean, soft white musk attar.', 'unisex', true, true, true, 'Attar', 'White Musk Attar | AYAD Scent Lab', 'Pure White Musk Attar from AYAD Scent Lab.'),
  ('10000000-0000-4000-8000-000000000004', 'amber-nights', 'Amber Nights', 'Warm amber and cedarwood layered with vanilla for a smooth, inviting scent that lingers beautifully.', 'Warm amber, cedarwood, and vanilla.', 'unisex', true, false, false, 'Eau de Parfum', 'Amber Nights | AYAD Scent Lab', 'Experience Amber Nights by AYAD Scent Lab.')
on conflict (id) do update set
  slug = excluded.slug,
  name = excluded.name,
  description = excluded.description,
  short_description = excluded.short_description,
  gender = excluded.gender,
  is_active = excluded.is_active,
  is_featured = excluded.is_featured,
  featured = excluded.featured,
  concentration = excluded.concentration,
  seo_title = excluded.seo_title,
  seo_description = excluded.seo_description;

-- Variants (whole LKR) - schema uses label/sku/price_lkr/stock
insert into public.product_variants (id, product_id, label, sku, price_lkr, compare_at_lkr, stock, is_active)
values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', '30 ml', 'AYD-OR-30', 6500, 7200, 25, true),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', '50 ml', 'AYD-OR-50', 9500, null, 18, true),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', '30 ml', 'AYD-MS-30', 6200, 6800, 30, true),
  ('20000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', '50 ml', 'AYD-MS-50', 8900, null, 20, true),
  ('20000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000003', '6 ml', 'AYD-WMA-6', 3500, null, 40, true),
  ('20000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000003', '12 ml', 'AYD-WMA-12', 5900, 6400, 22, true),
  ('20000000-0000-4000-8000-000000000007', '10000000-0000-4000-8000-000000000004', '30 ml', 'AYD-AN-30', 5800, null, 28, true),
  ('20000000-0000-4000-8000-000000000008', '10000000-0000-4000-8000-000000000004', '50 ml', 'AYD-AN-50', 8400, 9000, 15, true)
on conflict (id) do update set
  product_id = excluded.product_id,
  label = excluded.label,
  sku = excluded.sku,
  price_lkr = excluded.price_lkr,
  compare_at_lkr = excluded.compare_at_lkr,
  stock = excluded.stock,
  is_active = excluded.is_active;

-- Product images (placeholder storage paths; no binary image migration)
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
  ('10000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111'),
  ('10000000-0000-4000-8000-000000000001', '22222222-2222-4222-8222-222222222222'),
  ('10000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111'),
  ('10000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333'),
  ('10000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111')
on conflict do nothing;

-- Product <> notes (intensity 1-5 as simple ordering/strength)
insert into public.product_notes (product_id, note_id, intensity)
values
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 5), -- saffron
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 4), -- rose
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa5', 5), -- oud
  ('10000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 4), -- amber
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2', 5),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3', 4),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 4),
  ('10000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 3),
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 3),
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa4', 3),
  ('10000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa7', 5),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 3),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa6', 5),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa9', 4),
  ('10000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa8', 3)
on conflict do nothing;

-- Sample banners (placeholder storage paths)
insert into public.banners (
  id, title, subtitle, image_path, mobile_image_path, link_url, sort_order, is_active, start_at, end_at, placement
)
values
  ('40000000-0000-4000-8000-000000000001', 'Discover Oud Royale', 'A regal signature for every occasion', 'banners/oud-royale-hero.jpg', 'banners/oud-royale-hero-mobile.jpg', '/shop/oud-royale', 1, true, null, null, 'home_hero'),
  ('40000000-0000-4000-8000-000000000002', 'Midnight Saffron', 'Bold warmth, unforgettable trail', 'banners/midnight-saffron-hero.jpg', 'banners/midnight-saffron-hero-mobile.jpg', '/shop/midnight-saffron', 2, true, null, null, 'home_hero')
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

-- Sample approved reviews (for anon read policy verification/demo)
insert into public.reviews (id, product_id, customer_name, rating, title, body, status, is_verified)
values
  ('50000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Nimal', 5, 'Luxurious and long-lasting', 'Beautiful oud profile with a smooth dry down. Lasts all evening.', 'approved', true),
  ('50000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000003', 'Shalini', 5, 'So clean and soft', 'Perfect everyday musk attar. Gentle and comforting.', 'approved', true)
on conflict (id) do update set
  product_id = excluded.product_id,
  customer_name = excluded.customer_name,
  rating = excluded.rating,
  title = excluded.title,
  body = excluded.body,
  status = excluded.status,
  is_verified = excluded.is_verified;

commit;
