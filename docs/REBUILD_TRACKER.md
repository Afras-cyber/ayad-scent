# AYAD Rebuild Tracker

**Last updated:** 2026-11-23 (session handoff)  
**Purpose:** Continuation/handoff tracker so work can resume tomorrow or after a model/session change.

> **Source of truth:** [docs/AYAD_PROJECT_STRUCTURE.md](AYAD_PROJECT_STRUCTURE.md), [CLAUDE.md](../CLAUDE.md), [AGENTS.md](../AGENTS.md).  
> **Design refs:** Figma link in `CLAUDE.md` and local JPEG exports in [docs/blue-ayad-design-3-jpeg-format/](blue-ayad-design-3-jpeg-format/).  
> **Audit/baseline:** [docs/MIGRATION_REPORT.md](MIGRATION_REPORT.md).

---

## 1) Project context
- **Goal:** Transform the existing Next.js e-commerce app (Legacy Sports, MongoDB/Mongoose) into **AYAD Scent Lab** (`ayadscentlab.com`) on **Supabase** (Postgres/Storage/RLS/Realtime) with a new storefront UI matching Figma/Decisions v1.
- **Key rules (from CLAUDE):** no customer accounts; Track Order by Order ID + phone; COD & Bank Transfer (LKR whole rupees, `Rs 3,490`); island-wide delivery; logo is temporary text component in one file; admin-only auth/staff login; server-side price/stock/total/delivery calculation; RLS on every table; service role key only in server files with `import "server-only"`; config-driven values in `src/config/*`; ask before guessing/risky changes.
- **Fresh start decisions:** no legacy MongoDB data migration, no legacy image migration, legacy API/strategy to be removed and replaced with Supabase features.

## 2) Git / branches / commits
- **Remote:** `origin` = `https://github.com/Afras-cyber/ayad-scent.git`
- **Branches:** `main`, `feat/supabase`, `feat/ayad-rebuild` (current)
- **Recent commits (local):**
  - `e2e60ae` (`feat/ayad-rebuild`) — `feat(db): reset-ready Decisions v1 schema, search RPC, seed, and regenerated types`
  - `b89ae0e` (`feat/ayad-rebuild`) — `docs: add Figma JPEG design exports for storefront reference`
  - `544d88c` (`feat/supabase`, pushed to `origin/feat/supabase`) — `chore: add supabase foundation (schema, rls, functions, seed, clients)`
  - `d1bddda` (`main`, `origin/main`) — `first commit`
- **Push status:** `feat/supabase` pushed. **`feat/ayad-rebuild` is local-only (not pushed yet)** — includes commits `b89ae0e`, `e2e60ae` and this tracker once committed.
- **Working tree:** clean at time of tracker creation except this file (untracked/new) until committed.

## 3) Environment / Supabase (no secrets committed)
- **Supabase project (linked):** ref `jelodbnmtkuttbonhchx` (`NEXT_PUBLIC_SUPABASE_URL=https://jelodbnmtkuttbonhchx.supabase.co`)
- **Local env:** `.env.local` (gitignored) is configured locally with Supabase URL/anon (publishable) key, service role key, DB password, and project ref. **Do not commit secrets.**
- **CLI:** Supabase CLI installed and project linked; commands run with `--remote` and DB password from local env where required.
- **Remote DB state:** **reset and reseeded** on 2026-11-23 (`npx supabase db reset --remote --yes`). Current schema/seed reflect Decisions v1 reset-ready migrations.

