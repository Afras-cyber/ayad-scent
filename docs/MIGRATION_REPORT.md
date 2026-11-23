# Migration Audit Report — Existing e-com → AYAD (Supabase)

**Date:** 2026-11-23  
**Scope:** Repository audit only (no application code changed).  
**Sources inspected:** [`package.json`](../package.json), [`src/config/site.ts`](../src/config/site.ts), [`next.config.ts`](../next.config.ts), `src/app/**` routes, `src/lib/**` integrations, `src/lib/db/models/*.ts`, [`README.md`](../README.md), [`PROJECT_STRUTURE.md`](../PROJECT_STRUTURE.md), and target schema in [`docs/AYAD_PROJECT_STRUCTURE.md`](AYAD_PROJECT_STRUCTURE.md) (Section 8).

**Important limitations:** Row counts, live data quality, broken URLs in stored content, and production hosting/runtime configuration are **not observable from the repository**. Where information is unavailable, this report states that explicitly.

---

## 1. STACK

| Area | Current implementation | Evidence |
| --- | --- | --- |
| Frontend framework | Next.js 16.2.4 (App Router), React 19.2.4, TypeScript 5 | [`package.json`](../package.json), `src/app/layout.tsx`, route groups under `src/app/(public)`, `src/app/(admin)`, `src/app/(admin-auth)` |
| Backend / API | Next.js Route Handlers (`src/app/api/**/route.ts`) running in the app server; server-side data access via Mongoose models | Route inventory in `src/app/api/*`; DB connection in [`src/lib/db/mongoose.ts`](../src/lib/db/mongoose.ts) |
| Database | MongoDB with Mongoose 9.x | [`package.json`](../package.json), [`src/lib/db/mongoose.ts`](../src/lib/db/mongoose.ts) (`MONGODB_URI`), models in `src/lib/db/models/*.ts` |
| Auth method | NextAuth v5 (Auth.js beta) with **Credentials** provider; JWT session strategy; admin/staff login at `/admin/login`; role stored in JWT/session (`admin` \| `staff`); active-user check on sign-in | [`src/lib/auth.ts`](../src/lib/auth.ts), [`src/lib/auth.config.ts`](../src/lib/auth.config.ts), `src/app/api/auth/[...nextauth]/route.ts`, [`src/lib/db/models/User.ts`](../src/lib/db/models/User.ts) |
| Hosting | **Not specified in repo** (no Vercel/infra manifests found; README gives generic Next.js deployment guidance) | [`README.md`](../README.md); no `vercel.json`, Dockerfile, or CI deploy config identified during audit |
| Image storage | AWS S3 for uploads/deletes; presigned browser uploads via `POST /api/upload`; optional CloudFront/public S3 URL construction; `next/image` allows remote patterns including `*.amazonaws.com` and `*.cloudfront.net` (also broad wildcard hosts) | [`src/lib/s3.ts`](../src/lib/s3.ts), [`src/app/api/upload/route.ts`](../src/app/api/upload/route.ts), [`next.config.ts`](../next.config.ts) |
| Payment handling | **No online payment gateway integrated in repo.** Business flow is inquiry/negotiation via WhatsApp; orders carry statuses such as `inquiry`, `contacted`, `negotiating`, `confirmed` and monetary fields (`totalAmount`, optional `negotiatedTotal`) but no payment processor, COD/bank-transfer verification workflow, or slip handling found in code | [`src/lib/db/models/Order.ts`](../src/lib/db/models/Order.ts), order APIs, [`PROJECT_STRUTURE.md`](../PROJECT_STRUTURE.md) (legacy design notes) |
| Third-party services | MongoDB, AWS S3 (SDK v3), Resend (transactional email), WhatsApp via configurable number/links (`wa.me`-style integration implied by config/UI naming), NextAuth/Auth.js; UI/data libs (TanStack Query, Zustand, Framer Motion, etc.) | [`package.json`](../package.json), [`src/config/site.ts`](../src/config/site.ts), [`src/lib/resend.ts`](../src/lib/resend.ts), [`src/lib/s3.ts`](../src/lib/s3.ts), [`src/components/home/whatsappOrderTrack.jsx`](../src/components/home/whatsappOrderTrack.jsx) |

