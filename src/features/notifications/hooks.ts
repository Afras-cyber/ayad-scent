"use client";

export function useNotifications() {
  return {
    enqueueNotification: async (orderId: string, event: string, payload: Record<string, unknown>) => {
      const { enqueueNotification } = await import("./actions");
      return enqueueNotification(orderId, event as any, payload);
    },
  };
}