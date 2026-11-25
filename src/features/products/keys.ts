export const productKeys = {
  all: ["products"] as const,
  list: (filters: Record<string, unknown>) => [...productKeys.all, "list", filters] as const,
  detail: (slug: string) => [...productKeys.all, "detail", slug] as const,
  variants: (productId: string) => [...productKeys.all, "variants", productId] as const,
  images: (productId: string) => [...productKeys.all, "images", productId] as const,
  collections: ["collections"] as const,
  collectionDetail: (slug: string) => [...productKeys.all, "collections", slug] as const,
  notes: ["notes"] as const,
  search: (params: Record<string, unknown>) => [...productKeys.all, "search", params] as const,
} as const;