**Notable stack deltas vs AYAD target:** MongoDB/Mongoose → Supabase Postgres + RLS; NextAuth credentials/JWT admin auth → NextAuth v5 admin-only on Supabase-backed admin users (per AYAD doc); S3/CloudFront images → Supabase Storage buckets; Resend emails present now but AYAD target emphasizes WhatsApp Cloud API notifications with PDF invoices/receipts and outbox/worker; no customer accounts now or in target.

---

## 2. FEATURES

Assessment key: **KEEP** = concept/value should carry forward; **REDESIGN** = keep capability but rebuild for AYAD domain/schema/UX; **REPLACE** = supersede with AYAD-specified mechanism; **REMOVE** = drop (not needed or out of scope).

### 2.1 Storefront

| Feature | Current state (evidence) | Disposition | Reason |
| --- | --- | --- | --- |
| Home page (hero/brand/testimonials/featured/products/tracking CTA) | `src/app/(public)/page.tsx`, home components (`Hero*`, `FeaturedProducts`, `TestimonialsSection`, `whatsappOrderTrack`, etc.) | **REDESIGN** | Core storefront remains, but AYAD is perfume/attar (not shoes), new IA/visuals (Figma), green theme, config-driven brand/contact, and different catalog/navigation (collections, scent notes). |
| Shop listing | `/shop` (`src/app/(public)/shop/page.tsx`) + `GET /api/products`, filters/colors/sizes APIs | **REDESIGN** | Catalog browsing stays, but must align to AYAD products/variants/collections/notes, LKR pricing rules, and Supabase reads/RLS/public catalog model. |
| Product detail (slug) | `/shop/[slug]` (`src/app/(public)/shop/[slug]/page.tsx`) + `GET /api/products/[id]` (route name suggests id-based handler; verify behavior) | **REDESIGN** | Product pages remain; schema shifts from single product with sizes/colors/stock to `products` + `product_variants` + images/notes/collections; URL strategy must be preserved or redirected for SEO. |
| Wishlist | `/wishlist` page/layout + `src/store/useWishlist.ts` | **KEEP/REDESIGN** (confirm) | Useful UX if desired for launch; not explicitly listed in AYAD core flows—reimplement against new catalog IDs/variants if retained. Mark **question** for product decision. |
| Cart / checkout initiation | `src/store/useCartStore.ts`, `src/components/layout/CartDrawer.tsx` | **REPLACE** | Current flow supports WhatsApp inquiry/order creation; AYAD requires cart + checkout with name/phone/address, COD or bank transfer, server-side `create_order` RPC, idempotency, rate limiting, consent, outbox enqueue. |
| Order tracking | `/track` page/layout + `GET /api/track/[orderNumber]` | **REDESIGN** | AYAD requires Track Order by **Order ID + phone number** with status timeline (`order_events`) and polling; current implementation tracks by order number endpoint—must adapt to new identifiers, auth/rate-limit/privacy model. |
| About page | `/about` | **REDESIGN** | Keep page, replace content/branding for AYAD. |
| Contact page/form | `/contact` + `POST /api/contact` | **REDESIGN** | Keep contact channel, align to AYAD config (WhatsApp/email/phone) and anti-abuse/rate limiting expectations. |
| Newsletter signup | `POST /api/newsletter` | **REDESIGN** | Newsletter concept can remain, but storage moves to `newsletter_subscribers` with server action/RLS posture per AYAD; confirm consent/copy. |
| Testimonials / public reviews display & submission | `TestimonialsSection`, `TestimonialForm`, `GET /api/testimonials`, `POST /api/testimonials/submit` | **REPLACE/REDESIGN** | Current `Testimonial` model (approved/featured, optional product link) differs from AYAD `reviews` (verified, moderation status, tied to delivered orders per default question). Needs new rules/UI. |
| SEO (metadata, sitemap, robots, structured data) | `src/app/robots.ts`, `src/app/sitemap.ts`, `src/lib/seo.ts`, `src/components/seo/*` | **REDESIGN** | Keep strong SEO; regenerate for AYAD domain/routes/products/collections and add redirects from legacy URLs. |
| Theme (dark/light) | `next-themes` dependency/provider | **KEEP** (review) | AYAD target includes next-themes; palette/tokens must follow Figma/green theme and client review. |

### 2.2 Admin

