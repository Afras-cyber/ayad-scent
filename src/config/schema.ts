import { z } from "zod";

export const SiteConfigSchema = z.object({
  name: z.string().min(1),
  legalName: z.string().min(1),
  tagline: z.string().min(1),
  description: z.string().min(1),
  url: z.string().url(),
  domain: z.string().min(1),
  language: z.string().min(1),
  locale: z.string().min(1),
  timezone: z.string().min(1),
  currency: z.object({
    code: z.string().length(3),
    symbol: z.string().min(1),
    decimals: z.number().int().nonnegative(),
  }),
  brand: z.object({
    logoText: z.string().min(1),
    logoLetterSpacing: z.string().min(1),
    themeColor: z.string().startsWith("#"),
  }),
  contact: z.object({
    phoneDisplay: z.string().min(1),
    phoneE164: z.string().startsWith("+"),
    whatsapp: z.object({
      display: z.string().min(1),
      number: z.string().min(1),
      defaultMessage: z.string().min(1),
    }),
    email: z.string().email(),
    hours: z.string().min(1),
    address: z.object({
      line1: z.string(),
      city: z.string(),
      district: z.string(),
      country: z.string(),
    }),
  }),
  social: z.object({
    instagram: z.string().url().optional().or(z.literal("")),
    facebook: z.string().url().optional().or(z.literal("")),
    tiktok: z.string().url().optional().or(z.literal("")),
  }),
  ogImage: z.string().url().optional().or(z.literal("")),
  ogImage2: z.string().url().optional().or(z.literal("")),
});

export type SiteConfig = z.infer<typeof SiteConfigSchema>;

export const CommerceConfigSchema = z.object({
  orderCodePrefix: z.string().min(1),
  invoicePrefix: z.string().min(1),
  receiptPrefix: z.string().min(1),
  maxQtyPerLine: z.number().int().positive(),
  maxLinesPerOrder: z.number().int().positive(),
  freeDeliveryThresholdLkr: z.number().int().nonnegative(),
  paymentMethods: z.array(z.enum(["cod", "bank_transfer"])),
  bankTransfer: z.object({
    bankName: z.string(),
    accountName: z.string(),
    accountNumber: z.string(),
    branch: z.string(),
  }),
  deliveryEstimate: z.object({
    colombo: z.string(),
    other: z.string(),
  }),
});

export type CommerceConfig = z.infer<typeof CommerceConfigSchema>;

export const NotificationsConfigSchema = z.object({
  provider: z.string().min(1),
  graphApiVersion: z.string().min(1),
  language: z.string().min(1),
  events: z.object({
    order_placed: z.object({
      enabled: z.boolean(),
      template: z.string().min(1),
      attach: z.string().nullable(),
    }),
    payment_received: z.object({
      enabled: z.boolean(),
      template: z.string().min(1),
      attach: z.string().nullable(),
    }),
    order_dispatched: z.object({
      enabled: z.boolean(),
      template: z.string().min(1),
      attach: z.string().nullable(),
    }),
    order_delivered: z.object({
      enabled: z.boolean(),
      template: z.string().min(1),
      attach: z.string().nullable(),
    }),
    order_cancelled: z.object({
      enabled: z.boolean(),
      template: z.string().min(1),
      attach: z.string().nullable(),
    }),
  }),
  retry: z.object({
    maxAttempts: z.number().int().positive(),
    backoffSeconds: z.array(z.number().int().positive()),
  }),
  optIn: z.object({
    required: z.boolean(),
    checkboxDefaultChecked: z.boolean(),
  }),
  pdf: z.object({
    paper: z.string().min(1),
    showTaxLine: z.boolean(),
  }),
});

export type NotificationsConfig = z.infer<typeof NotificationsConfigSchema>;

export const NavigationConfigSchema = z.object({
  header: z.array(z.object({
    label: z.string().min(1),
    href: z.string().min(1),
  })),
  footer: z.array(z.object({
    label: z.string().min(1),
    href: z.string().min(1),
  })),
  megaMenu: z.array(z.object({
    label: z.string().min(1),
    href: z.string().min(1),
    items: z.array(z.object({
      label: z.string().min(1),
      href: z.string().min(1),
    })),
  })),
});

export type NavigationConfig = z.infer<typeof NavigationConfigSchema>;

export const SeoConfigSchema = z.object({
  titleTemplate: z.string().min(1),
  defaultTitle: z.string().min(1),
  defaultDescription: z.string().min(1),
  ogImage: z.string().url().optional().or(z.literal("")),
  siteName: z.string().min(1),
});

export type SeoConfig = z.infer<typeof SeoConfigSchema>;

export const FeaturesConfigSchema = z.object({
  darkMode: z.boolean(),
  reviews: z.boolean(),
  newsletter: z.boolean(),
  wishlist: z.boolean(),
});

export type FeaturesConfig = z.infer<typeof FeaturesConfigSchema>;

export const AllConfigSchema = z.object({
  site: SiteConfigSchema,
  commerce: CommerceConfigSchema,
  notifications: NotificationsConfigSchema,
  navigation: NavigationConfigSchema,
  seo: SeoConfigSchema,
  features: FeaturesConfigSchema,
});

function findPlaceholders(obj: unknown, path: string = ""): string[] {
  const issues: string[] = [];
  if (typeof obj === "string") {
    const lowered = obj.toLowerCase();
    if (
      lowered.includes("todo") ||
      lowered.includes("****") ||
      lowered.includes("placeholder") ||
      obj.trim() === ""
    ) {
      issues.push(path || "(root)");
    }
  } else if (Array.isArray(obj)) {
    obj.forEach((item, i) => {
      issues.push(...findPlaceholders(item, `${path}[${i}]`));
    });
  } else if (obj !== null && typeof obj === "object") {
    for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
      issues.push(...findPlaceholders(value, `${path}.${key}`));
    }
  }
  return issues;
}

export function validateConfig(config: Record<string, unknown>) {
  const parsed = AllConfigSchema.safeParse(config);
  if (!parsed.success) {
    throw new Error(
      `Config validation failed:\n${parsed.error.errors.map((e) => `${e.path.join(".")}: ${e.message}`).join("\n")}`
    );
  }

  const placeholderIssues = findPlaceholders(config);
  if (placeholderIssues.length > 0) {
    throw new Error(
      `Config contains placeholders or empty values at:\n${placeholderIssues.join("\n")}`
    );
  }

  return parsed.data;
}