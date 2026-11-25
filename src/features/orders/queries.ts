import { createAdminClient } from "@/lib/supabase/admin";
import type { Database } from "@/types/database.types";

type OrderRow = Database["public"]["Tables"]["orders"]["Row"];
type OrderItemRow = Database["public"]["Tables"]["order_items"]["Row"];
type OrderEventRow = Database["public"]["Tables"]["order_events"]["Row"];

export async function getOrderByCode(code: string) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("orders")
    .select(`
      *,
      order_items (*),
      order_events (*, created_at)
    `)
    .eq("code", code)
    .single();

  if (error) throw error;
  return { order: data as OrderRow, items: (data.order_items ?? []) as OrderItemRow[], events: (data.order_events ?? []) as OrderEventRow[] };
}

export async function getOrdersByPhone(phoneE164: string) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("orders")
    .select(`
      *,
      order_items (*)
    `)
    .eq("phone_e164", phoneE164)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return (data ?? []) as OrderRow[];
}

export async function getAllOrders() {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("orders")
    .select(`
      *,
      order_items (*)
    `)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return (data ?? []) as OrderRow[];
}