| Feature | Current state (evidence) | Disposition | Reason |
| --- | --- | --- | --- |
| Admin authentication & protected layout | `/admin/login`, NextAuth credentials, admin layout | **REDESIGN** | Keep admin-only access but migrate auth backing store to Supabase `admin_users` (or agreed method), role guard, and remove customer-account assumptions (none today). |
| Dashboard / admin home | `src/app/(admin)/admin/page.tsx`, `DashboardCharts` | **REDESIGN** | Keep management overview, rebuild metrics for AYAD entities (orders, payments, notifications, stock). |
| Products (CRUD/list/edit/new) | `/admin/products`, `/admin/products/new`, `/admin/products/[id]`, APIs `/api/products*`, `ProductForm`, `ProductTable` | **REPLACE/REDESIGN** | Core capability retained but data model changes substantially (variants, images table/storage, collections, notes, SKU/stock per variant). |
| Orders (list/detail/status/notes/invoice) | `/admin/orders`, `/admin/orders/[id]`, APIs `/api/orders/*`, `/api/orders/[id]/invoice`, `OrderManager`, `OrderTable`, `OrderSearchModal` | **REPLACE/REDESIGN** | Orders remain central but must move to AYAD schema (`orders`, `order_items`, `order_events`, `payments`, invoices, outbox/WhatsApp logs), new statuses, COD/bank-transfer verification, and timeline/printing flows. |
| Banners / hero content | `/admin/banners`, `/admin/hero`, banner APIs/components | **REDESIGN** | Keep content management; map to AYAD `banners`/site content patterns and Supabase storage/settings as applicable. |
| Categories | `/admin/categories`, category APIs/components | **REPLACE/REDESIGN** | Shoe categories/brands model does not match AYAD collections/notes; migrate/reshape taxonomy. |
| Brands | `/admin/brands`, brand APIs/components | **REMOVE/REPLACE** | Likely not applicable to AYAD perfume catalog (replace with collections/notes/attributes per target schema) unless business requires brand field—confirm. |
| Staff management | `/admin/staff`, `/api/admin/staff*`, `StaffTable`, `AddStaffForm`, welcome email | **REDESIGN** | Keep role-based staff/admin users; migrate to `admin_users`, adjust password/reset/onboarding flow, and align notifications. |
| Testimonials moderation/management | `/admin/testimonials`, `/api/admin/testimonials*` | **REDESIGN/REPLACE** | Replace with AYAD `reviews` moderation (and eligibility rules) if reviews are in scope. |
| Newsletter admin/send | `/admin/newsletter`, `/admin/newsletter/new`, `/api/admin/newsletter*` | **REDESIGN** | Keep if marketing emails remain; AYAD target prioritizes WhatsApp notifications—confirm channel/priority. |
| Image uploads | `/api/upload` to S3 presigned URLs | **REPLACE** | Move to Supabase Storage buckets (`products`, `banners`, `payment-slips`, `invoices` as applicable) with proper access controls. |
| Reports/settings/stock modules as separate admin areas | **Not found as dedicated routes/modules** (stock is embedded in products/orders workflows) | **REDESIGN/ADD** (per AYAD) | AYAD expects richer order/payment/notification operations and site settings; build per target requirements. |

---

## 3. DATA MODEL

> **Row counts:** Not available (database not accessible from repository). Obtain counts via MongoDB export/query before migration (`Product`, `Order`, `User`, `Category`, `Brand`, `Banner`, `Testimonial`, `Newsletter`, and any other collections present in production).

### 3.1 `User` (`src/lib/db/models/User.ts`, collection implied `users`)

| Field | Type / notes |
| --- | --- |
| `name` | string, required, trimmed |
| `email` | string, required, unique, lowercase |
| `password` | string, optional in schema but required for credential login in practice; `select: false` |
| `role` | enum `admin` \| `staff`, default `staff` |
| `isActive` | boolean, default `true` |
| `phone` | string, optional |
| `avatar` | string, optional |
| `addedBy` | ObjectId ref `User`, optional |
| `lastLogin` | Date, optional |
| `createdAt`, `updatedAt` | timestamps |

**Relations/behavior:** `addedBy -> User`; password hashed in pre-save hook; `comparePassword` via bcrypt.

### 3.2 `Product` (`src/lib/db/models/Product.ts`)

