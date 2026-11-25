import type { SiteConfig } from "./schema";

export const siteConfig = {
  name: "AYAD",
  legalName: "AYAD Scent Lab",
  tagline: "Smell Expensive. Feel Confident.",
  description:
    "Long-lasting oud, musk and amber attars and Arabic-inspired perfumes in Sri Lanka. Cash on Delivery and island-wide delivery.",
  url: "https://ayadscentlab.com",
  domain: "ayadscentlab.com",
  language: "en",
  locale: "en-LK",
  timezone: "Asia/Colombo",
  currency: { code: "LKR", symbol: "Rs", decimals: 0 },

  brand: {
    logoText: "AYAD",
    logoLetterSpacing: "0.42em",
    themeColor: "#081B1A",
  },

  contact: {
    phoneDisplay: "+94 76 776 0000",
    phoneE164: "+94767760000",
    whatsapp: {
      display: "+94 76 776 0000",
      number: "94767760000",
      defaultMessage: "Hello AYAD, I need help choosing a scent.",
    },
    email: "hello@ayadscentlab.com",
    hours: "Daily 10am – 10pm",
    address: {
      line1: "",
      city: "",
      district: "",
      country: "Sri Lanka",
    },
  },

  social: {
    instagram: "https://instagram.com/ayadscentlab",
    facebook: "",
    tiktok: "",
  },
} as const satisfies SiteConfig;