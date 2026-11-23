-- Patch: add missing product columns required by seed/app catalog features
begin;

alter table public.products
  add column if not exists featured boolean not null default false,
  add column if not exists concentration text,
  add column if not exists gender text,
  add column if not exists seo_title text,
  add column if not exists seo_description text;

commit;