| Field | Type / notes |
| --- | --- |
| `name`, `slug` | required; `slug` unique/lowercase |
| `description`, `shortDescription` | string (`description` marked not required in schema, `shortDescription` required) |
| `categoryId`, `brandId` | ObjectId refs `Category`, `Brand`, required |
| `category`, `brand` | denormalized strings, required |
| `subcategory` | optional string |
| `price` | number, required, >= 0 |
| `discountPrice`, `discountPercent` | optional numbers |
| `images` | string[] (URLs/paths) |
| `sizes` | string[] |
| `colors` | array of `{ name, hex, imageIndex? }` |
| `stock` | number, required, default 0 |
| `isAvailable`, `isFeatured`, `isOnSale` | booleans |
| `tags` | string[] |
| `seoTitle`, `seoDescription` | optional strings |
| `rating`, `reviewCount`, `viewCount`, `clickCount` | numeric metrics |
| timestamps | `createdAt`, `updatedAt` |

**Relations:** `categoryId -> Category`, `brandId -> Brand`. **Indexes:** category/availability/featured/sale/createdAt/text search on name+tags.

### 3.3 `Order` (`src/lib/db/models/Order.ts`)

| Field | Type / notes |
| --- | --- |
| `orderNumber` | string, required, unique; auto-generated as `STK-YYYY-NNNNN` (count-based) in pre-validate hook |
| `customer` | embedded `{ name, phone, email? }` |
| `items[]` | embedded line snapshots: `{ productId, productName, productSlug, selectedSize, selectedColor, price, quantity, image }` |
| `totalAmount` | number, required |
| `negotiatedTotal` | number, optional |
| `status` | enum `inquiry \| contacted \| negotiating \| confirmed \| processing \| shipped \| delivered \| cancelled` (default `inquiry`) |
| `statusHistory[]` | `{ status, updatedBy (ref User), note?, timestamp }` |
| `whatsappSent`, `emailSent` | booleans |
| `notes` | optional string |
| timestamps | `createdAt`, `updatedAt` |

**Relations:** `items[].productId -> Product`, `statusHistory[].updatedBy -> User`. **Indexes:** status, createdAt, status+updatedAt, customer.phone.

### 3.4 `Category` (`src/lib/db/models/Category.ts`)

| Field | Type / notes |
| --- | --- |
| `name`, `slug` | required, unique |
| `description`, `image` | optional |
| `sizes` | string[] |
| `isActive` | boolean, default `true` |
| `order` | number, default 0 |
| timestamps | present |

**Behavior:** post-save / post-findOneAndUpdate hooks set related `Product.isAvailable = false` when deactivated.

### 3.5 `Brand` (`src/lib/db/models/Brand.ts`)

| Field | Type / notes |
| --- | --- |
| `name`, `slug` | required, unique |
| `description`, `logo` | optional |
| `isActive`, `isFeatured` | booleans |
| timestamps | present |

**Behavior:** deactivation cascades to set related products unavailable.

### 3.6 `Banner` (`src/lib/db/models/Banner.ts`)

| Field | Type / notes |
| --- | --- |
| `title` | required |
| `subtitle`, `mobileImage`, `link`, `buttonText`, `startDate`, `endDate`, `backgroundColor`, `textColor` | optional |
| `image` | required |
| `type` | enum `hero \| promo \| sale \| seasonal` |
| `position` | number |
| `isActive` | boolean |
| timestamps | present |

### 3.7 `Testimonial` (`src/lib/db/models/Testimonial.ts`)

| Field | Type / notes |
| --- | --- |
| `customerName` | required |
| `customerAvatar` | optional |
| `rating` | number 1–5, required |
| `review` | required text |
| `productId` | optional ref `Product` |
| `productName` | optional denormalized string |
| `isApproved`, `isFeatured` | booleans |
| timestamps | present |

### 3.8 `Newsletter` (`src/lib/db/models/Newsletter.ts`)

| Field | Type / notes |
| --- | --- |
| `email` | required, unique, lowercase/trimmed |
| `isActive` | boolean |
| timestamps | present |

### 3.9 Other collections/tables

- **None identified in `src/lib/db/models`**. If production uses additional collections, include them in export and append to this mapping.

---

## 4. MAPPING (Old → New Supabase schema, AYAD Section 8)

Target tables (from AYAD doc): `products`, `product_variants`, `product_images`, `collections`, `product_collections`, `notes`, `product_notes`, `orders`, `order_items`, `order_events`, `payments`, `invoices`, `notification_outbox`, `whatsapp_messages`, `reviews`, `newsletter_subscribers`, `banners`, `delivery_zones`, `site_settings`, `admin_users`.

