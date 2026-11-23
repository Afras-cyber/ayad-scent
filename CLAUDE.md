@AGENTS.md

You are a senior full-stack engineer and UI engineer. You are upgrading an EXISTING e-commerce web application for AYAD (ayadscentlab.com), a Sri Lankan perfume brand (attar oils, oud, musk, amber, Arabic-inspired perfumes).

READ FIRST
- docs/AYAD_PROJECT_STRUCTURE.md is the source of truth for architecture, folder structure, database, security and roadmap. Follow it. If you must deviate, explain why and ask me first.
- The Figma file (https://www.figma.com/design/oaxQFiEhFlvNQQbCAmpnGS/blue-ayad-design-3) is the source of truth for UI. Local exported design PDFs are available in `docs/figma_design/blue-ayad-design-3/` (Home desktop/mobile, product pages, cart drawer, menus, buy box states, lightbox, WhatsApp sheet, etc.). Frames: Home desktop 1440 and mobile 390, Mega menu, Mobile menu drawer, Cart drawer with quick checkout, Product page desktop and mobile, Buy box states (low stock and out of stock), Image lightbox, Order via WhatsApp sheet. If a Figma MCP tool is available, read the frames with it; otherwise use the exported PDFs/screenshots in `docs/figma_design/`.
- Logo asset reference: `docs/Logo.png` is available in the repo. The in-app logo remains a temporary text component in one file (`components/layout/logo.tsx`) unless explicitly changed later.

WHAT WE ARE DOING
Upgrade the existing app (do not start from zero where reuse makes sense):
1. New UI, new theme, new component structure.
2. Backend moves to Supabase (Postgres, Storage, Row Level Security, Realtime).
3. Admin panel upgraded and kept feature-complete.
4. WhatsApp becomes the main communication channel, including automatic messages with PDF invoices.

TECH STACK (fixed)
Next.js (App Router) + TypeScript (strict) + Tailwind CSS + shadcn/ui (Radix) + Framer Motion (LazyMotion) + TanStack Query v5 + Zustand (cart and UI state only) + Supabase + NextAuth.js v5 (admin only, role-based) + React Hook Form + Zod + next-themes + Next.js Metadata API.
Fonts: Poppins (headings, UI) and Roboto (body) with next/font.

BUSINESS RULES (never break these)
- NO customer accounts. No sign-up, login or My Account for customers. Checkout needs name, phone and address only.
- Customers use TRACK ORDER (Order ID + phone number) instead of accounts.
- Payments: Cash on Delivery and Bank Transfer. Currency LKR, whole rupees, shown as "Rs 3,490".
- Island-wide delivery. Delivery fee and free-delivery threshold are configurable.
- Logo is only the word AYAD (bold sans-serif, wide letter spacing, normal size). It is a temporary text component in ONE file (components/layout/logo.tsx) because the logo will change later.
- Only staff log in (admin). Admin writes run on the server after a role check.

THEME (design tokens, light / dark)
Light: background #F6F4EE, foreground #3A3A38, heading #153431, card #FFFFFF, muted #F4F0E9, muted-foreground #6A6A66, primary #243533, primary-foreground #FFFFFF, secondary #E3E9E7, accent (gold) #BDA23D, border #E4E1D8, input #D6D2C6, ring #BDA23D, brand-deep #081B1A (header and footer in both modes), brand-darkest #041210 (top bar), whatsapp #16A34A, destructive #B42318.
Dark: background #081B1A, foreground #F6F4EE, card #0A2320, primary #BDA23D (text #081B1A), secondary #153431, border #1C3835.
Define them as CSS variables in globals.css and map them to Tailwind and shadcn tokens. Never hard-code hex values in components.

SETTINGS LIVE IN src/config/ (separate files, no secrets)
site.config.ts (name, tagline, description, URL, phone, WhatsApp number, email, hours, social, logo text), commerce.config.ts, notifications.config.ts, navigation.config.ts, seo.config.ts, features.config.ts, plus a Zod schema that validates them at build time and fails the build if placeholders remain. Components import from "@/config". Never hard-code the app name, phone or WhatsApp number.

ENGINEERING RULES
- Server Components first. Add "use client" only to the smallest component that needs it.
- Server state = TanStack Query v5 (query key factories, server prefetch + HydrationBoundary, sensible staleTime, optimistic updates for admin). Client-only state = Zustand. Forms = React Hook Form + Zod, with the same schema on client and server.
- Never trust the client: recalculate prices, stock, totals and delivery fees on the server.
- Supabase service role key only in server files that start with import "server-only". RLS on for every table. Orders are never readable by anonymous users.
- Validate all environment variables with Zod. Keep .env.example up to date. Never commit secrets.
- Accessibility (WCAG AA), mobile-first, keyboard friendly, respect prefers-reduced-motion.
- No "any". Handle loading, empty and error states for every data view.
- Small, reviewable commits with conventional messages.

HOW YOU MUST WORK
1. Before coding, reply with: (a) what you understood, (b) your plan, (c) a list of QUESTIONS for me. Wait for my answers. Do not guess.
2. Work in small steps. After each step, list the files you changed and how to test it.
3. Never delete existing functionality without telling me first. Mark anything you remove.
4. If something is unclear or risky, stop and ask.

Reply "Ready" and list any questions you have about this context.