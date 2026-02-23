# Gateway Routes

API Gateway listens on `:8080` and routes by path prefix.

| Public Path Prefix | Service | Target Port | Notes |
|---|---|---:|---|
| `/api/v1/auth/**` | Auth Service | 8081 | Public login/register + protected refresh/logout |
| `/api/v1/users/**` | User Service | 8082 | JWT required |
| `/api/v1/vendors/**` | Vendor Service | 8083 | Public browse; vendor management protected |
| `/api/v1/menu/**` | Menu Service | 8084 | Public browse; item mutation protected |
| `/api/v1/meal-builder/**` | Meal Builder Service | 8085 | JWT required for saving presets |
| `/api/v1/orders/**` | Order Service | 8086 | JWT required |
| `/api/v1/payments/**` | Payment Service | 8087 | Callbacks public with signature validation |
| `/api/v1/deliveries/**` | Delivery Service | 8088 | Rider/vendor/admin scope checks |
| `/api/v1/notifications/**` | Notification Service | 8089 | JWT required |
| `/api/v1/analytics/**` | Analytics Service | 8090 | Vendor/admin scope checks |

## Gateway Policies

- JWT validation at edge, forwarded user claims as headers.
- Per-route rate limiting backed by Redis.
- Request/response compression enabled.
- Correlation header `X-Trace-Id` generated if absent.