| Old model/field(s) | New target | Mapping / transformation notes |
| --- | --- | --- |
| `User.*` (admin/staff) | `admin_users` | **KEEP identity data, RESET credentials path.** Map `email`, `name` (if target supports/displayed elsewhere), role (`admin`/`staff`) and active state as applicable. **Passwords cannot be migrated** (bcrypt hashes tied to current auth flow/credential handling); plan forced reset/invite. Preserve audit fields (`createdAt`, `lastLogin`) only if target schema includes equivalents. |
| `Product.name/slug/description/shortDescription/isFeatured/rating/reviewCount` (and SEO fields) | `products` (+ related tables) | **REDESIGN split.** Create one `products` row per current product with slug, name, descriptions, active/featured flags. Map shoe-domain fields to perfume-domain attributes carefully (`gender`, scent notes, etc. may need defaults/manual curation). `rating_avg`/`rating_count` in target differ from current fields—recompute or reset per review migration strategy. SEO title/description have **no explicit home** in Section 8 schema shown; store in config/content strategy or extend schema (decision needed). |
| `Product.price/discountPrice/discountPercent/stock/sizes/colors` | `product_variants`, `product_images`, possibly `products` | **Major transformation.** Current model stores a single base price/stock and variant-like attributes (`sizes`, `colors`) on one document. AYAD expects per-variant SKU/label/price/compare-at/stock. Requires rule-based expansion (e.g. size/color combinations) or manual curation; image-to-variant linkage (`colors[].imageIndex`) must be rebuilt into `product_images` ordering/association. |
| `Product.images[]` | `product_images` + Supabase Storage (`products` bucket) | **Transform & rehost.** Download/copy assets from S3/URLs to Supabase Storage, create image rows with sort order/alt text; update references. Broken/missing URLs are a migration risk. |
| `Category.*` | `collections` / `product_collections` (and possibly `notes`/`product_notes`) | **REPLACE taxonomy.** Shoe categories/sizes do not map 1:1 to AYAD collections (Oud, Attar Oils, etc.) or scent notes. Requires business mapping table; `Category.sizes` has no direct home. |
| `Brand.*` | (no direct equivalent) | **No home / likely REMOVE.** If brand must be retained, add attribute or extend schema; otherwise drop after stakeholder confirmation. |
| `Banner.*` | `banners` | **REDESIGN/transform.** Field names/semantics differ; map titles/subtitles/images/links/active windows/ordering to target banner structure and move images to Supabase `banners` bucket. |
| `Testimonial.*` | `reviews` | **REPLACE with constraints.** AYAD reviews default to moderation and (per open question default) may require delivered-order linkage/verification; current testimonials are generic approved/featured entries with optional product refs. Transform statuses/flags and decide handling for non-verifiable legacy testimonials. |
| `Newsletter.*` | `newsletter_subscribers` | **Near-direct map.** `email`, active/subscription state, timestamps as supported. Deduplicate and normalize emails. |
| `Order.orderNumber` | `orders.code` | **Transform format.** `STK-YYYY-NNNNN` → `AYD-*` (sequence-driven in target). Preserve old number in a migration mapping table/audit note for customer support and redirect/lookups if needed (**no home in shown schema** unless added). |
| `Order.customer.name/phone/email` | `orders.customer_name`, `orders.phone_e164`, `orders.email` | **Transform phones.** Normalize to E.164 (`+94...`) using consistent rules; handle local formats (`07x`, spaces, dashes), invalid numbers, and duplicates. Address fields required in target (`address_line`, `city`, `district`) are **missing in current model** → must be collected/defaulted during migration or orders flagged incomplete. |
| `Order.items[]` snapshots | `order_items` | **Transform shape.** Map product/variant labels, unit prices, quantities; current items reference `selectedSize`/`selectedColor` and `productId/slug` but target expects `variant_id`/variant label snapshots consistent with new catalog. Historical items may not map cleanly if catalog is restructured—preserve textual snapshots. |
| `Order.totalAmount/negotiatedTotal` | `orders.subtotal_lkr`, `orders.delivery_fee_lkr`, `orders.total_lkr` | **Transform totals.** Current app has no explicit delivery fee/tax breakdown; negotiated totals exist. Define deterministic recalculation/snapshot rules; store whole LKR integers as required. |
| `Order.status` | `orders.status` (`order_status` enum) | **Transform enum values.** Old: `inquiry, contacted, negotiating, confirmed, processing, shipped, delivered, cancelled`. New: `pending, confirmed, packed, dispatched, delivered, cancelled, returned`. Needs explicit mapping table and business review (e.g. `inquiry/contacted/negotiating` → `pending` or custom handling; `processing` → `confirmed/packed`; `shipped` → `dispatched`; no `returned` today). |
| `Order.statusHistory[]` | `order_events` | **Transform.** Map statuses/timestamps/notes; `updatedBy` references old `User` IDs—remap to migrated admin users or store actor metadata if schema allows. |
| `Order.whatsappSent/emailSent`, notes | `notification_outbox`, `whatsapp_messages`, `orders.notes` | **Partial/no direct home.** Booleans are not equivalent to outbox/message logs; target tracks event queue and provider message statuses. Migrate notes to `orders.notes`; do not fabricate message history—optionally seed skipped/legacy records for audit only if useful. |
| (none) payments/slips/COD-bank verification | `payments` | **No source data in schema.** Current app lacks structured payment records/slips; all historical "paid" state may be implicit in status/notes and cannot be reliably backfilled without business input. |
| (none) invoices/receipts PDFs | `invoices` (+ `invoices` bucket) | **No source data.** Current has invoice route/PDF capability in codebase but persisted invoice records/files not modeled in MongoDB; regenerate or mark unavailable per order. |
| (none) delivery zones/fees, site runtime settings | `delivery_zones`, `site_settings` | **No source data.** Currently configured in code/env (`src/config/site.ts`, env vars) rather than DB tables; seed new tables from agreed business rules. |
| Product `viewCount/clickCount/tags/subcategory/isOnSale` and similar analytics/merchandising fields | (various / none explicit) | **No direct home or redesign needed.** Decide whether to drop, store in analytics, or extend target schema. |
| `Category` deactivation side effects, `Brand` deactivation side effects | RLS/DB/application logic in new system | **Behavioral transformation.** Replace Mongoose hooks with explicit application/RPC/trigger logic consistent with Supabase design. |

