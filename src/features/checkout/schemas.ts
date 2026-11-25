import { z } from "zod";

export const checkoutSchema = z.object({
  customerName: z.string().min(1, "Name is required"),
  phone: z.string().min(1, "Phone number is required"),
  email: z.string().email("Invalid email").optional().or(z.literal("")),
  addressLine: z.string().min(1, "Address is required"),
  city: z.string().min(1, "City is required"),
  district: z.string().min(1, "District is required"),
  notes: z.string().optional(),
  paymentMethod: z.enum(["cod", "bank_transfer"]),
  whatsappOptIn: z.boolean().default(false),
  idempotencyKey: z.string().optional(),
});

export type CheckoutInput = z.infer<typeof checkoutSchema>;