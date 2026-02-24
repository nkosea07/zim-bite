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

Status: In progress

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
