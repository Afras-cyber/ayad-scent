import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export async function getSiteSettings() {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("site_settings")
    .select("key, value, is_public")
    .eq("is_public", true);

  if (error) throw error;
  return (data ?? []) as { key: string; value: unknown; is_public: boolean }[];
}

export async function getSiteSetting(key: string) {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("site_settings")
    .select("key, value, is_public")
    .eq("key", key)
    .single();

  if (error) throw error;
  return data as { key: string; value: unknown; is_public: boolean } | null;
}

export async function updateSiteSetting(key: string, value: unknown, isPublic: boolean) {
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("site_settings")
    .upsert({ key, value, is_public: isPublic })
    .select()
    .single();

  if (error) throw error;
  return data;
}