# Operations Alerting Provisioning

## Goal

Provide dashboard and alert definitions as code for Stage 3 operational readiness.

## Artifacts

- Prometheus alerts:
  - `ops/monitoring/prometheus/alerts/zimbite-stage3-alerts.yml`
- Grafana dashboard:
  - `ops/monitoring/grafana/dashboards/zimbite-stage3-operations.json`

## Covered Signals

- Kafka consumer lag (`order-service`, `payment-service`, `delivery-service`, `notification-service`)
- Outbox backlog age (`order-service`, `payment-service`)
- API latency p95 (`/orders`, `/payments`, `/deliveries`)
- Database pool saturation (Hikari connection utilization)

## Provisioning Steps

1. Apply Prometheus alert rules through your monitoring stack release process.
2. Import the Grafana dashboard JSON or provision it via dashboard provisioning.
3. Map `severity=warning|critical` alerts to on-call routing.
4. Validate alert fire and resolve cycle in staging before production rollout.

## Validation Checklist

- Alert rule group loads without syntax errors.
- Dashboard renders all four panels with live series.
- Alert notifications route to platform on-call channel.
- Runbook links are attached to each alert in Alertmanager routing config.
