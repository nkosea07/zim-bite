import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type AuthState = {
  userId: string | null;
  token: string | null;
  refreshToken: string | null;
  role: string | null;
  setSession: (payload: { userId: string; token: string; role: string; refreshToken?: string | null }) => void;
  clearSession: () => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      userId: null,
      token: null,
      refreshToken: null,
      role: null,
      setSession: ({ userId, token, role, refreshToken = null }) => set({ userId, token, role, refreshToken }),
      clearSession: () => set({ userId: null, token: null, refreshToken: null, role: null })
    }),
    { name: 'zimbite-auth' }
  )
);
