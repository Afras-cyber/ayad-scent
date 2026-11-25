import type { Tables, Enums } from "@/types/database.types";

export type Product = Tables<"products">;
export type ProductVariant = Tables<"product_variants">;
export type ProductImage = Tables<"product_images">;
export type Collection = Tables<"collections">;
export type Note = Tables<"notes">;
export type ProductNote = Tables<"product_notes">;

export type ProductWithRelations = Product & {
  variants: ProductVariant[];
  images: ProductImage[];
  collections: Collection[];
  notes: Note[];
};

export type ProductType = Enums<"product_type">;
export type ConcentrationType = Enums<"concentration_type">;
export type NoteLayer = Enums<"note_layer">;
export type OccasionType = Enums<"occasion_type">;
export type SeasonType = Enums<"season_type">;