## 4) Decisions v1 (implemented in DB/schema where applicable)
- **Routes/IA:** `(public)` → `(storefront)` (route groups don’t change URLs). Canonical routes include `/`, `/shop`, `/collections`, `/collections/[slug]` (`oud`, `attar-oils`, `spray-perfumes`, `musk-amber`, `gift-sets`), `/product/[slug]`, `/search?q=`, `/cart`, `/checkout`, `/order-success/[code]`, `/track-order`, `/guides`, `/guides/[slug]`, `/about`, `/contact`, `/faq`, `/delivery-returns`, `/privacy`, `/terms`. 301 redirects from migration report for old URLs.
- **Trending/badges/budget:** product type/concentration/trending/ranking/units sold, tab logic, badges (Trending/Best Seller/New/Sale), budget buckets in `commerce.config.ts` against `price_from_lkr`.
- **Scent profile:** DB-driven (`product_notes.layer`, scores/hours/occasions/seasons/scent_story, etc.), admin “Scent profile” tab later; hide empty sections/meters.
- **Content sources:** approved reviews only (DB-derived, no fabricated aggregates), scent guides as MDX in `src/content/guides/*.mdx` (seed 3), static typed content in `src/config/content.config.ts`, banners from DB with config fallback, newsletter via Server Action + Turnstile + rate limit.
- **Delivery checker:** `delivery_zones` (district, fee_lkr, eta_min_days, eta_max_days, is_serviceable), client-side lookup with TanStack Query (staleTime 5m), free-delivery threshold logic, defined UI states, remember district in localStorage.
- **Shop/Search:** URL params + shared Zod `searchParamsSchema` (`q, gender, type, notes, size, min, max, availability, sale, collection, sort, page`), OR within / AND across filters, canonical/noindex rules, server-rendered pagination (12/page) with `keepPreviousData`, sort options incl. relevance on search, Postgres FTS + `pg_trgm` via `search_products` RPC, header suggestions (2+ chars, debounce 250ms, 6 products + 3 collections), recent searches in localStorage.
- **Other:** low-stock threshold config (default 5), OOS visible but last, `/product/[slug]` canonical, WhatsApp/notify flows as specified (details to finalize during implementation), cart drawer scope per Figma/components.

## 5) Database/schema (current, reset-ready)
**Migrations in repo (`supabase/migrations/`):**
- `20261123160000_init_ayad_schema.sql` — Decisions v1 schema: extensions (`pgcrypto`, `pg_trgm`), enums (`order_status`, `payment_method`, `payment_status`, `notification_event`, `notification_status`, `review_status`, `admin_role`, `product_type`, `concentration_type`, `note_layer`, `occasion_type`, `season_type`), `order_code_seq` (AYD-10001+), tables (`products`, `product_variants`, `product_images`, `collections`, `product_collections`, `notes`, `product_notes`, `orders`, `order_items`, `order_events`, `payments`, `invoices`, `notification_outbox`, `whatsapp_messages`, `reviews`, `newsletter_subscribers`, `banners`, `delivery_zones`, `site_settings`, `admin_users`), indexes (incl. search/trigram/GIN), updated_at triggers, `sync_product_price_from_lkr` triggers on variants.
- `20261123160100_rls_policies.sql` — RLS enabled on all tables; anon/authenticated read for active catalog/collections/notes links, active+scheduled banners, active delivery zones, public site settings, approved reviews; no anon policies for sensitive tables.
- `20261123160200_order_functions.sql` — `create_order(jsonb)` and `record_payment(jsonb)` (`security definer`, empty `search_path`, execute revoked from anon/authenticated).
- `20261123160300_storage_buckets.sql` — buckets `products`/`banners` (public read policies) and `payment-slips`/`invoices` (private).
- `20261123160500_search_products_rpc.sql` — `search_products(...)` RPC (FTS/trigram, filters/sort/pagination).

**Seed (`supabase/seed.sql`):** 25 delivery zones (fees/ETA/serviceable placeholders), site settings (store/phone/WhatsApp/thresholds/currency/social links, demo non-public bank details), 5 collections, notes, 4 sample products with Decisions v1 fields, variants with `size_ml`, images (placeholder paths), product-collection/note links, banners, approved reviews.

**Verified remote seed counts (after reset):** `collections=5, products=4, variants=8, delivery_zones=25, reviews=3, banners=2, product_notes=15`.

**Supabase client/type artifacts in repo:**
- [src/lib/supabase/browser.ts](../src/lib/supabase/browser.ts)
- [src/lib/supabase/server.ts](../src/lib/supabase/server.ts)
- [src/lib/supabase/admin.ts](../src/lib/supabase/admin.ts) (`import "server-only"`)
- [src/types/database.types.ts](../src/types/database.types.ts) (regenerated from remote after reset)
- [supabase/tests/rls_anon_access.sql](../supabase/tests/rls_anon_access.sql)
- [scripts/migrate/README.md](../scripts/migrate/README.md), [scripts/migrate/fresh_start_check.mjs](../scripts/migrate/fresh_start_check.mjs)

## 6) Work completed
- [x] Legacy app audit → [docs/MIGRATION_REPORT.md](MIGRATION_REPORT.md)
- [x] [CLAUDE.md](../CLAUDE.md) updated with local Figma JPEG/PDF and logo refs
- [x] `feat/supabase` created; Supabase initialized/linked; initial schema/RLS/functions/storage authored, pushed, seed applied; typed clients/types/tests/scripts scaffolded; foundation committed and pushed (`544d88c`)
- [x] `feat/ayad-rebuild` created from `feat/supabase`
- [x] Figma JPEG exports committed (`b89ae0e`)
- [x] **Remote DB reset** with Decisions v1 migrations + `search_products` RPC + updated seed; types regenerated; committed (`e2e60ae`)
- [x] Fresh-start helper check available: `node scripts/migrate/fresh_start_check.mjs --dry-run`

