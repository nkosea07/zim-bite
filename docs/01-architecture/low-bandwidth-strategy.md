# Low-Bandwidth Strategy

## Constraints

- 2G/3G segments with intermittent connectivity.
- High packet loss and expensive mobile data bundles.
- Morning traffic spikes between 5AM and 10AM.

## Performance Budget

| Experience | Target |
|---|---|
| Initial menu browse payload | < 500KB |
| Subsequent list pages | < 120KB |
| Order status polling fallback payload | < 20KB |
| Critical JS for first render | < 200KB gzipped |

## Backend Optimizations

- Enable gzip/brotli compression at gateway.
- Use cursor pagination for vendor/menu lists.
- Add sparse fieldsets: `?fields=id,name,price,thumbnail_url`.
- Default to lite DTOs; full details on demand.
- Cache hot lookups in Redis with short TTL.
- Support `If-None-Match` + `ETag` for immutable menu assets.

## Frontend Optimizations

- Use responsive WebP images with 3 size variants.
- Preload only above-the-fold assets.
- Persist critical read models in IndexedDB.
- Queue writes offline (favorites, preset saves) and sync later.
- Defer non-critical analytics scripts.

## Network Resilience

- Exponential retry with jitter for safe GET requests.
- Offline indicator with explicit sync status.
- Graceful fallback from websocket to long-polling for tracking.
- Background sync for pending payment verification checks.

## Operational Guardrails

- Track real-user monitoring by network type.
- Alert when p95 payload size breaches budget.
- Reject regressions in CI when bundle size exceeds threshold.
