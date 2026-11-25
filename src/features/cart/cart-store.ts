"use client";

import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

export type CartLine = {
  variantId: string;
  quantity: number;
};

type CartState = {
  lines: CartLine[];
  add: (variantId: string, qty?: number) => void;
  setQty: (variantId: string, qty: number) => void;
  remove: (variantId: string) => void;
  clear: () => void;
};

export const useCartStore = create<CartState>()(
  persist(
    (set) => ({
      lines: [],
      add: (variantId, qty = 1) =>
        set((s) => {
          const found = s.lines.find((l) => l.variantId === variantId);
          const lines = found
            ? s.lines.map((l) =>
                l.variantId === variantId
                  ? { ...l, quantity: Math.min(20, l.quantity + qty) }
                  : l,
              )
            : [...s.lines, { variantId, quantity: qty }];
          return { lines };
        }),
      setQty: (variantId, qty) =>
        set((s) => ({
          lines: s.lines
            .map((l) =>
              l.variantId === variantId
                ? { ...l, quantity: Math.max(0, Math.min(20, qty)) }
                : l,
            )
            .filter((l) => l.quantity > 0),
        })),
      remove: (variantId) =>
        set((s) => ({ lines: s.lines.filter((l) => l.variantId !== variantId) })),
      clear: () => set({ lines: [] }),
    }),
    { name: "ayad-cart", version: 1, storage: createJSONStorage(() => localStorage), skipHydration: true },
  ),
);