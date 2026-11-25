import type { SeoConfig } from "./schema";

export const seoConfig = {
  titleTemplate: "%s | AYAD",
  defaultTitle: "AYAD - Premium Oud, Musk & Amber Perfumes in Sri Lanka",
  defaultDescription:
    "Long-lasting oud, musk and amber attars and Arabic-inspired perfumes. Cash on Delivery and island-wide delivery.",
  ogImage: "https://ayadscentlab.com/og/default.jpg",
  siteName: "AYAD",
} as const satisfies SeoConfig;