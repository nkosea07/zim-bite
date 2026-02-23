# ADR 001: Microservices Over Monolith

- Status: Accepted
- Date: 2026-02-22

## Context

ZimBite combines consumer ordering, vendor operations, payment integrations, delivery logistics, and analytics with different scaling and reliability profiles.

## Decision

Adopt a microservices architecture with explicit bounded contexts and asynchronous event propagation via Kafka.

## Consequences

- Pros: Independent scaling, fault isolation, autonomous release cadence per domain.
- Cons: Operational complexity, distributed tracing requirements, eventual consistency handling.
- Mitigation: Shared platform standards, gateway policy centralization, and strong observability.
