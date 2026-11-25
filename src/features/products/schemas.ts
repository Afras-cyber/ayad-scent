import { z } from "zod";

export const productFiltersSchema = z.object({
  q: z.string().optional(),
  gender: z.array(z.string()).optional(),
  type: z.array(z.string()).optional(),
  notes: z.array(z.string()).optional(),
  size: z.array(z.string()).optional(),
  min: z.coerce.number().optional(),
  max: z.coerce.number().optional(),
  availability: z.enum(["in_stock", "low_stock", "out_of_stock"]).optional(),
  sale: z.boolean().optional(),
  collection: z.string().optional(),
  sort: z.enum(["featured", "trending", "price_asc", "price_desc", "name_asc", "name_desc", "newest"]).optional(),
  page: z.coerce.number().min(1).default(1),
  pageSize: z.coerce.number().min(1).max(48).default(12),
});

export type ProductFilters = z.infer<typeof productFiltersSchema>;

export const productVariantSchema = z.object({
  label: z.string().min(1),
  sku: z.string().optional().nullable(),
  priceLkr: z.number().int().nonnegative(),
  compareAtLkr: z.number().int().nonnegative().optional().nullable(),
  stock: z.number().int().nonnegative(),
  sizeMl: z.number().int().positive().optional().nullable(),
  isActive: z.boolean().default(true),
});

export type ProductVariantInput = z.infer<typeof productVariantSchema>;

export const productCreateSchema = z.object({
  name: z.string().min(1),
  slug: z.string().min(1),
  shortDescription: z.string().optional(),
  description: z.string().optional(),
  gender: z.string().optional(),
  isActive: z.boolean().default(true),
  isFeatured: z.boolean().default(false),
  isTrending: z.boolean().default(false),
  priceFromLkr: z.number().int().nonnegative(),
  productType: z.enum(["attar", "spray", "gift_set"]),
  concentration: z.enum(["attar_oil", "parfum", "edp", "edt"]).optional().nullable(),
  scentStory: z.string().optional().nullable(),
  seoTitle: z.string().optional().nullable(),
  seoDescription: z.string().optional().nullable(),
  variants: z.array(productVariantSchema).min(1),
});

export type ProductCreateInput = z.infer<typeof productCreateSchema>;

export const productUpdateSchema = productCreateSchema.partial();

export type ProductUpdateInput = z.infer<typeof productUpdateSchema>;