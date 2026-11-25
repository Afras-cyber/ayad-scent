import { createClient } from "@/lib/supabase/server";
import type { Database } from "@/types/database.types";
import type { ProductFilters } from "./schemas";
import type { Product, ProductWithRelations } from "./types";

type ProductRow = Database["public"]["Tables"]["products"]["Row"];
type ProductVariantRow = Database["public"]["Tables"]["product_variants"]["Row"];
type ProductImageRow = Database["public"]["Tables"]["product_images"]["Row"];
type CollectionRow = Database["public"]["Tables"]["collections"]["Row"];
type NoteRow = Database["public"]["Tables"]["notes"]["Row"];
type ProductNoteRow = Database["public"]["Tables"]["product_notes"]["Row"];

async function getClient() {
  const { createClient } = await import("@/lib/supabase/server");
  return createClient();
}

export async function getProducts(filters: ProductFilters) {
  const supabase = await getClient();

  let query = supabase
    .from("products")
    .select(`
      *,
      product_variants (*),
      product_images (*),
      product_collections (collection_id),
      product_notes (note_id)
    `)
    .eq("is_active", true)
    .order("created_at", { ascending: false })
    .range((filters.page - 1) * filters.pageSize, filters.page * filters.pageSize - 1);

  if (filters.q) {
    query = query.ilike("name", `%${filters.q}%`);
  }
  if (filters.collection) {
    query = query.eq("product_collections.collection_id", filters.collection);
  }
  if (filters.min !== undefined) {
    query = query.gte("price_from_lkr", filters.min);
  }
  if (filters.max !== undefined) {
    query = query.lte("price_from_lkr", filters.max);
  }
  if (filters.availability === "in_stock") {
    query = query.gt("product_variants.stock", 0);
  }
  if (filters.availability === "out_of_stock") {
    query = query.eq("product_variants.stock", 0);
  }

  const { data, error, count } = await query;

  if (error) throw error;

  return {
    products: (data ?? []) as ProductWithRelations[],
    count: count ?? 0,
  };
}

export async function getProductBySlug(slug: string) {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("products")
    .select(`
      *,
      product_variants (*),
      product_images (*),
      product_collections (collection_id),
      product_notes (note_id)
    `)
    .eq("slug", slug)
    .eq("is_active", true)
    .single();

  if (error) throw error;
  return data as ProductWithRelations;
}

export async function getFeaturedProducts(limit = 8) {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("products")
    .select(`
      *,
      product_variants (*),
      product_images (*)
    `)
    .eq("is_active", true)
    .eq("is_featured", true)
    .order("created_at", { ascending: false })
    .limit(limit);

  if (error) throw error;
  return (data ?? []) as ProductWithRelations[];
}

export async function getTrendingProducts(limit = 8) {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("products")
    .select(`
      *,
      product_variants (*),
      product_images (*)
    `)
    .eq("is_active", true)
    .eq("is_trending", true)
    .order("trending_rank", { ascending: false })
    .limit(limit);

  if (error) throw error;
  return (data ?? []) as ProductWithRelations[];
}

export async function getCollections() {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("collections")
    .select("*")
    .eq("is_active", true)
    .order("sort_order", { ascending: true });

  if (error) throw error;
  return (data ?? []) as CollectionRow[];
}

export async function getCollectionBySlug(slug: string) {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("collections")
    .select("*")
    .eq("slug", slug)
    .eq("is_active", true)
    .single();

  if (error) throw error;
  return data as CollectionRow;
}

export async function getNotes() {
  const supabase = await getClient();

  const { data, error } = await supabase
    .from("notes")
    .select("*")
    .eq("is_active", true)
    .order("name", { ascending: true });

  if (error) throw error;
  return (data ?? []) as NoteRow[];
}