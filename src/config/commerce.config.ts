import type { CommerceConfig } from "./schema";

export const commerceConfig = {
  orderCodePrefix: "AYD",
  invoicePrefix: "INV",
  receiptPrefix: "RCT",
  maxQtyPerLine: 20,
  maxLinesPerOrder: 30,
  freeDeliveryThresholdLkr: 5000,
  paymentMethods: ["cod", "bank_transfer"] as const,
  bankTransfer: {
    bankName: "Demo Bank",
    accountName: "AYAD Scent Lab",
    accountNumber: "0123456789",
    branch: "Colombo Main Branch",
  },
  deliveryEstimate: {
    colombo: "1–2 days",
    other: "2–4 days",
  },
} as const satisfies CommerceConfig;