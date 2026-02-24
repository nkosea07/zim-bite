# ZimBite

On-demand breakfast delivery platform for Zimbabwe. Hot breakfast delivered between 5AM–10AM.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java Spring Boot (Maven) |
| Frontend | React (Vite + React Router) |
| Database | PostgreSQL 16 + PostGIS |
| Cache | Redis 7 |
| Messaging | Apache Kafka |
| Auth | JWT + OAuth2 |
| Containers | Docker |
| Orchestration | Kubernetes |

## Architecture

11 microservices: API Gateway, Auth, User, Vendor, Menu, Meal Builder, Order, Payment, Delivery, Notification, Analytics.

## Current Stage

- Stage 1 complete: architecture and platform documentation.
- Stage 2 complete: service implementations, domain migrations, event workflows, frontend feature routes, and CI quality gates.
- Stage 3 implementation complete: release hardening gates, load/security baselines, and operational runbooks are in repo.
- Stage 3 rollout in progress: execute staging/production rehearsals and validate live SLO outcomes.

## Quick Start (Bootstrap)

1. Build backend modules:
   `mvn clean install -DskipTests`
2. Create local env file:
   `cp .env.example .env`
   Set `POSTGRES_PASSWORD` in `.env` before starting services.
3. Start infrastructure dependencies:
   `docker-compose up -d`
4. Run a service locally (example):
   `mvn -pl services/auth-service spring-boot:run`
5. Start frontend (from `frontend/web`):
   `npm install && npm run dev`

## Documentation

- [System Architecture](docs/01-architecture/system-overview.md)
- [Service Catalog](docs/01-architecture/service-catalog.md)
- [Communication Patterns](docs/01-architecture/communication-patterns.md)
- [Data Flow](docs/01-architecture/data-flow.md)
- [Security](docs/01-architecture/security-architecture.md)
- [Low-Bandwidth Strategy](docs/01-architecture/low-bandwidth-strategy.md)
- [Database ER Diagram](docs/02-database/er-diagram.md)
- [SQL Schema](docs/02-database/schema/)
- [API Overview](docs/03-api/api-overview.md)
- [Gateway Routes](docs/03-api/gateway-routes.md)
- [OpenAPI Specs](docs/03-api/specs/)
- [Monorepo Layout](docs/04-project-structure/monorepo-layout.md)
- [Service Template](docs/04-project-structure/service-template.md)
- [Frontend Structure](docs/04-project-structure/frontend-structure.md)
- [Shared Libraries](docs/04-project-structure/shared-libraries.md)
- [Infrastructure](docs/05-deployment/infrastructure-overview.md)
- [Docker Strategy](docs/05-deployment/docker-strategy.md)
- [Kubernetes Manifests](docs/05-deployment/kubernetes-manifests.md)
- [CI/CD Pipeline](docs/05-deployment/ci-cd-pipeline.md)
- [Monitoring](docs/05-deployment/monitoring-observability.md)
- [Scaling Strategy](docs/05-deployment/scaling-strategy.md)
- [Outbox Rollout](docs/05-deployment/outbox-rollout.md)
- [Load Testing Baseline](docs/05-deployment/load-testing-baseline.md)
- [JWT Key Rotation Rehearsal](docs/05-deployment/jwt-key-rotation-rehearsal.md)
- [Operations Alerting Provisioning](docs/05-deployment/operations-alerting-provisioning.md)
- [Service Rollback and Incident Runbook](docs/05-deployment/service-rollback-and-incident-runbook.md)
- [Stage 3 Execution Plan](docs/05-deployment/stage-3-execution-plan.md)
- [Implementation TODO Tracker](docs/implementation-todo.md)

## Payments

EcoCash, OneMoney, Visa/Mastercard, Cash on Delivery.

## Key Features

- Drag-and-drop meal builder with real-time pricing
- Location-based vendor discovery (PostGIS)
- Delivery rider logistics with route optimization
- Corporate breakfast ordering
- Subscription-based meal plans
- Low-bandwidth optimization for Zimbabwe network conditions
- Offline-first support
