import { createClient } from "@/lib/supabase/server";
import type { Database } from "@/types/database.types";

export async function getApprovedReviews(productId?: string) {
  const supabase = await createClient();

  let query = supabase
    .from("reviews")
    .select("*")
    .eq("status", "approved")
    .order("created_at", { ascending: false });

  if (productId) {
    query = query.eq("product_id", productId);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as Database["public"]["Tables"]["reviews"]["Row"][];
}

export async function getAllReviews() {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("reviews")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return (data ?? []) as Database["public"]["Tables"]["reviews"]["Row"][];
}