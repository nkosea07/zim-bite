# Implementation Roadmap: Complex Workflow Completion

Last updated: 2026-02-24

## Objective

Close the remaining implementation gaps for medium-to-complex production workflows while keeping the current tech stack and service boundaries.

## Priority Plan

### P0 - Foundation Correctness

1. Sprint 1: Identity integrity and trust boundaries
   - Enforce OTP-gated token issuance (challenge first, tokens after OTP verification).
   - Remove placeholder user auto-provisioning fallback in user-service.
   - Bind sensitive create flows to gateway-propagated identity headers instead of trusting payload identity fields.
2. Sprint 2: Commercial correctness
   - Replace fixed order pricing with menu-backed pricing snapshots.
   - Add inventory reservation/release semantics on order and payment transitions.
   - Harden provider callback verification and reconciliation in payment flows.

### P1 - Operational Intelligence

3. Sprint 3: Delivery realism
   - Replace synthetic pickup/dropoff coordinates with real address-derived coordinates.
   - Strengthen tracking ingestion (freshness/outlier controls).
   - Improve ETA calculations with route-aware inputs.
4. Sprint 4: Event completion
   - Complete notification fan-out for payment and delivery milestones.
   - Persist analytics projections (restart-safe) and support replay bootstrap.

### P2 - Product Completeness

5. Sprint 5: Meal builder hardening
   - Persist presets and recommendation state.
   - Drive availability/pricing/nutrition from real menu/inventory data.
6. Sprint 6: Advanced business workflows
   - Implement real corporate ordering rules and approval/billing workflow.
   - Implement subscription lifecycle (recurrence, skip/pause/cancel, payment retries).

## Sprint 1 Scope

Status: Completed (2026-02-24)

### Deliverables

1. Auth service
   - `POST /api/v1/auth/login` returns OTP challenge response instead of tokens.
   - `POST /api/v1/auth/verify-otp` verifies challenge and issues access/refresh tokens.
2. User service
   - Replace fallback `getOrCreateUser` behavior with strict lookup and explicit not-found handling.
3. Order and vendor trust boundaries
   - Ensure identity used for create flows is derived from gateway headers, not request body identity fields.

### Acceptance Criteria

1. A user cannot receive access/refresh tokens without successful OTP verification.
2. User profile APIs do not auto-create placeholder users.
3. Order/vendor creation ignores mismatched body identity values and uses gateway identity.
4. Existing unit tests pass and new tests cover Sprint 1 behavior.

## Sprint 1 Execution Notes

Implementation details and changed files are tracked in the corresponding service modules and test suites.

## Sprint 2 Scope

Status: Completed (2026-02-24)

### Deliverables

1. Replace fixed order pricing with menu-backed price snapshots.
2. Add inventory reservation/release semantics linked to order and payment status transitions.
3. Harden payment callbacks with provider verification, callback dedupe/audit, and stale pending reconciliation.

## Sprint 3 Scope

Status: Completed (2026-02-24)

### Deliverables

1. Replace synthetic pickup/dropoff coordinates with order snapshot coordinates derived from vendor and delivery address data.
2. Enforce tracking ingestion freshness/outlier validation before persisting rider location pings.
3. Use route-aware ETA estimation with telemetry-informed speed envelopes.

## Sprint 4 Scope

Status: Completed (2026-02-24)

### Deliverables

1. Complete notification fan-out for payment and delivery milestones by resolving order recipient identity and persisting notifications.
2. Persist analytics projections to PostgreSQL and bootstrap in-memory aggregates from persisted projections on startup.
