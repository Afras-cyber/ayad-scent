import { siteConfig as ayadSiteConfig } from "./site.config";
import { commerceConfig } from "./commerce.config";

/**
 * Backward-compatible site config shim.
 * Canonical AYAD values live in site.config.ts / commerce.config.ts.
 * Legacy fields are kept so existing imports continue to work during migration.
 */
export const siteConfig = {
  ...ayadSiteConfig,
  shortName: "AYAD",
  ogImage: ayadSiteConfig.ogImage || `${ayadSiteConfig.url}/og/default.jpg`,
  ogImage2: ayadSiteConfig.ogImage2 || `${ayadSiteConfig.url}/og/default.jpg`,
  contact: {
    ...ayadSiteConfig.contact,
    phone: ayadSiteConfig.contact.phoneDisplay,
    whatsapp: ayadSiteConfig.contact.whatsapp.number,
    address: [
      ayadSiteConfig.contact.address.line1,
      ayadSiteConfig.contact.address.city,
      ayadSiteConfig.contact.address.district,
      ayadSiteConfig.contact.address.country,
    ]
      .filter(Boolean)
      .join(", "),
  },
  business: {
    currency: ayadSiteConfig.currency.code,
    currencySymbol: ayadSiteConfig.currency.symbol,
    orderPrefix: commerceConfig.orderCodePrefix,
  },
};

export type SiteConfig = typeof siteConfig;
