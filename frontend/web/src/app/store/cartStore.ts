import { create } from 'zustand';

export type CartItem = {
  menuItemId: string;
  name: string;
  quantity: number;
  unitPrice: number;
};

type CartState = {
  vendorId: string | null;
  currency: 'USD' | 'ZWL';
  items: CartItem[];
  addItem: (vendorId: string, item: Omit<CartItem, 'quantity'>) => void;
  updateQuantity: (menuItemId: string, quantity: number) => void;
  clearCart: () => void;
  total: () => number;
};

export const useCartStore = create<CartState>((set, get) => ({
  vendorId: null,
  currency: 'USD',
  items: [],
  addItem: (vendorId, item) =>
    set((state) => {
      const existing = state.items.find((i) => i.menuItemId === item.menuItemId);
      if (state.vendorId && state.vendorId !== vendorId) {
        return { vendorId, items: [{ ...item, quantity: 1 }] };
      }
      if (existing) {
        return {
          vendorId,
          items: state.items.map((i) =>
            i.menuItemId === item.menuItemId ? { ...i, quantity: i.quantity + 1 } : i
          )
        };
      }
      return { vendorId, items: [...state.items, { ...item, quantity: 1 }] };
    }),
  updateQuantity: (menuItemId, quantity) =>
    set((state) => ({
      items:
        quantity <= 0
          ? state.items.filter((i) => i.menuItemId !== menuItemId)
          : state.items.map((i) => (i.menuItemId === menuItemId ? { ...i, quantity } : i))
    })),
  clearCart: () => set({ vendorId: null, items: [] }),
  total: () => get().items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0)
}));
