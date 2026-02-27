import { useAuthStore } from '../app/store/authStore';

const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/api/v1';

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {}
): Promise<T> {
  const { token } = useAuthStore.getState();
  const headers = new Headers(init.headers ?? {});
  headers.set('Content-Type', 'application/json');
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  const response = await fetch(`${BASE_URL}${path}`, { ...init, headers });
  if (!response.ok) {
    throw new Error(`Request failed ${response.status}`);
  }
  return (await response.json()) as T;
}
