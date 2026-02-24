# Stage 3 Execution Plan

## Objective

Move ZimBite from feature-complete implementation to production-ready operation with validated performance, security, and deployability.

## Scope

- Cross-service end-to-end validation.
- Release and rollback automation.
- Production observability and SLO enforcement.
- Security and resilience verification.

## Workstreams

### 1) Validation and Quality Gates

- Build CI smoke tests for checkout and fulfillment lifecycle.
- Add gateway-to-spec contract checks with failure-on-drift.
- Ensure deterministic test execution for all service modules.

### 2) Performance and Capacity

- Run load tests for order creation, payment processing, and delivery tracking.
- Define target SLOs and establish pass/fail thresholds for release.
- Produce capacity assumptions for peak breakfast window traffic.

### 3) Security and Compliance

- Run dependency and container vulnerability scans on every mainline build.
- Exercise JWT signing key rotation in a controlled rehearsal.
- Validate access controls on protected endpoints via automated tests.

### 4) Operations and Rollout

- Publish service runbooks including startup checks, rollback, and recovery steps.
- Configure dashboards and alerts for latency, Kafka lag, and outbox backlog.
- Execute a staged production rollout with defined go/no-go criteria.
- Run `scripts/run-stage3-rollout-readiness.sh` and archive the generated readiness report before rollout approval.
- Run `scripts/run-stage3-canary-drill.sh` for `10% -> 50% -> 100%` progression and archive canary SLO report.

## Exit Criteria

Stage 3 is complete when all items below are true:

- Stage 3 checklist in `docs/implementation-todo.md` is fully checked.
- CI pipeline blocks merges on smoke, contract, and regression failures.
- Load testing demonstrates SLO compliance for critical APIs.
- On-call dashboard and alert routing are active and validated.
- Rollback drill succeeds for at least `order-service` and `payment-service`.
