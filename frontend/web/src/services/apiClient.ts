import { useAuthStore } from '../app/store/authStore';
import { parseJwtClaims } from './jwt';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1';

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

async function extractErrorMessage(response: Response): Promise<string> {
  try {
    const body = await response.json();
    if (typeof body?.message === 'string') return body.message;
    if (typeof body?.error === 'string') return body.error;
  } catch { /* non-JSON body */ }
  return `Request failed (${response.status})`;
}

let refreshPromise: Promise<boolean> | null = null;

async function attemptTokenRefresh(): Promise<boolean> {
  const { refreshToken, clearSession, setSession } = useAuthStore.getState();
  if (!refreshToken) return false;

  try {
    const response = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    });
    if (!response.ok) {
      clearSession();
      return false;
    }
    const tokens: { accessToken: string; refreshToken: string; expiresIn: number } =
      await response.json();
    const claims = parseJwtClaims(tokens.accessToken);
    setSession({
      userId: typeof claims?.sub === 'string' ? claims.sub : '',
      token: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      role: typeof claims?.role === 'string' ? claims.role : 'CUSTOMER'
    });
    return true;
  } catch {
    clearSession();
    return false;
  }
}

export async function apiRequest<T>(
  path: string,
  init: RequestInit = {}
): Promise<T> {
  const makeRequest = () => {
    const { token } = useAuthStore.getState();
    const headers = new Headers(init.headers ?? {});
    headers.set('Content-Type', 'application/json');
    if (token) {
      headers.set('Authorization', `Bearer ${token}`);
    }
    return fetch(`${BASE_URL}${path}`, { ...init, headers });
  };

  let response = await makeRequest();

  // On 401, attempt a single token refresh and retry
  if (response.status === 401 && useAuthStore.getState().refreshToken) {
    // Deduplicate concurrent refresh attempts
    if (!refreshPromise) {
      refreshPromise = attemptTokenRefresh().finally(() => { refreshPromise = null; });
    }
    const refreshed = await refreshPromise;
    if (refreshed) {
      response = await makeRequest();
    }
  }

  if (!response.ok) {
    const msg = await extractErrorMessage(response);
    throw new ApiError(response.status, msg);
  }

  return (await response.json()) as T;
}
