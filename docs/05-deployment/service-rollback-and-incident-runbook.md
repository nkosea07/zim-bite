# Service Rollback and Incident Runbook

## Scope

Critical services:

- `api-gateway`
- `auth-service`
- `order-service`
- `payment-service`
- `delivery-service`
- `notification-service`

## Standard Rollback Drill

1. Identify impacted service and failing release version.
2. Freeze new deploys for the service.
3. Roll back to previous stable image tag.
4. Verify service health endpoint and key API smoke path.
5. Confirm error rate and latency return to baseline.
6. Resume deploys only after incident commander approval.

## Service-Specific Smoke Checks

- `api-gateway`: `GET /actuator/health` and protected route returns expected auth status.
- `auth-service`: login and token refresh flow.
- `order-service`: create order and fetch status.
- `payment-service`: initiate payment and idempotent callback handling.
- `delivery-service`: tracking endpoint and status update endpoint.
- `notification-service`: preference update and retrieval endpoints.

## Incident Response Workflow

1. `Detect`: alert triggers from latency/error/lag thresholds.
2. `Triage`: classify severity (`SEV-1`/`SEV-2`/`SEV-3`) and assign incident commander.
3. `Contain`: apply rollback, traffic shaping, or feature flag disablement.
4. `Recover`: restore healthy operation and validate downstream consistency.
5. `Review`: publish incident timeline, root cause, and action items within 48 hours.

## Trigger-to-Action Matrix

- High API latency + normal DB saturation:
  - scale affected service replicas and inspect dependency latency.
- High DB saturation:
  - scale DB pool conservatively, inspect slow queries, and reduce traffic burst.
- High Kafka lag:
  - scale consumer replicas and inspect poison messages/DLQ growth.
- Outbox backlog age high:
  - verify publisher scheduler health and database write latency.

## Escalation Contacts Template

- Incident commander: platform on-call engineer
- Communications lead: engineering manager on duty
- Domain experts:
  - Ordering domain owner
  - Payments domain owner
  - Delivery domain owner

## Drill Cadence

- Rollback drill: bi-weekly for `order-service` and `payment-service`
- Full incident simulation: monthly
- Evidence retention: attach logs, metrics screenshots, and timeline to incident ticket
