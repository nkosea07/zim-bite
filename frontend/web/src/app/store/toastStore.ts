import { create } from 'zustand';

export type ToastVariant = 'default' | 'success' | 'error' | 'warning';

export type Toast = {
  id: string;
  title: string;
  description?: string;
  variant?: ToastVariant;
};

type ToastState = {
  toasts: Toast[];
  push: (toast: Omit<Toast, 'id'>) => void;
  dismiss: (id: string) => void;
};

export const useToastStore = create<ToastState>((set) => ({
  toasts: [],
  push: (toast) => {
    const id = crypto.randomUUID();
    set((s) => ({ toasts: [...s.toasts, { ...toast, id }] }));
    setTimeout(() => {
      set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }));
    }, 4500);
  },
  dismiss: (id) => set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }))
}));

/** Convenience helpers */
export const toast = {
  show:    (title: string, description?: string) => useToastStore.getState().push({ title, description }),
  success: (title: string, description?: string) => useToastStore.getState().push({ title, description, variant: 'success' }),
  error:   (title: string, description?: string) => useToastStore.getState().push({ title, description, variant: 'error' }),
  warning: (title: string, description?: string) => useToastStore.getState().push({ title, description, variant: 'warning' })
};
