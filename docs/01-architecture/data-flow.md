# Data Flow

## Order Lifecycle

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant App as Client App
  participant O as Order Service
  participant P as Payment Service
  participant D as Delivery Service
  participant N as Notification Service

  U->>App: Confirm cart and checkout
  App->>O: POST /orders
  O-->>App: order_id + PENDING_PAYMENT
  O-->>P: order.created event
  P-->>O: payment.succeeded/payment.failed event
  P-->>D: payment.succeeded event
  D-->>O: delivery.assigned event
  D-->>O: delivery.completed event
  O-->>N: order.status.changed events
  N-->>U: Push/SMS updates
```

## Payment Flow (EcoCash / OneMoney / Card)

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant App as Client App
  participant Pay as Payment Service
  participant Ext as External Provider
  participant Ord as Order Service

  U->>App: Select payment method
  App->>Pay: initiate payment + idempotency key
  Pay->>Ext: create payment request
  Ext-->>U: prompt/redirect
  Ext-->>Pay: webhook callback
  Pay->>Pay: verify signature + dedupe callback
  alt success
    Pay-->>Ord: payment.succeeded
  else failure
    Pay-->>Ord: payment.failed
  end
```

## Meal Builder Flow

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant App as Client App
  participant MB as Meal Builder Service
  participant Menu as Menu Service

  U->>App: Drag ingredient onto canvas
  App->>MB: POST /calculate
  MB->>Menu: fetch component pricing + availability
  Menu-->>MB: component metadata
  MB->>MB: compute totals and nutrition
  MB-->>App: updated price, kcal, availability flags
  App-->>U: Real-time result

  U->>App: Save preset
  App->>MB: POST /presets
  MB-->>App: preset_id saved
```

## Data Ownership Constraints

- Only Order Service writes `orders` and `order_status_history`.
- Only Payment Service writes `payments` and payment callbacks.
- Only Delivery Service writes `deliveries` and tracking points.
- Cross-domain updates happen through events, not direct table writes.
