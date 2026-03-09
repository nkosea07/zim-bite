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

export type Address = {
  id: string;
  label: string;
  line1: string;
  line2?: string;
  city: string;
  area?: string;
  latitude: number;
  longitude: number;
};

export type AddressPayload = Omit<Address, 'id'>;

export type DeliveryTracking = {
  deliveryId: string;
  orderId: string;
  status: string;
  driverName?: string | null;
  driverPhone?: string | null;
  estimatedArrival?: string | null;
  currentLatitude?: number | null;
  currentLongitude?: number | null;
  deliveryLatitude?: number | null;
  deliveryLongitude?: number | null;
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
  principal: string;
  expiresAt: string;
  attemptsRemaining: number;
  status: string;
};

export type OtpVerifyRequest = {
  principal: string;
  otp: string;
};

export type RegisterRequestPayload = {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  password: string;
  role?: string;
};

export type CreateVendorPayload = {
  name: string;
  description?: string;
  phoneNumber: string;
  email: string;
  city: string;
  latitude: number;
  longitude: number;
};

export type VendorDetail = Vendor & {
  description?: string;
  phoneNumber?: string;
  email?: string;
  rating?: number;
  totalOrders?: number;
};

export type VendorStats = {
  ordersToday: number;
  revenueToday: number;
  rating: number;
  totalOrders: number;
};

export type VendorDashboardAnalytics = {
  weeklyOrders: { day: string; count: number }[];
  weeklyRevenue: { day: string; amount: number }[];
  topItems: { name: string; count: number }[];
};

export type AdminOverview = {
  activeVendors: number;
  activeRiders: number;
  ordersToday: number;
  revenueToday: number;
  totalUsers: number;
};

export type RevenueData = {
  period: string;
  amount: number;
};

export type UserProfile = {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  role: string;
};

export type FavoriteItem = MenuItem & {
  vendorName: string;
};

export type Subscription = {
  id: string;
  vendorId: string;
  vendorName: string;
  planType: string;
  status: string;
  nextDeliveryDate?: string;
};

export type VendorReview = {
  id: string;
  customerId: string;
  customerName: string;
  rating: number;
  comment: string;
  createdAt: string;
};

export type RiderDelivery = {
  id: string;
  orderId: string;
  vendorName: string;
  vendorAddress: string;
  customerName: string;
  customerAddress: string;
  status: string;
  estimatedEarning: number;
  createdAt: string;
};

export type ChatMessage = {
  id: string;
  senderId: string;
  senderRole: string;
  content: string;
  timestamp: string;
};

/* ── API client ───────────────────────────────────────────────── */

