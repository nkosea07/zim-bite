# ADR 002: Kafka Over RabbitMQ

- Status: Accepted
- Date: 2026-02-22

## Context

ZimBite needs durable event streams for order/payment/delivery flows and replayable analytics pipelines.

## Decision

Use Apache Kafka as the primary event backbone.

## Consequences

- Pros: Ordered partitions, high throughput, log retention and replay, consumer group scaling.
- Cons: Operational overhead compared to simple queues.
- Mitigation: Managed Kafka deployment, topic governance, and DLQ standards.
