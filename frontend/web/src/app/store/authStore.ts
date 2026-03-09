import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type AuthState = {
  userId: string | null;
  token: string | null;
  refreshToken: string | null;
  role: string | null;
  vendorId: string | null;
  setSession: (payload: { userId: string; token: string; role: string; refreshToken?: string | null; vendorId?: string | null }) => void;
  setVendorId: (vendorId: string) => void;
  clearSession: () => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      userId: null,
      token: null,
      refreshToken: null,
      role: null,
      vendorId: null,
      setSession: ({ userId, token, role, refreshToken = null, vendorId = null }) =>
        set({ userId, token, role, refreshToken, vendorId }),
      setVendorId: (vendorId) => set({ vendorId }),
      clearSession: () => set({ userId: null, token: null, refreshToken: null, role: null, vendorId: null })
    }),
    { name: 'zimbite-auth' }
  )
);