export const zimbiteApi = {
  /** Register a new account */
  register: (payload: RegisterRequestPayload) =>
    apiRequest<{ status: string }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(payload)
    }),

  /** Step 1: login with principal (email/phone) + password → receive OTP challenge */
  login: (principal: string, password: string) =>
    apiRequest<OtpChallengeResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ principal, password })
    }),

  /** Step 2: verify OTP code → receive tokens */
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

  listAddresses: () =>
    apiRequest<Address[]>('/users/addresses', { method: 'GET' }),

  addAddress: (payload: AddressPayload) =>
    apiRequest<Address>('/users/addresses', {
      method: 'POST',
      body: JSON.stringify(payload)
    }),

  placeOrder: (payload: {
    vendorId: string;
    deliveryAddressId: string;
    currency: 'USD' | 'ZWL';
    items: Array<{ menuItemId: string; quantity: number }>;
    scheduledFor?: string;
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
    }),

  getDeliveryTracking: (orderId: string) =>
    apiRequest<DeliveryTracking>(`/deliveries/orders/${orderId}/tracking`, { method: 'GET' }),

  // ── Vendor CRUD ──────────────────────────────────────────────
  createVendor: (payload: CreateVendorPayload) =>
    apiRequest<VendorDetail>('/vendors', { method: 'POST', body: JSON.stringify(payload) }),

  getVendor: (vendorId: string) =>
    apiRequest<VendorDetail>(`/vendors/${vendorId}`, { method: 'GET' }),

  updateVendor: (vendorId: string, payload: Partial<CreateVendorPayload>) =>
    apiRequest<VendorDetail>(`/vendors/${vendorId}`, { method: 'PATCH', body: JSON.stringify(payload) }),

  getVendorStats: (vendorId: string) =>
    apiRequest<VendorStats>(`/vendors/${vendorId}/stats`, { method: 'GET' }),

  // ── Menu CRUD ────────────────────────────────────────────────
  createMenuItem: (vendorId: string, payload: Omit<MenuItem, 'id' | 'vendorId'>) =>
    apiRequest<MenuItem>(`/menu/vendors/${vendorId}/items`, { method: 'POST', body: JSON.stringify(payload) }),

  updateMenuItem: (vendorId: string, itemId: string, payload: Partial<MenuItem>) =>
    apiRequest<MenuItem>(`/menu/items/${itemId}`, { method: 'PATCH', body: JSON.stringify(payload) }),

  toggleMenuItemAvailability: (vendorId: string, itemId: string, available: boolean) =>
    apiRequest<MenuItem>(`/menu/items/${itemId}/availability`, {
      method: 'PATCH',
      body: JSON.stringify({ available })
    }),

  // ── User / Profile ───────────────────────────────────────────
  getProfile: () =>
    apiRequest<UserProfile>('/users/profile', { method: 'GET' }),

  updateProfile: (payload: Partial<UserProfile>) =>
    apiRequest<UserProfile>('/users/profile', { method: 'PATCH', body: JSON.stringify(payload) }),

  listFavorites: () =>
    apiRequest<FavoriteItem[]>('/users/favorites', { method: 'GET' }),

  getOrderHistory: () =>
    apiRequest<OrderResponse[]>('/orders', { method: 'GET' }),

  // ── Subscriptions ────────────────────────────────────────────
  listSubscriptions: () =>
    apiRequest<Subscription[]>('/subscriptions', { method: 'GET' }),

  // ── Analytics ────────────────────────────────────────────────
  getVendorDashboard: (vendorId: string) =>
    apiRequest<VendorDashboardAnalytics>(`/analytics/vendor/${vendorId}/dashboard`, { method: 'GET' }),

  getAdminOverview: () =>
    apiRequest<AdminOverview>('/analytics/admin/overview', { method: 'GET' }),

  getRevenueTrends: (from?: string, to?: string) => {
    const params = new URLSearchParams();
    if (from) params.set('from', from);
    if (to) params.set('to', to);
    const qs = params.toString();
    return apiRequest<RevenueData[]>(`/analytics/revenue${qs ? `?${qs}` : ''}`, { method: 'GET' });
  },

  // ── Reviews ──────────────────────────────────────────────────
  getVendorReviews: (vendorId: string) =>
    apiRequest<VendorReview[]>(`/vendors/${vendorId}/reviews`, { method: 'GET' }),

  // ── Rider ────────────────────────────────────────────────────
  getAvailableDeliveries: (lat: number, lng: number) => {
    const params = new URLSearchParams({ lat: String(lat), lng: String(lng) });
    return apiRequest<RiderDelivery[]>(`/deliveries/rider/available?${params}`, { method: 'GET' });
  },

  acceptDelivery: (deliveryId: string) =>
    apiRequest<RiderDelivery>(`/deliveries/${deliveryId}/accept`, { method: 'POST' }),

  getActiveDeliveries: () =>
    apiRequest<RiderDelivery[]>('/deliveries/rider/active', { method: 'GET' }),

  updateDeliveryStatus: (deliveryId: string, status: string) =>
    apiRequest<RiderDelivery>(`/deliveries/${deliveryId}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status })
    }),

  getDeliveryChat: (deliveryId: string) =>
    apiRequest<ChatMessage[]>(`/deliveries/${deliveryId}/chat`, { method: 'GET' }),

  // ── Admin Vendors ────────────────────────────────────────────
  listAllVendors: () =>
    apiRequest<VendorDetail[]>('/vendors', { method: 'GET' })
};
