# Service Catalog

## Runtime Catalog

| Service | Port | Base Path | DB Schema Ownership | Kafka Topics (Pub/Sub) | Depends On | Redis Usage |
|---|---:|---|---|---|---|---|
| API Gateway | 8080 | `/api/v1/*` | None | None | Auth for token introspection | Sliding window counters, route cache |
| Auth Service | 8081 | `/api/v1/auth` | `auth` | Publishes `auth.user.registered` | User Service | Refresh token/session cache |
| User Service | 8082 | `/api/v1/users` | `user` | Publishes `user.profile.updated` | Auth Service | Profile cache, address cache |
| Vendor Service | 8083 | `/api/v1/vendors` | `vendor` | Publishes `vendor.status.changed` | None | Geo query result cache |
| Menu Service | 8084 | `/api/v1/menu` | `menu` | Publishes `menu.item.updated`, `menu.inventory.changed` | Vendor Service | Menu catalog cache |
| Meal Builder Service | 8085 | `/api/v1/meal-builder` | `meal_builder` | Publishes `meal.preset.saved` | Menu Service | Price calculation cache |
| Order Service | 8086 | `/api/v1/orders` | `ordering` | Publishes `order.created`, `order.cancelled`, `order.status.changed` | User, Menu, Payment | Cart snapshot cache, idempotency guard |
| Payment Service | 8087 | `/api/v1/payments` | `payment` | Publishes `payment.initiated`, `payment.succeeded`, `payment.failed`, `payment.refunded` | Order, external processors | Idempotency keys, callback dedupe |
| Delivery Service | 8088 | `/api/v1/deliveries` | `delivery` | Publishes `delivery.assigned`, `delivery.location.updated`, `delivery.completed` | Order, Vendor | Rider state cache, ETA cache |
| Notification Service | 8089 | `/api/v1/notifications` | `notification` | Subscribes to order/payment/delivery topics; publishes `notification.sent` | User Service | Notification preference cache |
| Analytics Service | 8090 | `/api/v1/analytics` | `analytics` | Subscribes to all domain topics | All domain topics | Dashboard aggregate cache |

## Bounded Responsibilities

| Domain | Owning Service | Notes |
|---|---|---|
| Identity and tokens | Auth Service | Issues JWT access + refresh tokens |
| Customer profile and addresses | User Service | Includes favorites and history projections |
| Vendor onboarding and availability | Vendor Service | Storefront metadata and operating schedules |
| Menu, categories, and components | Menu Service | Source of truth for sellable items and inventory |
| Custom meal pricing and nutrition | Meal Builder Service | Computes combinations and validates availability |
| Order lifecycle | Order Service | Order creation, cancellation, and status orchestration |
| Payment lifecycle | Payment Service | External provider integration and reconciliation |
| Last-mile dispatch | Delivery Service | Rider assignment, live tracking, ETA |
| Customer communications | Notification Service | Push/SMS/email + preference enforcement |
| KPIs and reporting | Analytics Service | Vendor/admin dashboards and trend slices |

## Failure Isolation Notes

- Payment failures do not block menu browsing or vendor operations.
- Delivery backlog only degrades ETA quality; order state remains durable in Order Service.
- Analytics lag is acceptable and does not gate transactional endpoints.
- Meal Builder falls back to cached component metadata when Menu Service is degraded.
