"use server";

import { createAdminClient } from "@/lib/supabase/admin";
import type { Database } from "@/types/database.types";

type NotificationOutboxInsert = Database["public"]["Tables"]["notification_outbox"]["Insert"];

export async function enqueueNotification(orderId: string, event: "order_placed" | "payment_received" | "order_dispatched" | "order_delivered" | "order_cancelled", payload: Record<string, unknown>) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("notification_outbox")
    .insert({
      order_id: orderId,
      event,
      channel: "whatsapp",
      status: "pending",
      attempts: 0,
      payload,
    } as NotificationOutboxInsert)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getPendingNotifications() {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("notification_outbox")
    .select("*")
    .eq("status", "pending")
    .lte("next_attempt_at", new Date().toISOString())
    .order("created_at", { ascending: true });

  if (error) throw error;
  return (data ?? []) as Database["public"]["Tables"]["notification_outbox"]["Row"][];
}

export async function updateNotificationStatus(id: string, status: "sent" | "failed" | "skipped", errorMessage?: string) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("notification_outbox")
    .update({
      status,
      last_error: errorMessage || null,
      sent_at: status === "sent" ? new Date().toISOString() : null,
      attempts: status === "failed" ? undefined : undefined,
    })
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;
  return data;
}