
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: '14.18'
  }
  "graphql_public": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "graphql":
{ Args: { "extensions"?: Json,"operationName"?: string,"query"?: string,"variables"?: Json }; Returns: Json
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"public": {
          Tables: {
            "admin_users": {
                  Row: {
                    "avatar_url": string | null,"created_at": string,"email": string,"id": string,"is_active": boolean,"last_login_at": string | null,"name": string,"password_hash": string | null,"phone": string | null,"role": Database["public"]['Enums']["admin_role"],"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "avatar_url"?: string | null,"created_at"?: string,"email": string,"id"?: string,"is_active"?: boolean,"last_login_at"?: string | null,"name": string,"password_hash"?: string | null,"phone"?: string | null,"role"?: Database["public"]['Enums']["admin_role"],"updated_at"?: string
                  }
                  Update: {
                    "avatar_url"?: string | null,"created_at"?: string,"email"?: string,"id"?: string,"is_active"?: boolean,"last_login_at"?: string | null,"name"?: string,"password_hash"?: string | null,"phone"?: string | null,"role"?: Database["public"]['Enums']["admin_role"],"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"banners": {
                  Row: {
                    "background_color": string | null,"button_text": string | null,"created_at": string,"end_at": string | null,"id": string,"image_path": string | null,"image_url": string | null,"is_active": boolean,"link_url": string | null,"mobile_image_path": string | null,"mobile_image_url": string | null,"placement": string,"sort_order": number,"start_at": string | null,"subtitle": string | null,"text_color": string | null,"title": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "background_color"?: string | null,"button_text"?: string | null,"created_at"?: string,"end_at"?: string | null,"id"?: string,"image_path"?: string | null,"image_url"?: string | null,"is_active"?: boolean,"link_url"?: string | null,"mobile_image_path"?: string | null,"mobile_image_url"?: string | null,"placement"?: string,"sort_order"?: number,"start_at"?: string | null,"subtitle"?: string | null,"text_color"?: string | null,"title": string,"updated_at"?: string
                  }
                  Update: {
                    "background_color"?: string | null,"button_text"?: string | null,"created_at"?: string,"end_at"?: string | null,"id"?: string,"image_path"?: string | null,"image_url"?: string | null,"is_active"?: boolean,"link_url"?: string | null,"mobile_image_path"?: string | null,"mobile_image_url"?: string | null,"placement"?: string,"sort_order"?: number,"start_at"?: string | null,"subtitle"?: string | null,"text_color"?: string | null,"title"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"collections": {
                  Row: {
                    "created_at": string,"description": string | null,"id": string,"image_path": string | null,"is_active": boolean,"name": string,"slug": string,"sort_order": number,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"description"?: string | null,"id"?: string,"image_path"?: string | null,"is_active"?: boolean,"name": string,"slug": string,"sort_order"?: number,"updated_at"?: string
                  }
                  Update: {
                    "created_at"?: string,"description"?: string | null,"id"?: string,"image_path"?: string | null,"is_active"?: boolean,"name"?: string,"slug"?: string,"sort_order"?: number,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"delivery_zones": {
                  Row: {
                    "created_at": string,"district": string,"estimated_days_max": number | null,"estimated_days_min": number | null,"fee_lkr": number,"id": string,"is_active": boolean,"province": string | null,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"district": string,"estimated_days_max"?: number | null,"estimated_days_min"?: number | null,"fee_lkr"?: number,"id"?: string,"is_active"?: boolean,"province"?: string | null,"updated_at"?: string
                  }
                  Update: {
                    "created_at"?: string,"district"?: string,"estimated_days_max"?: number | null,"estimated_days_min"?: number | null,"fee_lkr"?: number,"id"?: string,"is_active"?: boolean,"province"?: string | null,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"invoices": {
                  Row: {
                    "created_at": string,"id": string,"kind": string,"number": string,"order_id": string,"pdf_path": string,"sha256": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"kind": string,"number": string,"order_id": string,"pdf_path": string,"sha256": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"kind"?: string,"number"?: string,"order_id"?: string,"pdf_path"?: string,"sha256"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "invoices_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    }
                  ]
                },"newsletter_subscribers": {
                  Row: {
                    "email": string,"id": string,"is_active": boolean,"source": string | null,"subscribed_at": string,"unsubscribed_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "email": string,"id"?: string,"is_active"?: boolean,"source"?: string | null,"subscribed_at"?: string,"unsubscribed_at"?: string | null
                  }
                  Update: {
                    "email"?: string,"id"?: string,"is_active"?: boolean,"source"?: string | null,"subscribed_at"?: string,"unsubscribed_at"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"notes": {
                  Row: {
                    "created_at": string,"id": string,"is_active": boolean,"name": string,"note_type": string | null,"slug": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"is_active"?: boolean,"name": string,"note_type"?: string | null,"slug": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"is_active"?: boolean,"name"?: string,"note_type"?: string | null,"slug"?: string
                  }
                  Relationships: [
                    
                  ]
                },"notification_outbox": {
                  Row: {
                    "attempts": number,"channel": string,"created_at": string,"event": Database["public"]['Enums']["notification_event"],"id": string,"last_error": string | null,"next_attempt_at": string,"order_id": string,"payload": NonNullable<Json>,"provider_message_id": string | null,"sent_at": string | null,"status": Database["public"]['Enums']["notification_status"]
                  }
                  ComputedFields: never
                  Insert: {
                    "attempts"?: number,"channel"?: string,"created_at"?: string,"event": Database["public"]['Enums']["notification_event"],"id"?: string,"last_error"?: string | null,"next_attempt_at"?: string,"order_id": string,"payload"?: NonNullable<Json>,"provider_message_id"?: string | null,"sent_at"?: string | null,"status"?: Database["public"]['Enums']["notification_status"]
                  }
                  Update: {
                    "attempts"?: number,"channel"?: string,"created_at"?: string,"event"?: Database["public"]['Enums']["notification_event"],"id"?: string,"last_error"?: string | null,"next_attempt_at"?: string,"order_id"?: string,"payload"?: NonNullable<Json>,"provider_message_id"?: string | null,"sent_at"?: string | null,"status"?: Database["public"]['Enums']["notification_status"]
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_outbox_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    }
                  ]
                },"order_events": {
                  Row: {
                    "actor_admin_user_id": string | null,"created_at": string,"id": string,"note": string | null,"order_id": string,"status": Database["public"]['Enums']["order_status"]
                  }
                  ComputedFields: never
                  Insert: {
                    "actor_admin_user_id"?: string | null,"created_at"?: string,"id"?: string,"note"?: string | null,"order_id": string,"status": Database["public"]['Enums']["order_status"]
                  }
                  Update: {
                    "actor_admin_user_id"?: string | null,"created_at"?: string,"id"?: string,"note"?: string | null,"order_id"?: string,"status"?: Database["public"]['Enums']["order_status"]
                  }
                  Relationships: [
                    {
      foreignKeyName: "order_events_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    }
                  ]
                },"order_items": {
                  Row: {
                    "created_at": string,"id": string,"line_total_lkr": number,"order_id": string,"product_id": string | null,"product_name": string,"quantity": number,"unit_price_lkr": number,"variant_id": string | null,"variant_label": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"id"?: string,"line_total_lkr": number,"order_id": string,"product_id"?: string | null,"product_name": string,"quantity": number,"unit_price_lkr": number,"variant_id"?: string | null,"variant_label": string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"line_total_lkr"?: number,"order_id"?: string,"product_id"?: string | null,"product_name"?: string,"quantity"?: number,"unit_price_lkr"?: number,"variant_id"?: string | null,"variant_label"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "order_items_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "order_items_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "order_items_variant_id_fkey"
      columns: ["variant_id"]
isOneToOne: false
      referencedRelation: "product_variants"
      referencedColumns: ["id"]
    }
                  ]
                },"orders": {
                  Row: {
                    "address_line": string,"city": string,"code": string,"created_at": string,"customer_name": string,"delivery_fee_lkr": number,"district": string,"email": string | null,"id": string,"idempotency_key": string | null,"legacy_code": string | null,"notes": string | null,"payment_method": Database["public"]['Enums']["payment_method"],"payment_status": Database["public"]['Enums']["payment_status"],"phone_e164": string,"status": Database["public"]['Enums']["order_status"],"subtotal_lkr": number,"total_lkr": number,"updated_at": string,"whatsapp_opt_in": boolean,"whatsapp_opt_in_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "address_line": string,"city": string,"code"?: string,"created_at"?: string,"customer_name": string,"delivery_fee_lkr": number,"district": string,"email"?: string | null,"id"?: string,"idempotency_key"?: string | null,"legacy_code"?: string | null,"notes"?: string | null,"payment_method": Database["public"]['Enums']["payment_method"],"payment_status"?: Database["public"]['Enums']["payment_status"],"phone_e164": string,"status"?: Database["public"]['Enums']["order_status"],"subtotal_lkr": number,"total_lkr": number,"updated_at"?: string,"whatsapp_opt_in"?: boolean,"whatsapp_opt_in_at"?: string | null
                  }
                  Update: {
                    "address_line"?: string,"city"?: string,"code"?: string,"created_at"?: string,"customer_name"?: string,"delivery_fee_lkr"?: number,"district"?: string,"email"?: string | null,"id"?: string,"idempotency_key"?: string | null,"legacy_code"?: string | null,"notes"?: string | null,"payment_method"?: Database["public"]['Enums']["payment_method"],"payment_status"?: Database["public"]['Enums']["payment_status"],"phone_e164"?: string,"status"?: Database["public"]['Enums']["order_status"],"subtotal_lkr"?: number,"total_lkr"?: number,"updated_at"?: string,"whatsapp_opt_in"?: boolean,"whatsapp_opt_in_at"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"payments": {
                  Row: {
                    "amount_lkr": number,"created_at": string,"id": string,"method": Database["public"]['Enums']["payment_method"],"order_id": string,"received_at": string,"recorded_by": string | null,"reference": string | null,"slip_path": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "amount_lkr": number,"created_at"?: string,"id"?: string,"method": Database["public"]['Enums']["payment_method"],"order_id": string,"received_at"?: string,"recorded_by"?: string | null,"reference"?: string | null,"slip_path"?: string | null
                  }
                  Update: {
                    "amount_lkr"?: number,"created_at"?: string,"id"?: string,"method"?: Database["public"]['Enums']["payment_method"],"order_id"?: string,"received_at"?: string,"recorded_by"?: string | null,"reference"?: string | null,"slip_path"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "payments_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    }
                  ]
                },"product_collections": {
                  Row: {
                    "collection_id": string,"product_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "collection_id": string,"product_id": string
                  }
                  Update: {
                    "collection_id"?: string,"product_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "product_collections_collection_id_fkey"
      columns: ["collection_id"]
isOneToOne: false
      referencedRelation: "collections"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "product_collections_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    }
                  ]
                },"product_images": {
                  Row: {
                    "alt_text": string | null,"created_at": string,"id": string,"image_url": string | null,"is_primary": boolean,"product_id": string,"sort_order": number,"storage_path": string | null,"variant_id": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "alt_text"?: string | null,"created_at"?: string,"id"?: string,"image_url"?: string | null,"is_primary"?: boolean,"product_id": string,"sort_order"?: number,"storage_path"?: string | null,"variant_id"?: string | null
                  }
                  Update: {
                    "alt_text"?: string | null,"created_at"?: string,"id"?: string,"image_url"?: string | null,"is_primary"?: boolean,"product_id"?: string,"sort_order"?: number,"storage_path"?: string | null,"variant_id"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "product_images_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "product_images_variant_id_fkey"
      columns: ["variant_id"]
isOneToOne: false
      referencedRelation: "product_variants"
      referencedColumns: ["id"]
    }
                  ]
                },"product_notes": {
                  Row: {
                    "intensity": number | null,"note_id": string,"product_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "intensity"?: number | null,"note_id": string,"product_id": string
                  }
                  Update: {
                    "intensity"?: number | null,"note_id"?: string,"product_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "product_notes_note_id_fkey"
      columns: ["note_id"]
isOneToOne: false
      referencedRelation: "notes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "product_notes_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    }
                  ]
                },"product_variants": {
                  Row: {
                    "compare_at_lkr": number | null,"created_at": string,"id": string,"is_active": boolean,"label": string,"price_lkr": number,"product_id": string,"sku": string | null,"stock": number,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "compare_at_lkr"?: number | null,"created_at"?: string,"id"?: string,"is_active"?: boolean,"label": string,"price_lkr": number,"product_id": string,"sku"?: string | null,"stock"?: number,"updated_at"?: string
                  }
                  Update: {
                    "compare_at_lkr"?: number | null,"created_at"?: string,"id"?: string,"is_active"?: boolean,"label"?: string,"price_lkr"?: number,"product_id"?: string,"sku"?: string | null,"stock"?: number,"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "product_variants_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    }
                  ]
                },"products": {
                  Row: {
                    "concentration": string | null,"created_at": string,"description": string | null,"featured": boolean,"gender": string | null,"id": string,"is_active": boolean,"is_featured": boolean,"name": string,"rating_avg": number,"rating_count": number,"seo_description": string | null,"seo_title": string | null,"short_description": string | null,"slug": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "concentration"?: string | null,"created_at"?: string,"description"?: string | null,"featured"?: boolean,"gender"?: string | null,"id"?: string,"is_active"?: boolean,"is_featured"?: boolean,"name": string,"rating_avg"?: number,"rating_count"?: number,"seo_description"?: string | null,"seo_title"?: string | null,"short_description"?: string | null,"slug": string,"updated_at"?: string
                  }
                  Update: {
                    "concentration"?: string | null,"created_at"?: string,"description"?: string | null,"featured"?: boolean,"gender"?: string | null,"id"?: string,"is_active"?: boolean,"is_featured"?: boolean,"name"?: string,"rating_avg"?: number,"rating_count"?: number,"seo_description"?: string | null,"seo_title"?: string | null,"short_description"?: string | null,"slug"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    
                  ]
                },"reviews": {
                  Row: {
                    "body": string,"created_at": string,"customer_name": string,"id": string,"is_featured": boolean,"is_verified": boolean,"order_id": string | null,"product_id": string | null,"rating": number,"status": Database["public"]['Enums']["review_status"],"title": string | null,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "body": string,"created_at"?: string,"customer_name": string,"id"?: string,"is_featured"?: boolean,"is_verified"?: boolean,"order_id"?: string | null,"product_id"?: string | null,"rating": number,"status"?: Database["public"]['Enums']["review_status"],"title"?: string | null,"updated_at"?: string
                  }
                  Update: {
                    "body"?: string,"created_at"?: string,"customer_name"?: string,"id"?: string,"is_featured"?: boolean,"is_verified"?: boolean,"order_id"?: string | null,"product_id"?: string | null,"rating"?: number,"status"?: Database["public"]['Enums']["review_status"],"title"?: string | null,"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "reviews_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "reviews_product_id_fkey"
      columns: ["product_id"]
isOneToOne: false
      referencedRelation: "products"
      referencedColumns: ["id"]
    }
                  ]
                },"site_settings": {
                  Row: {
                    "description": string | null,"is_public": boolean,"key": string,"updated_at": string,"value": NonNullable<Json>
                  }
                  ComputedFields: never
                  Insert: {
                    "description"?: string | null,"is_public"?: boolean,"key": string,"updated_at"?: string,"value"?: NonNullable<Json>
                  }
                  Update: {
                    "description"?: string | null,"is_public"?: boolean,"key"?: string,"updated_at"?: string,"value"?: NonNullable<Json>
                  }
                  Relationships: [
                    
                  ]
                },"whatsapp_messages": {
                  Row: {
                    "body_preview": string | null,"created_at": string,"direction": string,"id": string,"order_id": string | null,"phone_e164": string,"provider_message_id": string | null,"raw": Json | null,"status": string | null,"template_name": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "body_preview"?: string | null,"created_at"?: string,"direction": string,"id"?: string,"order_id"?: string | null,"phone_e164": string,"provider_message_id"?: string | null,"raw"?: Json | null,"status"?: string | null,"template_name"?: string | null
                  }
                  Update: {
                    "body_preview"?: string | null,"created_at"?: string,"direction"?: string,"id"?: string,"order_id"?: string | null,"phone_e164"?: string,"provider_message_id"?: string | null,"raw"?: Json | null,"status"?: string | null,"template_name"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "whatsapp_messages_order_id_fkey"
      columns: ["order_id"]
isOneToOne: false
      referencedRelation: "orders"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "create_order":
{ Args: { "p_payload": Json }; Returns: Json
                           },
"record_payment":
{ Args: { "p_payload": Json }; Returns: Json
                           }
          }
          Enums: {
            "admin_role": "admin"|"staff","notification_event": "order_placed"|"payment_received"|"order_dispatched"|"order_delivered"|"order_cancelled","notification_status": "pending"|"processing"|"sent"|"delivered"|"read"|"failed"|"skipped","order_status": "pending"|"confirmed"|"packed"|"dispatched"|"delivered"|"cancelled"|"returned","payment_method": "cod"|"bank_transfer","payment_status": "unpaid"|"awaiting_verification"|"paid"|"refunded","review_status": "pending"|"approved"|"rejected"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "graphql_public": {
          Enums: {
            
          }
        },"public": {
          Enums: {
            "admin_role": ["admin", "staff"],"notification_event": ["order_placed", "payment_received", "order_dispatched", "order_delivered", "order_cancelled"],"notification_status": ["pending", "processing", "sent", "delivered", "read", "failed", "skipped"],"order_status": ["pending", "confirmed", "packed", "dispatched", "delivered", "cancelled", "returned"],"payment_method": ["cod", "bank_transfer"],"payment_status": ["unpaid", "awaiting_verification", "paid", "refunded"],"review_status": ["pending", "approved", "rejected"]
          }
        }
} as const
