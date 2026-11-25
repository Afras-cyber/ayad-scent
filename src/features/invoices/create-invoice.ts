"use server";

import { createAdminClient } from "@/lib/supabase/admin";
import type { Database } from "@/types/database.types";

type InvoiceInsert = Database["public"]["Tables"]["invoices"]["Insert"];

export async function createInvoice(orderId: string, kind: "invoice" | "receipt", number: string, pdfPath: string, sha256: string) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("invoices")
    .insert({
      order_id: orderId,
      kind,
      number,
      pdf_path: pdfPath,
      sha256,
    } as InvoiceInsert)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getInvoiceByOrder(orderId: string, kind: "invoice" | "receipt") {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("invoices")
    .select("*")
    .eq("order_id", orderId)
    .eq("kind", kind)
    .single();

  if (error) throw error;
  return data;
}