### Fields with no clear home (needs decision/extension)

- `Product.seoTitle`, `Product.seoDescription`
- `Product.subcategory`, `Product.tags`, `Product.viewCount`, `Product.clickCount`, `Product.isOnSale`
- `Category.sizes`, category `order` semantics vs collections
- `Brand.*` (entire concept)
- `Order.negotiatedTotal` as a distinct concept (vs recalculated totals/payment records)
- Legacy `orderNumber` (`STK-*`) preservation for support/redirects
- `statusHistory.updatedBy` actor mapping details

### Data quality problems to assess during export (unknown until DB inspected)

- Duplicate or invalid `User.email`, `Newsletter.email`, `Category/Brand/Product` slugs
- Missing/blank slugs or non-URL-safe slugs
- Products with missing `categoryId/brandId`, orphaned references, or inconsistent denormalized `category/brand` strings
- Broken or inaccessible image URLs (S3 objects deleted, external hotlinks, mixed URL formats)
- Phone numbers in non-normalizable formats (required for `phone_e164` and Track Order by ID+phone)
- Orders missing customer email/phone, inconsistent `statusHistory`, count-based order-number collisions/gaps, or items referencing deleted products
- Prices stored as floats/decimals vs whole LKR integers; negative/zero anomalies
- Testimonials/reviews without verifiable order linkage (relevant to AYAD review rules)

---

## 5. AUTH

| Topic | Current state | Migration plan (recommended) |
| --- | --- | --- |
| Admin user storage | MongoDB `users` collection via Mongoose model `User` (`role`: `admin`/`staff`, `isActive`, profile fields, timestamps) | Export admin/staff users and import into Supabase `admin_users` (per AYAD target) with role/status mapping and unique email constraint. Exclude non-admin concepts (none exist). |
| Password hashing | `bcryptjs` with cost factor **12** in `UserSchema.pre('save')`; comparison via `bcrypt.compare` in `comparePassword`; credentials verified in NextAuth `authorize` | **Do not attempt in-place hash reuse unless target auth mechanism is explicitly compatible.** AYAD plan anticipates admin-only auth; safest path is **forced password reset / invite flow** for all migrated admins and staff. |
| Session/auth runtime | NextAuth v5 JWT sessions; role/id injected into token and session callbacks | Rebuild admin auth against AYAD architecture (NextAuth v5 + Supabase-backed admin users/service-role server access) with server-only credential checks and role guards. |
| Account states | `isActive` gates login (`User.findOne({ email, isActive: true })`); `lastLogin` updated on sign-in | Preserve active/disabled semantics; require password reset before first login on new system. |

