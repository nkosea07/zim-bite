import { apiRequest } from './apiClient';
import { parseJwtClaims } from './jwt';

/* ── Domain types ─────────────────────────────────────────────── */

export type Vendor = {
  id: string;
  name: string;
  city: string;
  latitude: number;
  longitude: number;
  open: boolean;
};

export type MenuItem = {
  id: string;
  vendorId: string;
  name: string;
  category: string;
  basePrice: number;
  currency: 'USD' | 'ZWL';
  available: boolean;
};

export type MealCalcRequest = {
  vendorId: string;
  baseItemId: string;
  components: Array<{ componentId: string; quantity: number }>;
};

export type MealCalcResponse = {
  totalPrice: number;
  estimatedCalories: number;
  available: boolean;
};

export type OrderResponse = {
  orderId: string;
  status: string;
  totalAmount: number;
  currency: 'USD' | 'ZWL';
  scheduledFor?: string | null;
};

export type PaymentResponse = {
  paymentId: string;
  orderId: string;
  provider: string;
  status: string;
  amount: number;
  currency: 'USD' | 'ZWL';
};

export type AuthSession = {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  userId: string;
  role: string;
};

export type OtpChallengeResponse = {
  challengeId: string;
  maskedPhone: string;
  expiresIn: number;
};

export type OtpVerifyRequest = {
  challengeId: string;
  otp: string;
};

/* ── API client ───────────────────────────────────────────────── */

export const zimbiteApi = {
  /** Step 1 of OTP login: register/login phone → receive OTP */
  sendOtp: (phone: string) =>
    apiRequest<OtpChallengeResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ phone })
    }),

  /** Step 2 of OTP login: verify code → receive tokens */
  verifyOtp: async (payload: OtpVerifyRequest): Promise<AuthSession> => {
    const tokens = await apiRequest<{ accessToken: string; refreshToken: string; expiresIn: number }>(
      '/auth/verify-otp',
      {
        method: 'POST',
        body: JSON.stringify(payload)
      }
    );

    const claims = parseJwtClaims(tokens.accessToken);
    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
      userId: typeof claims?.sub === 'string' ? claims.sub : '',
      role: typeof claims?.role === 'string' ? claims.role : 'CUSTOMER'
    };
  },

  listVendors: () =>
    apiRequest<Vendor[]>('/vendors', { method: 'GET' }),

  listMenuItems: (vendorId: string) =>
    apiRequest<MenuItem[]>(`/menu/vendors/${vendorId}/items`, { method: 'GET' }),

  calculateMeal: (payload: MealCalcRequest) =>
    apiRequest<MealCalcResponse>('/meal-builder/calculate', {
      method: 'POST',
      body: JSON.stringify(payload)
    }),

  listOrders: () =>
    apiRequest<OrderResponse[]>('/orders', { method: 'GET' }),

  placeOrder: (payload: {
    userId: string;
    vendorId: string;
    currency: 'USD' | 'ZWL';
    items: Array<{ menuItemId: string; quantity: number }>;
  }) =>
    apiRequest<OrderResponse>('/orders', {
      method: 'POST',
      body: JSON.stringify(payload)
    }),

  initiatePayment: (payload: {
    orderId: string;
    provider: 'ECOCASH' | 'ONEMONEY' | 'CARD' | 'CASH';
    amount: number;
    currency: 'USD' | 'ZWL';
  }) =>
    apiRequest<PaymentResponse>('/payments/initiate', {
      method: 'POST',
      headers: { 'Idempotency-Key': `ui-${payload.orderId}` },
      body: JSON.stringify(payload)
    })
};
