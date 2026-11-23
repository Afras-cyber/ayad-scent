-- Core commerce RPC functions
begin;

-- create_order: creates an order transactionally (server-side pricing/validation)
-- Expected p_payload JSONB shape (essential fields):
-- {
--   "idempotency_key": "string|null",
--   "customer_name": "string",
--   "phone_e164": "string",
--   "email": "string|null",
--   "address_line": "string",
--   "city": "string",
--   "district": "string",
--   "notes": "string|null",
--   "payment_method": "cod|bank_transfer",
--   "whatsapp_opt_in": true|false,
--   "items": [{"variant_id":"uuid","quantity":1}, ...]
-- }
create or replace function public.create_order(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_idempotency_key text := nullif(btrim(p_payload->>'idempotency_key'), '');
  v_existing public.orders%rowtype;
  v_order public.orders%rowtype;
  v_district text := btrim(coalesce(p_payload->>'district', ''));
  v_payment_method public.payment_method;
  v_whatsapp_opt_in boolean := coalesce((p_payload->>'whatsapp_opt_in')::boolean, false);
  v_customer_name text := btrim(coalesce(p_payload->>'customer_name', ''));
  v_phone_e164 text := btrim(coalesce(p_payload->>'phone_e164', ''));
  v_email text := nullif(btrim(coalesce(p_payload->>'email', '')), '');
  v_address_line text := btrim(coalesce(p_payload->>'address_line', ''));
  v_city text := btrim(coalesce(p_payload->>'city', ''));
  v_notes text := nullif(btrim(coalesce(p_payload->>'notes', '')), '');
  v_subtotal_lkr integer := 0;
  v_delivery_fee_lkr integer := 0;
  v_total_lkr integer := 0;
  v_free_threshold integer := 5000;
  v_item jsonb;
  v_variant_id uuid;
  v_qty integer;
  v_variant record;
  v_line_total integer;
begin
  if v_idempotency_key is not null then
    select * into v_existing
    from public.orders
    where idempotency_key = v_idempotency_key;
    if found then
      return jsonb_build_object(
        'id', v_existing.id,
        'code', v_existing.code,
        'subtotal_lkr', v_existing.subtotal_lkr,
        'delivery_fee_lkr', v_existing.delivery_fee_lkr,
        'total_lkr', v_existing.total_lkr,
        'status', v_existing.status,
        'payment_status', v_existing.payment_status,
        'idempotent', true
      );
    end if;
  end if;

  if v_customer_name = '' or v_phone_e164 = '' or v_address_line = '' or v_city = '' or v_district = '' then
    raise exception 'Missing required customer/address fields';
  end if;

  v_payment_method := (p_payload->>'payment_method')::public.payment_method;

  if jsonb_typeof(p_payload->'items') <> 'array' or jsonb_array_length(p_payload->'items') = 0 then
    raise exception 'Order must contain at least one item';
  end if;

  -- free delivery threshold from site_settings (public or private; function is definer)
  select coalesce(
    (value->>'value')::integer,
    (value->>'free_delivery_threshold_lkr')::integer,
    (value)::integer,
    5000
  ) into v_free_threshold
  from public.site_settings
  where key in ('free_delivery_threshold_lkr', 'commerce')
  order by case when key = 'free_delivery_threshold_lkr' then 0 else 1 end
  limit 1;
  if v_free_threshold is null then v_free_threshold := 5000; end if;

  -- validate items, lock variants, calculate subtotal from DB prices, decrement stock
  for v_item in select * from jsonb_array_elements(p_payload->'items')
  loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::integer, 0);

    if v_variant_id is null or v_qty < 1 or v_qty > 20 then
      raise exception 'Invalid item variant or quantity';
    end if;

    select
      v.id as variant_id,
      v.product_id,
      v.label as variant_label,
      v.price_lkr,
      v.stock,
      v.is_active as variant_active,
      p.name as product_name,
      p.is_active as product_active
    into v_variant
    from public.product_variants v
    join public.products p on p.id = v.product_id
    where v.id = v_variant_id
    for update of v;

    if not found then
      raise exception 'Variant not found: %', v_variant_id;
    end if;
    if v_variant.variant_active is not true or v_variant.product_active is not true then
      raise exception 'Variant or product is not available: %', v_variant_id;
    end if;
    if v_variant.stock < v_qty then
      raise exception 'Insufficient stock for variant: %', v_variant_id;
    end if;

    v_line_total := v_variant.price_lkr * v_qty;
    v_subtotal_lkr := v_subtotal_lkr + v_line_total;
  end loop;

  -- delivery fee from district (active zone)
  select coalesce(dz.fee_lkr, 0) into v_delivery_fee_lkr
  from public.delivery_zones dz
  where dz.is_active = true and lower(dz.district) = lower(v_district)
  limit 1;
  if not found then
    v_delivery_fee_lkr := 0; -- essential fallback; can be tightened later
  end if;

  if v_subtotal_lkr >= v_free_threshold then
    v_delivery_fee_lkr := 0;
  end if;

  v_total_lkr := v_subtotal_lkr + v_delivery_fee_lkr;

  insert into public.orders (
    customer_name, phone_e164, email, address_line, city, district, notes,
    whatsapp_opt_in, whatsapp_opt_in_at,
    payment_method, payment_status, status,
    subtotal_lkr, delivery_fee_lkr, total_lkr, idempotency_key
  ) values (
    v_customer_name, v_phone_e164, v_email, v_address_line, v_city, v_district, v_notes,
    v_whatsapp_opt_in, case when v_whatsapp_opt_in then now() else null end,
    v_payment_method, 'unpaid', 'pending',
    v_subtotal_lkr, v_delivery_fee_lkr, v_total_lkr, v_idempotency_key
  )
  returning * into v_order;

  -- insert items (snapshot) and decrement stock
  for v_item in select * from jsonb_array_elements(p_payload->'items')
  loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := (v_item->>'quantity')::integer;

    select
      v.id as variant_id,
      v.product_id,
      v.label as variant_label,
      v.price_lkr,
      p.name as product_name
    into v_variant
    from public.product_variants v
    join public.products p on p.id = v.product_id
    where v.id = v_variant_id;

    v_line_total := v_variant.price_lkr * v_qty;

    insert into public.order_items (
      order_id, variant_id, product_id, product_name, variant_label,
      unit_price_lkr, quantity, line_total_lkr
    ) values (
      v_order.id, v_variant.variant_id, v_variant.product_id, v_variant.product_name,
      v_variant.variant_label, v_variant.price_lkr, v_qty, v_line_total
    );

    update public.product_variants
    set stock = stock - v_qty
    where id = v_variant_id;
  end loop;

  -- first order event
  insert into public.order_events (order_id, status, note)
  values (v_order.id, 'pending', 'Order placed');

  -- outbox row when opted in
  if v_whatsapp_opt_in then
    insert into public.notification_outbox (order_id, event, channel, status, payload)
    values (v_order.id, 'order_placed', 'whatsapp', 'pending', jsonb_build_object('order_code', v_order.code));
  end if;

  return jsonb_build_object(
    'id', v_order.id,
    'code', v_order.code,
    'subtotal_lkr', v_order.subtotal_lkr,
    'delivery_fee_lkr', v_order.delivery_fee_lkr,
    'total_lkr', v_order.total_lkr,
    'status', v_order.status,
    'payment_status', v_order.payment_status,
    'idempotent', false
  );
