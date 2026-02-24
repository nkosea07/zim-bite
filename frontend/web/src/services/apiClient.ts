import { useAuthStore } from '../app/store/authStore';

const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/api/v1';
const ENABLE_FALLBACK = (import.meta.env.VITE_ENABLE_API_FALLBACK ?? 'true') === 'true';

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {},
  fallbackFactory?: () => T
): Promise<T> {
  const { token } = useAuthStore.getState();
  const headers = new Headers(init.headers ?? {});
  headers.set('Content-Type', 'application/json');
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  try {
    const response = await fetch(`${BASE_URL}${path}`, { ...init, headers });
    if (!response.ok) {
      throw new Error(`Request failed ${response.status}`);
    }
    return (await response.json()) as T;
  } catch (error) {
    if (ENABLE_FALLBACK && fallbackFactory) {
      return fallbackFactory();
    }
    throw error;
  }
}