**Operational steps:** inventory active admins/staff, communicate cutover/reset window, invalidate old sessions/secrets, and verify least-privilege roles after migration.

---

## 6. URLS (existing public URLs)

> Inventory based on App Router pages/layouts in the repository. Dynamic routes generate many concrete URLs from data (slugs, order numbers) that must be exported from the database.

| URL / pattern | Type | Notes for 301/SEO |
| --- | --- | --- |
| `/` | Public page | Preserve or redirect to AYAD home. |
| `/shop` | Public page | Preserve intent (catalog) but likely redesign/redirect to AYAD shop/collections structure. |
| `/shop/[slug]` | Public dynamic (product detail) | **High SEO value.** Export all product slugs; map each to new product/collection/variant URL or return best-match 301; handle removed products with 410/redirect strategy. |
| `/about` | Public page | Redirect to AYAD about page if slug/path changes. |
| `/contact` | Public page | Preserve or redirect. |
| `/track` | Public page | AYAD tracking flow differs (Order ID + phone). Keep `/track-order`/equivalent UX and 301 `/track` → new path if renamed. |
| `/wishlist` | Public page | Only redirect if feature retained and path changes; otherwise consider deprecation plan. |
| `/admin/login` | Admin entry (publicly reachable page) | Not a customer SEO URL, but update bookmarks/links; ensure noindex. |
| `/admin/**` | Protected admin routes (see route inventory) | No SEO redirects needed; ensure access controls in new app. |
| `/sitemap.xml`, `/robots.txt` | Generated metadata routes (`src/app/sitemap.ts`, `src/app/robots.ts`) | Regenerate for `ayadscentlab.com`; remove legacy-only URLs. |

**Also audit (from data/CMS/content, not in repo):** any blog/content URLs, campaign landing pages, externally indexed filter/query URLs, and image/file URLs embedded in product descriptions or banners.

---

## 7. RISKS, RECOMMENDED MIGRATION ORDER, AND ROLLBACK IDEAS

### 7.1 Key risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Domain/model mismatch (shoes/bags vs perfume/attar; variants/notes/collections) | Incorrect catalog, broken purchase flow | Build explicit mapping tables (category/brand → collections/notes), manually curate variant expansion, and validate with stakeholders on samples. |
| No DB export/row counts in repo | Unknown scope, hidden edge cases | Freeze a production snapshot/export early; run profiling queries and counts before final mapping. |
| Customer identity/address gaps | Cannot satisfy AYAD checkout/tracking requirements from old orders alone | Preserve historical orders as legacy records where possible; collect missing address/district data only when available; define support playbook. |
| Phone normalization failures | Track-order failures, WhatsApp delivery issues | Use `libphonenumber-js`-based normalization to E.164 (+94), quarantine/flag invalid numbers, and test with real samples. |
| Order number/status/timeline translation errors | Customer confusion, support burden, analytics errors | Deterministic status map, preserve legacy order number mapping, migrate `statusHistory` to `order_events` with review. |
| Image migration (S3/remote URLs → Supabase Storage) | Missing/broken product/banner assets | Inventory all URLs, verify object accessibility, checksums/counts, and staged rehost with fallback placeholders. |
| Payment/invoice history gaps | Loss of financial/audit context | Reconstruct from notes/statuses where possible; otherwise mark as unavailable and define forward-only payment/invoice generation. |
| Auth migration (bcrypt/NextAuth → new admin auth) | Admin lockout | Forced password resets/invites, parallel admin verification, and break-glass owner account procedure. |
| SEO regression from URL/structure changes | Traffic/ranking loss | Complete slug export, 301 redirect map, updated sitemap/robots/canonicals, and post-launch crawl monitoring. |
| WhatsApp/notification compliance and setup lead time (AYAD target) | Delayed launch or failed notifications | Start Meta/WABA/template/number verification early (per AYAD roadmap); decouple core order creation from delivery via outbox. |
| In-flight orders during cutover | Duplicate/missed orders or inconsistent state | Define maintenance window, read-only freeze or dual-write policy (if any), and clear cutover checklist. |

### 7.2 Recommended migration order

