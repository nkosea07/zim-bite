import { apiRequest } from './apiClient';
import { parseJwtClaims } from './jwt';

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

export const zimbiteApi = {
  login: async (payload: { principal: string; password: string }) => {
    const tokens = await apiRequest<{ accessToken: string; refreshToken: string; expiresIn: number }>(
      '/auth/login',
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
      userId: typeof claims?.sub === 'string' ? claims.sub : payload.principal,
      role: typeof claims?.role === 'string' ? claims.role : 'CUSTOMER'
    } satisfies AuthSession;
  },

  listVendors: () =>
    apiRequest<Vendor[]>('/vendors', { method: 'GET' }, () => [
      {
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001',
        name: 'Sunrise Kitchen',
        city: 'Harare',
        latitude: -17.8292,
        longitude: 31.0522,
        open: true
      },
      {
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002',
        name: 'Morning Plate',
        city: 'Harare',
        latitude: -17.8016,
        longitude: 31.0447,
        open: true
      }
    ]),

  listMenuItems: (vendorId: string) =>
    apiRequest<MenuItem[]>(`/menu/vendors/${vendorId}/items`, { method: 'GET' }, () => [
      {
        id: 'dddddddd-dddd-dddd-dddd-ddddddddddd1',
        vendorId,
        name: 'Classic Sadza Breakfast Bowl',
        category: 'Breakfast Bowls',
        basePrice: 6.5,
        currency: 'USD',
        available: true
      },
      {
        id: 'dddddddd-dddd-dddd-dddd-ddddddddddd2',
        vendorId,
        name: 'Ginger Tea',
        category: 'Drinks',
        basePrice: 1.2,
        currency: 'USD',
        available: true
      }
    ]),

  calculateMeal: (payload: MealCalcRequest) =>
    apiRequest<MealCalcResponse>(
      '/meal-builder/calculate',
      {
        method: 'POST',
        body: JSON.stringify(payload)
      },
      () => {
        const componentTotal = payload.components.reduce((sum, item) => sum + item.quantity * 1.2, 0);
        return {
          totalPrice: Number((3 + componentTotal).toFixed(2)),
          estimatedCalories: 250 + payload.components.reduce((sum, item) => sum + item.quantity * 85, 0),
          available: payload.components.every((item) => item.quantity <= 5)
        };
      }
    ),

  placeOrder: (payload: {
    userId: string;
    vendorId: string;
    currency: 'USD' | 'ZWL';
    items: Array<{ menuItemId: string; quantity: number }>;
  }) =>
    apiRequest<OrderResponse>(
      '/orders',
      {
        method: 'POST',
        body: JSON.stringify(payload)
      },
      () => ({
        orderId: crypto.randomUUID(),
        status: 'PENDING_PAYMENT',
        totalAmount: payload.items.reduce((sum, item) => sum + item.quantity * 5, 0),
        currency: payload.currency
      })
    ),

  initiatePayment: (payload: {
    orderId: string;
    provider: 'ECOCASH' | 'ONEMONEY' | 'CARD' | 'CASH';
    amount: number;
    currency: 'USD' | 'ZWL';
  }) =>
    apiRequest<PaymentResponse>(
      '/payments/initiate',
      {
        method: 'POST',
        headers: { 'Idempotency-Key': `ui-${payload.orderId}` },
        body: JSON.stringify(payload)
      },
      () => ({
        paymentId: crypto.randomUUID(),
        orderId: payload.orderId,
        provider: payload.provider,
        status: 'PENDING',
        amount: payload.amount,
        currency: payload.currency
      })
    )
};
