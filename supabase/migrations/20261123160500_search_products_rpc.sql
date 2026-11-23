-- Search RPC for /shop and /search (Decisions v1)
-- Uses FTS (search_vector) + trigram similarity on product name and note names.
create or replace function public.search_products(
  q text default null,
  p_gender text[] default null,
  p_type text[] default null,
  p_note_slugs text[] default null,
  p_sizes integer[] default null,
  p_min integer default null,
  p_max integer default null,
  p_availability text default null, -- 'in-stock' to hide OOS
  p_sale boolean default false,
  p_collection text default null,
  p_sort text default 'featured',
  p_page integer default 1,
  p_page_size integer default 12
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_q text := nullif(trim(coalesce(q,'')), '');
  v_page integer := greatest(coalesce(p_page,1), 1);
  v_size integer := least(greatest(coalesce(p_page_size,12), 1), 48);
  v_offset integer := (v_page - 1) * v_size;
  v_ts tsquery;
  v_total bigint;
  v_rows jsonb;
begin
  if v_q is not null then
    v_ts := websearch_to_tsquery('simple', v_q);
  end if;

  with base as (
    select
      p.id,
      p.slug,
      p.name,
      p.short_description,
      p.gender,
      p.product_type,
      p.concentration,
      p.is_featured,
      p.is_trending,
      p.trending_rank,
      p.price_from_lkr,
      p.units_sold,
      p.rating_avg,
      p.rating_count,
      p.created_at,
      p.search_vector,
      -- stock/discount aggregates
      coalesce(sum(v.stock) filter (where v.is_active), 0) as total_stock,
      bool_or(v.is_active and v.compare_at_lkr is not null and v.compare_at_lkr > v.price_lkr) as has_sale,
      -- relevance
      case
        when v_q is null then 0::real
        else
          coalesce(ts_rank(p.search_vector, v_ts), 0) * 2
          + greatest(similarity(p.name, v_q), 0)
      end as relevance
    from public.products p
    left join public.product_variants v on v.product_id = p.id
    where p.is_active = true
      and (
        v_q is null
        or (v_ts is not null and p.search_vector @@ v_ts)
        or similarity(p.name, v_q) > 0.1
        or exists (
          select 1
          from public.product_notes pn
          join public.notes n on n.id = pn.note_id
          where pn.product_id = p.id and n.is_active = true and similarity(n.name, v_q) > 0.2
        )
      )
      and (p_gender is null or cardinality(p_gender)=0 or p.gender = any(p_gender))
      and (p_type is null or cardinality(p_type)=0 or p.product_type::text = any(p_type))
      and (p_min is null or p.price_from_lkr >= p_min)
      and (p_max is null or p.price_from_lkr <= p_max)
      and (
        p_collection is null or exists (
          select 1
          from public.product_collections pc
          join public.collections c on c.id = pc.collection_id
          where pc.product_id = p.id and c.slug = p_collection and c.is_active = true
        )
      )
      and (
        p_note_slugs is null or cardinality(p_note_slugs)=0 or exists (
          select 1
          from public.product_notes pn
          join public.notes n on n.id = pn.note_id
          where pn.product_id = p.id and n.slug = any(p_note_slugs)
        )
      )
      and (
        p_sizes is null or cardinality(p_sizes)=0 or exists (
          select 1 from public.product_variants vv
          where vv.product_id = p.id and vv.is_active = true and vv.size_ml = any(p_sizes)
        )
      )
    group by p.id
  ),
  filtered as (
    select *
    from base
    where (not p_sale or coalesce(has_sale,false))
      and (coalesce(p_availability,'') <> 'in-stock' or total_stock > 0)
  ),
  counted as (
    select count(*)::bigint as total from filtered
  ),
  paged as (
    select f.*
    from filtered f
    order by
      case when coalesce(p_availability,'') <> 'in-stock' then (case when f.total_stock <= 0 then 1 else 0 end) else 0 end asc,
      case when p_sort = 'relevance' and v_q is not null then f.relevance end desc nulls last,
      case when p_sort in ('featured','relevance') then f.is_featured end desc nulls last,
      case when p_sort in ('featured','relevance') then f.trending_rank end asc nulls last,
      case when p_sort = 'newest' then f.created_at end desc nulls last,
      case when p_sort = 'price-asc' then f.price_from_lkr end asc nulls last,
      case when p_sort = 'price-desc' then f.price_from_lkr end desc nulls last,
      case when p_sort = 'best-selling' then f.units_sold end desc nulls last,
      case when p_sort = 'rating' then f.rating_avg end desc nulls last,
      case when p_sort = 'rating' then f.rating_count end desc nulls last,
      f.created_at desc
    limit v_size offset v_offset
  )
  select c.total,
    coalesce(jsonb_agg(jsonb_build_object(
      'id', p.id,
      'slug', p.slug,
      'name', p.name,
      'short_description', p.short_description,
      'gender', p.gender,
      'product_type', p.product_type,
      'concentration', p.concentration,
      'is_featured', p.is_featured,
      'is_trending', p.is_trending,
      'price_from_lkr', p.price_from_lkr,
      'units_sold', p.units_sold,
      'rating_avg', p.rating_avg,
      'rating_count', p.rating_count,
      'total_stock', p.total_stock,
      'has_sale', coalesce(p.has_sale,false),
      'created_at', p.created_at
    ) order by
      case when coalesce(p_availability,'') <> 'in-stock' then (case when p.total_stock <= 0 then 1 else 0 end) else 0 end asc,
      case when p_sort = 'relevance' and v_q is not null then p.relevance end desc nulls last,
      case when p_sort in ('featured','relevance') then p.is_featured end desc nulls last,
      case when p_sort in ('featured','relevance') then p.trending_rank end asc nulls last,
      case when p_sort = 'newest' then p.created_at end desc nulls last,
      case when p_sort = 'price-asc' then p.price_from_lkr end asc nulls last,
      case when p_sort = 'price-desc' then p.price_from_lkr end desc nulls last,
      case when p_sort = 'best-selling' then p.units_sold end desc nulls last,
      case when p_sort = 'rating' then p.rating_avg end desc nulls last,
      case when p_sort = 'rating' then p.rating_count end desc nulls last,
      p.created_at desc
    ), '[]'::jsonb)
  into v_total, v_rows
  from counted c
  left join paged p on true
  group by c.total;

  return jsonb_build_object(
    'items', coalesce(v_rows, '[]'::jsonb),
    'total', coalesce(v_total, 0),
    'page', v_page,
    'page_size', v_size
  );
end;
$$;

grant execute on function public.search_products(text, text[], text[], text[], integer[], integer, integer, text, boolean, text, text, integer, integer) to anon, authenticated, service_role;
