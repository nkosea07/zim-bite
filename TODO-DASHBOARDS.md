# TODO: Role-Based Registration & Dashboards

## Context
Registration currently hardcodes all users as CUSTOMER. No vendor, rider, or admin dashboards exist on the web frontend. This plan adds role selection during registration, four role-specific dashboards, and role-based routing. SYSTEM_ADMIN accounts are SQL-only.

## Roles (from `shared/common-security/.../Role.java`)
- **CUSTOMER** — End users ordering breakfast
- **VENDOR_ADMIN** — Vendor owner with full permissions
- **VENDOR_STAFF** — Vendor employee (scoped permissions, not self-registrable)
- **RIDER** — Delivery driver
- **SYSTEM_ADMIN** — Platform admin (SQL-only creation)

## Files to Modify
| File | Change |
|------|--------|
| `services/auth-service/.../model/dto/RegisterRequest.java` | Add optional `role` field |
| `services/auth-service/.../service/AuthService.java` | Validate role (only CUSTOMER/VENDOR_ADMIN/RIDER allowed) |
| `frontend/web/src/services/zimbiteApi.ts` | Add ~20 new API methods + types for dashboards |
| `frontend/web/src/app/store/authStore.ts` | Add `vendorId` field |
| `frontend/web/src/pages/auth/RegisterPage.tsx` | Role selector cards + conditional vendor fields |
| `frontend/web/src/pages/auth/LoginPage.tsx` | Role-based redirect after OTP |
| `frontend/web/src/pages/account/AccountPage.tsx` | Transform into tabbed customer dashboard |
| `frontend/web/src/components/layout/AppShell.tsx` | Role-aware nav (hide cart for non-customers) |
| `frontend/web/src/app/router.tsx` | Add dashboard routes with RequireAuth guards |
| `frontend/web/src/styles/app.css` | Dashboard layout, stat cards, bar charts, toggles |

## New Files
| File | Purpose |
|------|---------|
| `frontend/web/src/components/auth/RequireAuth.tsx` | Route guard — redirects unauthenticated or wrong-role users |
| `frontend/web/src/pages/vendor-dashboard/VendorDashboardPage.tsx` | Vendor admin dashboard |
| `frontend/web/src/pages/admin-dashboard/AdminDashboardPage.tsx` | System admin dashboard |
| `frontend/web/src/pages/rider-dashboard/RiderDashboardPage.tsx` | Rider dashboard |

---

## Implementation Steps

### Step 1: Backend — Allow role on registration
- `RegisterRequest.java`: Add `String role` (nullable, no @NotBlank)
- `AuthService.java`: If `role` is null → CUSTOMER. If "VENDOR_ADMIN" or "RIDER" → allow. SYSTEM_ADMIN/VENDOR_STAFF → 400 Bad Request.
- Rebuild auth-service: `docker compose up -d --build auth-service`

### Step 2: Frontend API client — New endpoints + types
Add to `zimbiteApi.ts`:
- **Types**: `CreateVendorPayload`, `VendorDetail`, `VendorStats`, `VendorDashboardAnalytics`, `AdminOverview`, `RevenueData`, `UserProfile`, `FavoriteItem`, `Subscription`, `VendorReview`, `DeliveryAvailable`, `DeliveryActive`
- **Vendor CRUD**: `createVendor`, `getVendor`, `updateVendor`, `getVendorStats`
- **Menu CRUD**: `createMenuItem`, `updateMenuItem`, `toggleMenuItemAvailability`
- **User**: `getProfile`, `updateProfile`, `listFavorites`, `getOrderHistory`
- **Subscriptions**: `listSubscriptions`
- **Analytics**: `getVendorDashboard`, `getAdminOverview`, `getRevenueTrends`
- **Reviews**: `getVendorReviews`
- **Rider**: `getAvailableDeliveries`, `acceptDelivery`, `getActiveDeliveries`, `updateDeliveryStatus`, `getDeliveryChat`
- Add `role` to `RegisterRequestPayload`

### Step 3: Auth store — Add vendorId
- Add `vendorId: string | null` to authStore state, setSession, clearSession
- After login as VENDOR_ADMIN, fetch vendor list to discover vendorId and store it

### Step 4: RequireAuth component
- New `RequireAuth.tsx`: checks `userId` (redirect to login if missing) and `role` against `allowedRoles` (redirect to role-appropriate dashboard if wrong role)