1. **Discovery & freeze inputs:** obtain DB export/snapshots, media URL inventory, DNS/domain/access ownership, and stakeholder answers to open questions (below). Finalize status/taxonomy mapping tables.
2. **Target foundation:** provision Supabase/Vercel/env/CI, implement AYAD schema/RLS/storage buckets, config files, and generated types (aligned with AYAD roadmap Phase 0).
3. **Reference/config data:** seed `delivery_zones`, `site_settings`, banners/content, and create migrated `admin_users` with forced-reset onboarding (no customer accounts).
4. **Catalog migration:** transform/migrate categories/brands → collections/notes, products → `products`/`product_variants`/`product_images`, and rehost media to Supabase Storage; validate counts, slugs, prices, stock, and image integrity.
5. **Customer-facing transactional data:** migrate newsletters/testimonials-to-reviews (per policy), then migrate historical orders/order items/order events with phone normalization, status/totals mapping, and legacy-ID crosswalk.
6. **Integrations & flows:** implement `create_order` RPC, Track Order, admin order/payment operations, WhatsApp outbox/worker/PDFs (AYAD Phase 3B), and redirect map.
7. **UAT & cutover:** parallel run/UAT on staging with real samples, SEO redirect tests, admin password resets, DNS cutover, and monitoring.
8. **Post-cutover:** verify orders/notifications, crawl/index health, and decommission legacy resources after rollback window.

### 7.3 Rollback ideas

- **Pre-cutover:** keep legacy system and database untouched/read-only snapshots; all migration runs reversible in staging.
- **DNS/application rollback:** retain ability to repoint domain/traffic to legacy frontend/API during an agreed window if critical defects appear.
- **Data rollback:** migration scripts should be idempotent where possible and write to fresh Supabase project/schema or versioned imports; keep source MongoDB backups and transformed export artifacts.
- **Auth rollback:** preserve legacy admin credentials until new admin access is verified; maintain break-glass admin.
- **Media rollback:** do not delete S3/source assets until post-migration verification and retention period expire.
- **Order cutover safety:** if orders are taken during migration window, define a reconciliation script or temporary freeze to avoid split-brain records.

---

## 8. QUESTIONS FOR ME

1. **Scope/priority:** Should this migration target full feature parity with the current store first, or implement the AYAD roadmap phases strictly (some current features like wishlist, brands, newsletter sending may be deferred/removed)?
2. **Brand/taxonomy mapping:** How should existing shoe `Category` and `Brand` data map to AYAD `collections` and `notes` (and do you need to retain brand names anywhere)?
3. **Product variants:** Current products store `sizes`, `colors`, one `stock`, and one `price`. How should these be converted into AYAD `product_variants` (size-based, volume-based like 12ml/50ml, color not applicable, or manual recuration)?
4. **Legacy catalog domain:** Will existing shoe/bag products be migrated at all, or will AYAD launch with a new perfume catalog (making catalog migration mostly a structural exercise)?
5. **Historical orders:** Must all historical `STK-*` orders appear in the new admin/track-order system? If yes, how should we handle missing address/district, negotiated totals, and old statuses that do not map cleanly to the new enum?
6. **Track Order identity:** AYAD requires **Order ID + phone number**. Can we backfill/verify phone numbers for all legacy orders and expose a legacy-order lookup if customers only know the old number?
7. **Reviews/testimonials:** Should existing testimonials be migrated into `reviews`? If so, under what moderation/verification rules (AYAD default expects stronger verification than current testimonials)?
8. **Admin users:** Confirm the desired admin login method and role model for AYAD (email+password vs other), and who should receive forced-reset/invite emails at cutover.
9. **Payments & invoices:** Are there offline records (bank slips, COD confirmations, issued invoices) outside this system that must be imported into `payments`/`invoices`?
10. **WhatsApp setup:** Will you use the same business number for click-to-chat and WhatsApp Cloud API (coexistence) or a separate API number? Which events must be live at launch (AYAD default: order placed, payment received)?
11. **Images/media:** Can you provide access to the current S3 bucket (or a full media export) and confirm whether any product/banner images are hosted outside S3?
12. **SEO/redirect ownership:** Provide (or approve generation of) a full export of live/indexed URLs and product slugs so we can produce an exact 301 redirect map for `ayadscentlab.com` cutover.
13. **Operational data needed:** Please provide database counts/exports for products, orders, users, categories, brands, banners, testimonials, and newsletter subscribers, plus any known data quality issues.

---

*End of audit report. Awaiting answers to Section 8 before making migration-implementation changes.*