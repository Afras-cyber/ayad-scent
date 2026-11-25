"use client";

import { useQuery, useQueries } from "@tanstack/react-query";
import { productKeys } from "./keys";
import type { ProductFilters } from "./schemas";

export function useProducts(filters: ProductFilters) {
  return useQuery({
    queryKey: productKeys.list(filters),
    queryFn: async () => {
      const { getProducts } = await import("./queries");
      return getProducts(filters);
    },
    staleTime: 60_000,
  });
}

export function useProduct(slug: string) {
  return useQuery({
    queryKey: productKeys.detail(slug),
    queryFn: async () => {
      const { getProductBySlug } = await import("./queries");
      return getProductBySlug(slug);
    },
    enabled: !!slug,
    staleTime: 60_000,
  });
}

export function useFeaturedProducts() {
  return useQuery({
    queryKey: [...productKeys.all, "featured"],
    queryFn: async () => {
      const { getFeaturedProducts } = await import("./queries");
      return getFeaturedProducts();
    },
    staleTime: 60_000,
  });
}

export function useTrendingProducts() {
  return useQuery({
    queryKey: [...productKeys.all, "trending"],
    queryFn: async () => {
      const { getTrendingProducts } = await import("./queries");
      return getTrendingProducts();
    },
    staleTime: 60_000,
  });
}

export function useCollections() {
  return useQuery({
    queryKey: productKeys.collections,
    queryFn: async () => {
      const { getCollections } = await import("./queries");
      return getCollections();
    },
    staleTime: 5 * 60_000,
  });
}

export function useNotes() {
  return useQuery({
    queryKey: productKeys.notes,
    queryFn: async () => {
      const { getNotes } = await import("./queries");
      return getNotes();
    },
    staleTime: 5 * 60_000,
  });
}