### Step 5: Registration page — Role selector + vendor fields
- Three clickable cards at top: 🍳 Customer / 🏪 Vendor / 🚴 Rider (reuse `.payment-card` CSS pattern)
- When VENDOR_ADMIN selected, show extra fields: business name, description, phone, city, lat/lng
- On submit for VENDOR_ADMIN: register with `role: 'VENDOR_ADMIN'`, redirect to login
- After vendor logs in without a vendorId → show "Complete Vendor Setup" flow calling `createVendor`
- RIDER registration: just register with `role: 'RIDER'`, redirect to login

### Step 6: Login page — Role-based redirect
- After OTP verification, redirect based on role:
  - VENDOR_ADMIN → `/vendor-dashboard`
  - SYSTEM_ADMIN → `/admin-dashboard`
  - RIDER → `/rider-dashboard`
  - CUSTOMER → `/account`
- For VENDOR_ADMIN: fetch vendor to store vendorId in auth store

### Step 7: CSS additions
Add to `app.css`:
- `.dashboard-layout` — sidebar + main grid (stacks on mobile as horizontal scroll tabs)
- `.dash-nav-item` / `.dash-nav-item.active` — sidebar nav buttons
- `.stat-grid` + `.stat-card` — metric cards with icon, value, label
- `.bar-chart` / `.bar-col` / `.bar` — CSS-only bar charts (no library)
- `.data-row` — table-like rows for orders/items
- `.toggle` / `.toggle.on` — availability switch
- `.form-textarea` — multiline input

### Step 8: Customer dashboard (enhance AccountPage)
Sidebar sections: Overview | Orders | Subscriptions | Favorites | Addresses | Settings

- **Overview**: Profile card + stat cards (total orders, active subscriptions, saved addresses) + 3 recent orders
- **Orders**: Full order history with status timeline (reuse patterns from OrdersPage)
- **Subscriptions**: List with vendor name, plan type badge, status, next delivery date
- **Favorites**: Grid of saved menu items with "Order Again" CTA
- **Addresses**: Existing address list + add address form
- **Settings**: Editable profile form (name, email, phone) with save mutation

### Step 9: Vendor dashboard (new page)
Sidebar sections: Overview | Orders | Menu | Analytics | Reviews | Settings

- **Overview**: 4 stat cards (orders today, revenue today, rating, total orders) + 5 recent orders
- **Orders**: Order list for this vendor with status badges, amounts, timestamps
- **Menu**: Category-tabbed item grid with availability toggles + "Add Item" inline form + edit capability
- **Analytics**: CSS bar charts (weekly orders, weekly revenue) + top selling items list
- **Reviews**: Customer review cards with rating stars, comment, date
- **Settings**: Vendor profile form (name, description, phone, email, location) with save

### Step 10: Admin dashboard (new page)
Sidebar sections: Overview | Vendors | Users | Analytics | Settings

- **Overview**: 5 stat cards (active vendors, active riders, orders today, revenue today) + quick action links
- **Vendors**: Vendor list cards with name, city, status badge, expandable stats
- **Users**: Placeholder with empty state ("User management coming soon")
- **Analytics**: Revenue trend bar chart + summary stats
- **Settings**: Placeholder

### Step 11: Rider dashboard (new page)
Sidebar sections: Overview | Available Deliveries | Active Delivery | Earnings | Settings

- **Overview**: Stat cards (deliveries today, active delivery status, earnings today) + current active delivery card
- **Available Deliveries**: List of available deliveries near rider (GET /deliveries/rider/available?lat&lng) with accept button
- **Active Delivery**: Current delivery details (vendor, customer, addresses, status), status update buttons (PICKED_UP → DELIVERED), chat link
- **Earnings**: Delivery history with earnings summary, daily breakdown
- **Settings**: Profile form (name, phone, vehicle info)

### Step 12: Router + AppShell wiring
- Router: Add `/vendor-dashboard` (VENDOR_ADMIN), `/admin-dashboard` (SYSTEM_ADMIN), `/rider-dashboard` (RIDER), wrap `/account` with RequireAuth
- AppShell nav per role:
  - CUSTOMER: Vendors, Meal Builder, Orders, Account + cart button
  - VENDOR_ADMIN: Dashboard, Orders (no cart)
  - RIDER: Dashboard (no cart)
  - SYSTEM_ADMIN: Dashboard (no cart)

---

## Existing Backend Endpoints Available

### Auth Service (port 8081)
- POST `/api/v1/auth/register` — {firstName, lastName, email, phoneNumber, password}
- POST `/api/v1/auth/login` — {principal, password} → OTP challenge
- POST `/api/v1/auth/verify-otp` — {principal, otp} → tokens
- POST `/api/v1/auth/refresh` — {refreshToken} → new tokens

