# Scaling Strategy

## Peak Characteristics

- Sharp daily demand peak between 5AM and 10AM.
- Payment and order write paths are primary bottlenecks.
- Delivery assignment workload spikes shortly after order peak.

## Horizontal Scaling

| Service | Trigger |
|---|---|
| API Gateway | CPU > 60% or RPS threshold |
| Order Service | Request concurrency + queue depth |
| Payment Service | Callback throughput + pending payments |
| Delivery Service | Active deliveries + assignment latency |
| Notification Service | Kafka lag |

## Data Layer Scaling

- PostgreSQL with read replicas for analytics and heavy read endpoints.
- PgBouncer for connection pooling.
- Redis in clustered mode with replicas for resilience.
- Kafka partitioning by `order_id` for ordered lifecycle events.

## Operational Strategies

- Pre-scale critical workloads at 04:30 local time.
- Use canary deployments outside peak windows.
- Run load tests monthly with breakfast-peak traffic model.
