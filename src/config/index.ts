export { siteConfig } from "./site.config";
export type { SiteConfig } from "./site.config";
export { commerceConfig } from "./commerce.config";
export type { CommerceConfig } from "./commerce.config";
export { notificationsConfig } from "./notifications.config";
export type { NotificationsConfig } from "./notifications.config";
export { navigationConfig } from "./navigation.config";
export type { NavigationConfig } from "./navigation.config";
export { seoConfig } from "./seo.config";
export type { SeoConfig } from "./seo.config";
export { featuresConfig } from "./features.config";
export type { FeaturesConfig } from "./features.config";
export { validateConfig, AllConfigSchema } from "./schema";
export type { SiteConfigSchema, CommerceConfigSchema, NotificationsConfigSchema, NavigationConfigSchema, SeoConfigSchema, FeaturesConfigSchema } from "./schema";

import { siteConfig } from "./site.config";
import { commerceConfig } from "./commerce.config";
import { notificationsConfig } from "./notifications.config";
import { navigationConfig } from "./navigation.config";
import { seoConfig } from "./seo.config";
import { featuresConfig } from "./features.config";
import { validateConfig } from "./schema";

validateConfig({
  site: siteConfig,
  commerce: commerceConfig,
  notifications: notificationsConfig,
  navigation: navigationConfig,
  seo: seoConfig,
  features: featuresConfig,
});