### Vendor Service (port 8083)
- GET `/api/v1/vendors` — List vendors (supports lat, lng, radius_km params)
- POST `/api/v1/vendors` — Create vendor {ownerUserId, name, phoneNumber, description, latitude, longitude}
- GET `/api/v1/vendors/{id}` — Vendor details
- PATCH `/api/v1/vendors/{id}` — Update vendor
- GET `/api/v1/vendors/{id}/stats` — {ordersToday, revenue, rating, totalOrders}
- GET/POST `/api/v1/vendors/{id}/reviews` — Reviews CRUD

### Menu Service (port 8084)
- GET `/api/v1/menu/vendors/{vendorId}/items` — List items
- GET `/api/v1/menu/vendors/{vendorId}/categories` — List categories
- POST `/api/v1/menu/vendors/{vendorId}/items` — Create item
- PATCH `/api/v1/menu/items/{itemId}` — Update item
- PATCH `/api/v1/menu/items/{itemId}/availability` — Toggle availability

### Order Service (port 8086)
- POST `/api/v1/orders` — Place order
- GET `/api/v1/orders` — List orders (filtered by X-User-Id header)
- GET `/api/v1/orders/{id}` — Order details
- GET `/api/v1/orders/{id}/status` — Order status timeline
- POST `/api/v1/orders/{id}/cancel` — Cancel order

### Delivery Service (port 8088)
- GET `/api/v1/deliveries/rider/available?lat&lng` — Available deliveries near location
- POST `/api/v1/deliveries/{id}/accept` — Rider accepts delivery
- GET `/api/v1/deliveries/rider/active` — Rider's active deliveries
- PATCH `/api/v1/deliveries/{id}/status` — Update status {status: PICKED_UP|DELIVERED}
- GET `/api/v1/deliveries/orders/{orderId}/tracking` — Tracking info
- GET `/api/v1/deliveries/{id}/chat` — Chat history
- WebSocket: `/ws` (STOMP+SockJS), topics: `/topic/delivery/{id}/location`, `/topic/chat/{deliveryId}`

### Analytics Service (port 8090)
- GET `/api/v1/analytics/vendor/{vendorId}/dashboard` — {ordersToday, revenueToday, averagePrepMinutes, averageRating}
- GET `/api/v1/analytics/admin/overview` — {activeVendors, activeRiders, ordersToday, platformGrossRevenueToday}
- GET `/api/v1/analytics/revenue?from&to&currency` — Revenue time series

### User Service (port 8082)
- GET/PATCH `/api/v1/users/profile`
- GET/POST `/api/v1/users/addresses`
- GET/POST `/api/v1/users/favorites`
- GET `/api/v1/users/order-history`

### Subscription Service (port 8091)
- POST/GET `/api/v1/subscriptions`
- GET `/api/v1/subscriptions/{id}`
- POST `/api/v1/subscriptions/{id}/pause|resume|cancel`

### Payment Service (port 8087)
- POST `/api/v1/payments/initiate` — Requires Idempotency-Key header
- POST `/api/v1/payments/refunds/{paymentId}` — Refund

---

## Gateway RBAC Rules (from JwtAuthenticationFilter.java)
```
POST /api/v1/vendors/**          → VENDOR_ADMIN, SYSTEM_ADMIN
PATCH /api/v1/vendors/**         → VENDOR_ADMIN, SYSTEM_ADMIN
GET /api/v1/vendors/*/stats      → VENDOR_ADMIN, VENDOR_STAFF, SYSTEM_ADMIN
PATCH /api/v1/deliveries/**      → RIDER, SYSTEM_ADMIN
POST /api/v1/payments/refunds/** → VENDOR_ADMIN, SYSTEM_ADMIN
GET /api/v1/analytics/admin/**   → SYSTEM_ADMIN
GET /api/v1/analytics/**         → VENDOR_ADMIN, VENDOR_STAFF, SYSTEM_ADMIN
```

---

## Verification Checklist
- [ ] `npx tsc --noEmit` — clean compile
- [ ] Register as CUSTOMER → login → sees customer dashboard at /account
- [ ] Register as VENDOR_ADMIN → login → vendor setup → sees vendor dashboard
- [ ] Register as RIDER → login → sees rider dashboard
- [ ] Login as SYSTEM_ADMIN (seeded SQL) → sees admin dashboard
- [ ] Customer cannot access /vendor-dashboard, /admin-dashboard, /rider-dashboard
- [ ] Vendor cannot access /admin-dashboard or /rider-dashboard
- [ ] Rider cannot access /vendor-dashboard or /admin-dashboard
- [ ] Unauthenticated users redirected to login for all dashboard routes
- [ ] AppShell nav changes based on role (cart hidden for non-customers)
- [ ] Rebuild auth-service: `docker compose up -d --build auth-service`
