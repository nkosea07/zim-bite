# Infrastructure Overview

## Cluster Topology

```mermaid
flowchart TB
  Internet[Internet / Mobile Clients] --> CDN[CDN + WAF]
  CDN --> Ingress[NGINX Ingress Controller]

  subgraph K8s[ZimBite Kubernetes Cluster]
    Ingress --> Gateway[api-gateway]

    Gateway --> CoreNS[(core namespace)]
    CoreNS --> AuthSvc[auth-service]
    CoreNS --> UserSvc[user-service]
    CoreNS --> VendorSvc[vendor-service]
    CoreNS --> MenuSvc[menu-service]
    CoreNS --> MealSvc[meal-builder-service]
    CoreNS --> OrderSvc[order-service]
    CoreNS --> PaymentSvc[payment-service]
    CoreNS --> DeliverySvc[delivery-service]
    CoreNS --> NotifySvc[notification-service]
    CoreNS --> AnalyticsSvc[analytics-service]

    DataNS[(data namespace)] --> Postgres[(PostgreSQL + PostGIS)]
    DataNS --> Redis[(Redis)]
    DataNS --> Kafka[(Kafka)]

    ObsNS[(observability namespace)] --> Prom[Prometheus]
    ObsNS --> Graf[Grafana]
    ObsNS --> Loki[Loki/ELK]
  end
```

## Namespaces

| Namespace | Purpose |
|---|---|
| `zimbite-core` | Application workloads and gateway |
| `zimbite-data` | Stateful data services (or external managed endpoints) |
| `zimbite-observability` | Metrics, logs, tracing stack |
| `zimbite-jobs` | Scheduled jobs and backfill tasks |
