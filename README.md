# Legacy Sports E-Commerce

A full-stack e-commerce web application for **Legacy Sports** (premium shoes and accessories), built with Next.js App Router. The storefront supports product browsing, wishlist/cart flows, WhatsApp-based ordering, and order tracking, with an authenticated admin area for managing catalog, orders, content, and customers.

## Features

### Storefront
- Home page with featured products, testimonials, brand highlights, and WhatsApp order tracking entry points
- Shop listing and product detail pages (`/shop`, `/shop/[slug]`)
- Static/content pages: About, Contact, Wishlist, Order tracking (`/track`)
- SEO helpers including metadata, sitemap, and robots configuration

### Ordering & communication
- WhatsApp-oriented purchase flow and order-related messaging
- Order tracking endpoints and public tracking page
- Email notifications via [Resend](https://resend.com/) (order confirmation, admin notifications, staff welcome)

### Admin
- Admin authentication with [NextAuth](https://authjs.dev/) (credentials-based)
- Admin sections for products, orders, banners, hero content, categories, brands, staff, testimonials, and newsletter
- Product/order management APIs and invoice generation support
- Image uploads to AWS S3 (presigned uploads, optional CloudFront URLs)

## Tech stack

- **Framework:** [Next.js 16](https://nextjs.org/) (App Router), React 19, TypeScript
- **Styling/UI:** Tailwind CSS 4, shadcn/ui, Base UI/Radix primitives, Framer Motion
- **Data/state:** MongoDB + Mongoose, TanStack Query, Zustand
- **Forms/validation:** React Hook Form, Zod
- **Auth:** NextAuth v5 (beta)
- **Integrations:** AWS S3, Resend, WhatsApp links/config
- **Other:** next-themes, `@react-pdf/renderer` (invoicing)

## Prerequisites

- [Node.js](https://nodejs.org/) (LTS recommended)
- [pnpm](https://pnpm.io/) (recommended; repository includes `pnpm-lock.yaml`)
- A MongoDB database (local or hosted)
- Accounts/credentials for enabled integrations as needed (AWS S3, Resend, etc.)

## Getting started

1. **Install dependencies**

   ```bash
   pnpm install
   ```

2. **Configure environment variables**

   Create a `.env.local` file in the project root. Required values depend on which features you use; common variables referenced by the app include:

   | Variable | Purpose |
   | --- | --- |
   | `MONGODB_URI` | MongoDB connection string |
   | `AUTH_SECRET` or `NEXTAUTH_SECRET` | NextAuth secret for session/JWT signing |
   | `NEXTAUTH_URL` | Canonical app URL (used in emails/admin links) |
   | `NEXT_PUBLIC_SITE_URL` | Public site URL |
   | `NEXT_PUBLIC_SITE_NAME` | Store display name |
   | `NEXT_PUBLIC_SITE_DESCRIPTION` | Default site description |
   | `NEXT_PUBLIC_SITE_EMAIL` | Contact email |
   | `NEXT_PUBLIC_WHATSAPP_NUMBER` | WhatsApp number used for contact/orders |
   | `NEXT_PUBLIC_SHOP_ADDRESS` | Displayed shop address |
   | `NEXT_PUBLIC_CURRENCY` / `NEXT_PUBLIC_CURRENCY_SYMBOL` | Currency formatting |
   | `NEXT_PUBLIC_ORDER_PREFIX` | Order number prefix |
   | `RESEND_API_KEY` | Resend API key (transactional email) |
   | `RESEND_FROM_EMAIL` | Optional sender override for outgoing email |
   | `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET_NAME` | S3 uploads/deletes |
   | `NEXT_PUBLIC_CLOUDFRONT_URL` | Optional CDN base URL for uploaded assets |

   > Note: there is no committed `.env.example` in this repository. Review [`src/config/site.ts`](src/config/site.ts) and integration modules in [`src/lib/`](src/lib) for additional or feature-specific variables.

3. **Run the development server**

   ```bash
   pnpm dev
   ```

   Open [http://localhost:3000](http://localhost:3000) to view the app.

## Available scripts

| Command | Description |
| --- | --- |
| `pnpm dev` | Start Next.js development server |
| `pnpm build` | Create a production build |
| `pnpm start` | Start the production server |
| `pnpm lint` | Run ESLint |
| `pnpm clean` | Remove the `.next` build directory |

### Maintenance scripts

The [`scripts/`](scripts) directory contains TypeScript utilities for local maintenance and seeding (for example: admin/banner seeding, product/testimonial seeds, migrations, smoke tests). These scripts may require environment variables (typically from `.env.local`) and a TypeScript runner such as `ts-node`. Run them according to your local setup, for example:

```bash
pnpm exec ts-node scripts/seed-admin.ts
```

> Some scripts (e.g. `seed-admin`) expect variables like `MONGODB_URI`, `ADMIN_EMAIL`, and `ADMIN_PASSWORD`.

## Project structure

```text
src/
  app/
    (public)/        # Storefront routes (home, shop, about, contact, track, wishlist)
    (admin)/         # Protected admin pages
    (admin-auth)/    # Admin login
    api/             # Route handlers (auth, products, orders, upload, etc.)
  components/        # UI and feature components
  config/            # Site configuration
  hooks/             # Reusable hooks
  lib/               # Auth, DB, integrations, utilities
  store/             # Client state stores
  types/             # Shared TypeScript types
scripts/             # Seed/migration/smoke-test utilities
public/              # Static assets
```

For a more detailed historical design/reference document, see [`PROJECT_STRUTURE.md`](PROJECT_STRUTURE.md).

## Deployment

Build and run with:

```bash
pnpm build
pnpm start
```

Deploy on any platform that supports Next.js (for example, [Vercel](https://vercel.com/)). Ensure all required environment variables and external services (MongoDB, S3, Resend, auth secrets, and public site URLs) are configured in the target environment. Refer to the [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for platform-specific guidance.
