import type { FeaturesConfig } from "./schema";

export const featuresConfig = {
  darkMode: true,
  reviews: true,
  newsletter: true,
  wishlist: true,
} as const satisfies FeaturesConfig;