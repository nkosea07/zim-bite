# Frontend Structure (React + Vite)

```text
frontend/web/
  package.json
  vite.config.ts
  tsconfig.json
  src/
    main.tsx
    app/
      router.tsx
      providers.tsx
      store/
        authStore.ts
        cartStore.ts
      queryClient.ts
    pages/
      home/
      vendor/
      meal-builder/
      cart/
      checkout/
      tracking/
      account/
      vendor-portal/
    features/
      auth/
      vendor-discovery/
      menu/
      meal-builder/
      orders/
      payments/
      delivery-tracking/
      notifications/
    components/
      ui/
      layout/
      forms/
      maps/
    services/
      apiClient.ts
      websocket.ts
    hooks/
    utils/
    styles/
    assets/
```

## Frontend Stack

| Concern | Choice |
|---|---|
| Routing | React Router |
| Data fetching/cache | TanStack Query |
| Local UI state | Zustand |
| Forms | React Hook Form + Zod |
| Drag-and-drop | `@dnd-kit/core` |
| Styling | CSS Modules + design tokens |
| Offline cache | IndexedDB via local persistence layer |

## Meal Builder Module

- Canvas + component palette powered by `@dnd-kit`.
- Real-time recalculation requests to Meal Builder Service.
- Optimistic UI updates with rollback on validation failure.
- Preset save/load tied to authenticated user profile.

## Low-Bandwidth Frontend Rules

- Prefer list skeletons over blocking spinners.
- Use image placeholders + progressive loading.
- Store recent vendors/menu snapshots for offline view.
- Retry non-critical background requests with exponential backoff.