## 7) Pending work (high level)
- [ ] **Dependencies/tooling:** install required packages and resolve pnpm store issue (see blockers); add/align `src/config/*`, Zod env validation, `.env.example`, providers/theme/fonts/layout scaffolding per AYAD structure.
- [ ] **Remove legacy backend:** delete/replace Mongo/Mongoose (`src/lib/db/*`), legacy `src/app/api/*`, S3/Resend/old auth and DB-coupled code; replace with Supabase-backed `src/features/*/queries.ts` and server actions.
- [ ] **Storefront implementation:** restructure routes/layout to `(storefront)` and implement all Decisions v1 pages/components/behaviors (Home, Shop/Collections/Search, Product, Cart/Checkout/Order-success/Track-order, Guides, static pages, menus/drawers/cards/gallery/forms/delivery checker, WhatsApp flows) with server components + TanStack Query + Framer Motion, `next/image`, metadata, JSON-LD, a11y.
- [ ] **Admin compatibility:** keep updated for new schema (defer full UI rebuild; include “Scent profile” fields alignment when admin is addressed).
- [ ] **Validation:** build/typecheck/lint/tests, RLS re-checks, best-effort 1440/390 vs JPEGs, document Lighthouse mobile 90+ and keyboard/screen-reader steps.
- [ ] **Push `feat/ayad-rebuild`** to origin when ready.

## 8) Blockers / issues
- **pnpm dependency install failed (global store corruption on `D:\.pnpm-store\v10`):** `pnpm add @supabase/supabase-js @supabase/ssr server-only` and `pnpm store prune` hit `UNKNOWN ... stat` errors; local-store install conflicted with existing `node_modules` linkage. `package.json`/lockfile were **not** modified. Supabase client files in `src/lib/supabase/*` will not build/run until deps are installed.
  - **Suggested remediation (choose one):** fix/replace pnpm store and run `pnpm add @supabase/supabase-js @supabase/ssr server-only`; or clean/reinstall node_modules with a consistent store dir; or set `pnpm config set store-dir ...` appropriately and reinstall.

## 9) Useful commands
```powershell
# Git
git status
git log --oneline -10

# Supabase (load DB password from .env.local in shell session as needed)
npx supabase db push --remote --yes --password $env:SUPABASE_DB_PASSWORD
npx supabase db reset --remote --yes   # destructive; reapplies migrations + seed
npx supabase db query --remote --yes "select count(*) from public.products;"
npx supabase db query --remote --file supabase/tests/rls_anon_access.sql --yes
npx supabase gen types typescript --remote > src/types/database.types.ts

# App (after deps resolved)
pnpm install
pnpm dev
pnpm build
pnpm lint

# Fresh-start prerequisite check
node scripts/migrate/fresh_start_check.mjs --dry-run
```

## 10) Recommended next session start
1. **Resolve pnpm/deps** and install `@supabase/supabase-js @supabase/ssr server-only` (+ other required deps) so Supabase clients compile.
2. **Scaffold data layer:** create `src/features/*/queries.ts` (catalog/products/variants/images/notes/collections, search via RPC, delivery zones/settings/banners, reviews, orders/track, newsletter) and replace legacy data access incrementally.
3. **Remove legacy backend/routes** (Mongo models, old API routes, legacy integrations) in step with feature/query replacements.
4. **Begin storefront restructure/UI** per Decisions v1 and [docs/blue-ayad-design-3-jpeg-format/](blue-ayad-design-3-jpeg-format/) starting from route group/layout and core pages.
5. Commit in small increments and push `feat/ayad-rebuild` when ready.

## 11) Notes / cautions
- Never commit `.env.local` or secrets (service role key, DB password). Keep `.env.example` updated when env vars change.
- `orders.legacy_code` exists for compatibility; current project is a fresh start with no legacy data migration.
- `search_products` RPC is implemented for core Decisions v1 behavior; note-search integration and edge-case ranking may need refinement alongside UI query mapping.
- RLS/storage policies and `create_order` delivery-fee fallback behavior should be validated/tightened as checkout/admin flows are wired.
- Do not run destructive DB operations without explicit confirmation (remote reset already performed as requested). Use forward migrations for subsequent changes where possible.