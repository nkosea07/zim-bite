import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type AuthState = {
  userId: string | null;
  token: string | null;
  role: string | null;
  setSession: (payload: { userId: string; token: string; role: string }) => void;
  clearSession: () => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      userId: null,
      token: null,
      role: null,
      setSession: ({ userId, token, role }) => set({ userId, token, role }),
      clearSession: () => set({ userId: null, token: null, role: null })
    }),
    { name: 'zimbite-auth' }
  )
);
