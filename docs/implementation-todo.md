# Implementation TODO (Architecture and Flow)

Last updated: 2026-02-24

## 1) API Spec vs Service Implementation

- [x] Order Service: implement `GET /api/v1/orders`, `POST /api/v1/orders/{orderId}/cancel`, `GET /api/v1/orders/{orderId}/status`.
- [x] Order Service: implement `POST /api/v1/orders/corporate`.
- [x] Payment Service: implement `POST /api/v1/payments/refunds/{paymentId}`.
- [x] Payment Service: implement `GET/POST /api/v1/payments/methods`.
- [x] Delivery Service: implement `POST /api/v1/deliveries/{deliveryId}/location`.
- [x] Delivery Service: implement `GET /api/v1/deliveries/orders/{orderId}/tracking`.
- [x] User Service: implement `/addresses`, `/favorites`, `/order-history`.
- [x] Menu Service: implement `/vendors/{vendorId}/categories`, `/items/{itemId}`, `/items/{itemId}/availability`.
- [x] Vendor Service: implement business endpoints from OpenAPI (not only `/internal/ping`).
- [x] Meal Builder Service: implement `/calculate`, `/validate`, `/presets`, `/recommendations`.
- [x] Notification Service: expose REST APIs from OpenAPI (not only Kafka consumer + ping).
- [x] Analytics Service: implement `/vendor/{vendorId}/dashboard`, `/admin/overview`, `/revenue`.

## 2) Auth, Security, and Access Control

- [x] Replace `AuthService.verifyOtp` stub with real OTP verification flow.
- [x] Remove demo user fallback in User Service and use propagated gateway identity.
- [x] Add role/scope authorization checks to protected endpoints.
- [x] Implement gateway policies documented but not coded yet: route rate limiting, trace-id generation, and response compression verification.

## 3) Messaging and Reliability

- [x] Enable outbox publishers in non-local environments and document rollout config.
- [x] Add DLQ/retry policy configuration for Kafka consumers.
- [x] Add idempotency and replay safety tests for order/payment/delivery event handling.

## 4) Data and Persistence

- [x] Expand service-local migrations to cover currently documented domain schema needs.
- [x] Align service migrations with canonical SQL docs where gaps exist.
- [x] Add status history persistence for order timeline reads.

## 5) Frontend Delivery

- [x] Replace single bootstrap page with route structure from frontend architecture doc.
- [x] Implement API client, auth store, and order checkout happy path.
- [x] Implement meal builder UI flow with optimistic updates and rollback.

## 6) Testing and Build Stability

- [x] Add test suites per service (controller + service + integration with Testcontainers where relevant).
- [x] Fix Mockito/JDK 23 test runtime issue (currently blocks `mvn test` in this environment).
- [x] Add CI gates for compile, test, and OpenAPI drift checks.

## 7) Stage 3: Release Hardening and Operations

- [x] Add end-to-end smoke tests for primary flows (`auth -> order -> payment -> delivery -> notification`) in CI.
- [x] Add contract test gate for gateway routes vs OpenAPI specs and publish drift report artifact.
- [x] Baseline load tests for checkout and tracking APIs with target SLOs (p95 latency, error rate, throughput).
- [x] Complete security hardening checklist (secret scanning, dependency audit, JWT key rotation rehearsal).
- [x] Provision production dashboards and alerts for Kafka lag, outbox backlog age, API latency, and DB saturation.
- [x] Add deployment runbook with rollback drills and incident response playbook for each critical service.

## 8) Stage 3 Rollout Execution

- [x] Add go/no-go readiness rehearsal runner with report artifact output.
- [x] Add automated canary drill runner (`10% -> 50% -> 100%`) with SLO evidence artifacts.
- [ ] Execute readiness rehearsal in staging and attach report evidence.
- [ ] Execute canary rollout drill (`10% -> 50% -> 100%`) and capture live SLO observations.
