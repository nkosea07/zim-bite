# ER Diagram

The schema is logically separated by service ownership while running in one PostgreSQL instance.

## Mermaid ER

```mermaid
erDiagram
  USERS ||--o{ USER_ADDRESSES : has
  USERS ||--o{ USER_FAVORITES : has
  USERS ||--o{ ORDERS : places
  USERS ||--o{ USER_SUBSCRIPTIONS : enrolls
  USERS ||--o{ VENDOR_REVIEWS : writes
  USERS ||--o{ RIDER_REVIEWS : writes

  CORPORATES ||--o{ USERS : employs
  VENDORS ||--o{ VENDOR_OPERATING_DAYS : schedules
  VENDORS ||--o{ MENU_ITEMS : sells
  VENDORS ||--o{ INVENTORY : tracks
  VENDORS ||--o{ ORDERS : fulfills
  VENDORS ||--o{ SUBSCRIPTION_PLANS : offers

  MENU_CATEGORIES ||--o{ MENU_ITEMS : contains
  MENU_ITEMS ||--o{ MENU_ITEM_COMPONENTS : composed_of
  MENU_ITEMS ||--o{ ORDER_ITEMS : referenced_by

  ORDERS ||--o{ ORDER_ITEMS : contains
  ORDERS ||--o{ ORDER_STATUS_HISTORY : tracks
  ORDERS ||--o{ PAYMENTS : paid_by
  ORDERS ||--o{ DELIVERIES : fulfilled_by

  RIDERS ||--o{ DELIVERIES : assigned_to
  DELIVERIES ||--o{ DELIVERY_TRACKING_POINTS : updates

  SUBSCRIPTION_PLANS ||--o{ USER_SUBSCRIPTIONS : selected_by
  VENDORS ||--o{ VENDOR_REVIEWS : receives
  RIDERS ||--o{ RIDER_REVIEWS : receives
```

## Data Ownership

| Schema | Owning Service | Primary Tables |
|---|---|---|
| `auth` | Auth Service | `refresh_tokens` |
| `user_mgmt` | User Service | `users`, `corporates`, `user_addresses`, `user_favorites` |
| `vendor_mgmt` | Vendor Service | `vendors`, `vendor_operating_days` |
| `menu_mgmt` | Menu Service | `menu_categories`, `menu_items`, `menu_item_components`, `saved_meal_presets`, `inventory` |
| `ordering` | Order Service | `orders`, `order_items`, `order_status_history` |
| `payment_mgmt` | Payment Service | `payments`, `payment_callbacks`, `payment_methods_saved` |
| `delivery_mgmt` | Delivery Service | `riders`, `deliveries`, `delivery_tracking_points` |
| `subscription_mgmt` | Subscription Service | `subscription_plans`, `user_subscriptions` |
| `feedback_mgmt` | Review Service | `vendor_reviews`, `rider_reviews` |

## Design Notes

- UUID primary keys are used across all tables.
- `orders.customization_json` stores flexible meal builder snapshots.
- `order_items` stores denormalized names/prices for historical integrity.
- Payment idempotency is enforced in `payment_mgmt.payments`.
- Geospatial fields (`geometry(Point,4326)`) support vendor and rider proximity queries.
