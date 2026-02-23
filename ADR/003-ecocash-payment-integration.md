# ADR 003: EcoCash Integration With Idempotent Payment Core

- Status: Accepted
- Date: 2026-02-22

## Context

Zimbabwe market fit requires mobile money support with variable network reliability and delayed callbacks.

## Decision

Integrate EcoCash as a first-class payment provider through Payment Service with:

- Idempotency keys on payment initiation.
- Callback signature verification and deduplication.
- Event-driven status updates to Order and Notification services.

## Consequences

- Pros: Local payment adoption, safer retry behavior, lower duplicate-charge risk.
- Cons: More provider-specific reconciliation logic.
- Mitigation: Provider adapter abstraction and callback audit storage.
