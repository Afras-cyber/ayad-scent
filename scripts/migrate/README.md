# AYAD Migration Scripts (Fresh Start)

This project is starting fresh on Supabase for AYAD Scent Lab.

- **No legacy MongoDB data migration** is performed.
- **No legacy image migration** is performed (use placeholder/storage paths in seed or upload new assets to Supabase Storage).

## Item 9 status (adjusted)
The original request asked for idempotent scripts to migrate from the old database with `--dry-run`, row counts, logs, image upload, phone normalization, status mapping, and `legacy_code` preservation. Because the user confirmed a fresh Supabase start with no MongoDB source and no image migration, those legacy-source steps are **N/A**.

If a legacy source is provided later, add scripts here that:
- accept `--dry-run` and `--apply`
- are idempotent (upserts / conflict handling)
- log skipped/fixed rows and before/after counts
- normalize phones to `+94` E.164
- map legacy statuses to `order_status` enum values
- preserve old order numbers in `orders.legacy_code`
- upload images to Supabase Storage buckets (`products`, `banners`, `payment-slips`, `invoices`)

## Available helpers
- `fresh_start_check.mjs`: validates that required Supabase env vars are present and prints a fresh-start checklist. Supports `--dry-run` (default behavior; read-only checks only).
