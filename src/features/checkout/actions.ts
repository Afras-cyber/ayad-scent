"use server";

import { createAdminClient } from "@/lib/supabase/admin";
import type { Database } from "@/types/database.types";
import { checkoutSchema } from "./schemas";
import type { CheckoutInput } from "./schemas";

type OrderInsert = Database["public"]["Tables"]["orders"]["Insert"];
type OrderItemInsert = Database["public"]["Tables"]["order_items"]["Insert"];
type OrderEventInsert = Database["public"]["Tables"]["order_events"]["Insert"];

export async function createOrder(input: CheckoutInput, cartLines: { variantId: string; quantity: number }[]) {
  const validated = checkoutSchema.parse(input);
  const supabase = createAdminClient();

  // Calculate totals server-side from cart lines
  const variantIds = cartLines.map((l) => l.variantId);
  const { data: variants, error: variantsError } = await supabase
    .from("product_variants")
    .select("id, price_lkr, stock, is_active")
    .in("id", variantIds);

  if (variantsError) throw variantsError;

  // Validate stock and recalculate prices
  let subtotalLkr = 0;
  const lineItems: OrderItemInsert[] = [];

  for (const line of cartLines) {
    const variant = variants?.find((v) => v.id === line.variantId);
    if (!variant) throw new Error(`Variant ${line.variantId} not found`);
    if (!variant.is_active) throw new Error(`Variant ${variant.label} is not active`);
    if (variant.stock < line.quantity) throw new Error(`Insufficient stock for ${variant.label}`);

    subtotalLkr += variant.price_lkr * line.quantity;
    lineItems.push({
      variant_id: line.variantId,
      product_name: "", // Will be filled by RPC or set below
      variant_label: "", // Will be filled by RPC or set below
      unit_price_lkr: variant.price_lkr,
      quantity: line.quantity,
    });
  }

  // Determine delivery fee (simple fallback - can be enhanced with delivery_zones lookup)
  const deliveryFeeLkr = subtotalLkr >= 5000 ? 0 : 500;
  const totalLkr = subtotalLkr + deliveryFeeLkr;

  const orderInsert: OrderInsert = {
    customer_name: validated.customerName,
    phone_e164: validated.phone,
    email: validated.email || null,
    address_line: validated.addressLine,
    city: validated.city,
    district: validated.district,
    notes: validated.notes || null,
    payment_method: validated.paymentMethod,
    payment_status: "unpaid",
    status: "pending",
    subtotal_lkr: subtotalLkr,
    delivery_fee_lkr: deliveryFeeLkr,
    total_lkr: totalLkr,
    idempotency_key: validated.idempotencyKey,
    whatsapp_opt_in: validated.whatsappOptIn,
  };

  const { data: order, error: orderError } = await supabase
    .from("orders")
    .insert(orderInsert)
    .select()
    .single();

  if (orderError) throw orderError;

  // Insert order items
  const itemsWithOrderId = lineItems.map((item) => ({
    ...item,
    order_id: order.id,
  }));

  const { error: itemsError } = await supabase
    .from("order_items")
    .insert(itemsWithOrderId);

  if (itemsError) throw itemsError;

  // Insert initial order event
  const { error: eventError } = await supabase
    .from("order_events")
    .insert({
      order_id: order.id,
      status: "pending",
      note: "Order placed",
    } as OrderEventInsert);

  if (eventError) throw eventError;

  return { order, cartLines };
}