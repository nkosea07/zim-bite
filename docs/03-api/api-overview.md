# API Overview

Base URL via gateway: `/api/v1`

## Conventions

| Concern | Convention |
|---|---|
| Transport | HTTPS only |
| Auth | `Authorization: Bearer <jwt>` unless endpoint is public |
| Content type | `application/json; charset=utf-8` |
| Idempotency | `Idempotency-Key` required for order and payment create endpoints |
| Timestamps | ISO-8601 UTC (`2026-02-22T06:30:00Z`) |
| Currency | ISO-4217 (`USD`, `ZWL`) |

## Standard Error Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more fields are invalid",
    "details": [
      {"field": "phone_number", "message": "invalid format"}
    ],
    "trace_id": "b6c0e4de6e0f44f7"
  }
}
```

## Pagination

Cursor-based pagination for large collections:

- Request: `GET /vendors?limit=20&cursor=eyJpZCI6...`
- Response fields:
  - `items`: array
  - `next_cursor`: string or `null`
  - `has_more`: boolean

## Sparse Fieldsets

Use `fields` query parameter to reduce payload:

- `GET /menu/items?fields=id,name,base_price,image_url`

## Rate Limits

| Endpoint Class | Limit |
|---|---|
| Auth sensitive (`/auth/*`) | 5 req/min per IP/principal |
| Browse/read | 120 req/min per IP |
| Order create | 20 req/hour per user |
| Payment initiate | 10 req/hour per user/device |

## API Versioning

- Current major version: `v1`
- Backward-compatible changes are additive.
- Breaking changes require `v2` routes and dual-run deprecation window.
