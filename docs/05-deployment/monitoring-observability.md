# Monitoring and Observability

## Metrics

- Prometheus scrapes service metrics at `/actuator/prometheus`.
- Dashboards in Grafana for API latency, payment success rate, dispatch SLA, and queue lag.

## Logs

- Structured JSON logs with `trace_id`, `user_id`, `order_id`, `service`, and `severity`.
- Centralized in ELK or Loki stack.

## Tracing

- OpenTelemetry SDK in all services.
- Context propagation via HTTP and Kafka headers.
- Sampling policy: 10% baseline, 100% for payment and checkout errors.

## Alerts

| Alert | Threshold |
|---|---|
| P95 order placement latency | > 1500ms for 10 minutes |
| Payment success ratio | < 92% for 5 minutes |
| Delivery assignment lag | > 3 minutes for 5 minutes |
| Kafka consumer lag | > 10000 records for 10 minutes |
| Error rate | > 3% for 5 minutes |

## Provisioned Artifacts

- Prometheus alert rules:
  - `ops/monitoring/prometheus/alerts/zimbite-stage3-alerts.yml`
- Grafana dashboard:
  - `ops/monitoring/grafana/dashboards/zimbite-stage3-operations.json`