end;
$$;

-- record_payment: records a payment and enqueues receipt notification in one transaction
-- Expected p_payload JSONB shape:
-- {
--   "order_id": "uuid" (or "order_code": "AYD-..."),
--   "method": "cod|bank_transfer",
--   "amount_lkr": 1234,
--   "reference": "string|null",
--   "slip_path": "string|null",
--   "recorded_by": "uuid|null"
-- }
create or replace function public.record_payment(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_order public.orders%rowtype;
  v_payment public.payments%rowtype;
  v_order_id uuid := nullif(p_payload->>'order_id', '')::uuid;
  v_order_code text := nullif(btrim(p_payload->>'order_code'), '');
  v_method public.payment_method := (p_payload->>'method')::public.payment_method;
  v_amount integer := (p_payload->>'amount_lkr')::integer;
  v_reference text := nullif(btrim(coalesce(p_payload->>'reference', '')), '');
  v_slip_path text := nullif(btrim(coalesce(p_payload->>'slip_path', '')), '');
  v_recorded_by uuid := nullif(p_payload->>'recorded_by', '')::uuid;
begin
  if v_amount is null or v_amount <= 0 then
    raise exception 'amount_lkr must be greater than 0';
  end if;

  if v_order_id is not null then
    select * into v_order from public.orders where id = v_order_id for update;
  elsif v_order_code is not null then
    select * into v_order from public.orders where code = v_order_code for update;
  else
    raise exception 'order_id or order_code is required';
  end if;

  if not found then
    raise exception 'Order not found';
  end if;

  insert into public.payments (order_id, method, amount_lkr, reference, slip_path, recorded_by, received_at)
  values (v_order.id, v_method, v_amount, v_reference, v_slip_path, v_recorded_by, now())
  returning * into v_payment;

  update public.orders
  set payment_status = 'paid',
      updated_at = now()
  where id = v_order.id
  returning * into v_order;

  insert into public.order_events (order_id, status, note, actor_admin_user_id)
  values (v_order.id, v_order.status, 'Payment received', v_recorded_by);

  -- enqueue receipt notification (if opted in, send; else create skipped record for audit)
  if v_order.whatsapp_opt_in then
    insert into public.notification_outbox (order_id, event, channel, status, payload)
    values (v_order.id, 'payment_received', 'whatsapp', 'pending', jsonb_build_object('order_code', v_order.code, 'amount_lkr', v_amount))
    on conflict (order_id, event, channel) do nothing;
  else
    insert into public.notification_outbox (order_id, event, channel, status, payload, last_error)
    values (v_order.id, 'payment_received', 'whatsapp', 'skipped', jsonb_build_object('order_code', v_order.code, 'amount_lkr', v_amount), 'Customer not opted in to WhatsApp')
    on conflict (order_id, event, channel) do nothing;
  end if;

  return jsonb_build_object(
    'order_id', v_order.id,
    'order_code', v_order.code,
    'payment_id', v_payment.id,
    'payment_status', v_order.payment_status,
    'amount_lkr', v_payment.amount_lkr
  );
end;
$$;

-- Security: revoke execute from anon/authenticated
revoke all on function public.create_order(jsonb) from public;
revoke all on function public.create_order(jsonb) from anon, authenticated;
grant execute on function public.create_order(jsonb) to service_role;

revoke all on function public.record_payment(jsonb) from public;
revoke all on function public.record_payment(jsonb) from anon, authenticated;
grant execute on function public.record_payment(jsonb) to service_role;

commit;
