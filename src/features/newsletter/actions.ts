"use server";

import { createAdminClient } from "@/lib/supabase/admin";
import { z } from "zod";

const newsletterSchema = z.object({
  email: z.string().email("Invalid email address"),
  source: z.string().default("website"),
});

export async function subscribeNewsletter(email: string, source?: string) {
  const validated = newsletterSchema.parse({ email, source });
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("newsletter_subscribers")
    .insert({
      email: validated.email,
      source: validated.source,
      is_active: true,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getNewsletterSubscribers() {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("newsletter_subscribers")
    .select("*")
    .order("subscribed_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}