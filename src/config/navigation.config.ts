import type { NavigationConfig } from "./schema";

export const navigationConfig = {
  header: [
    { label: "Shop", href: "/shop" },
    { label: "Collections", href: "/collections" },
    { label: "About", href: "/about" },
    { label: "Contact", href: "/contact" },
    { label: "Track Order", href: "/track-order" },
  ],
  footer: [
    { label: "About", href: "/about" },
    { label: "Contact", href: "/contact" },
    { label: "Track Order", href: "/track-order" },
    { label: "Delivery & Returns", href: "/delivery-returns" },
    { label: "Privacy", href: "/privacy" },
    { label: "Terms", href: "/terms" },
  ],
  megaMenu: [
    {
      label: "Oud",
      href: "/collections/oud",
      items: [
        { label: "All Oud", href: "/collections/oud" },
        { label: "Oud Oils", href: "/collections/oud?type=oil" },
        { label: "Oud Sprays", href: "/collections/oud?type=spray" },
      ],
    },
    {
      label: "Attar Oils",
      href: "/collections/attar-oils",
      items: [
        { label: "All Attar Oils", href: "/collections/attar-oils" },
        { label: "Concentrated Attars", href: "/collections/attar-oils?type=concentrated" },
      ],
    },
    {
      label: "Spray Perfumes",
      href: "/collections/spray-perfumes",
      items: [
        { label: "All Sprays", href: "/collections/spray-perfumes" },
        { label: "50ml Sprays", href: "/collections/spray-perfumes?size=50ml" },
        { label: "100ml Sprays", href: "/collections/spray-perfumes?size=100ml" },
      ],
    },
    {
      label: "Musk & Amber",
      href: "/collections/musk-amber",
      items: [
        { label: "All Musk & Amber", href: "/collections/musk-amber" },
      ],
    },
    {
      label: "Gift Sets",
      href: "/collections/gift-sets",
      items: [
        { label: "All Gift Sets", href: "/collections/gift-sets" },
      ],
    },
  ],
} as const satisfies NavigationConfig;