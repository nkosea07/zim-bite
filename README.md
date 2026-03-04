# ZimBite

On-demand breakfast delivery platform for Zimbabwe. Hot breakfast delivered between 5 AM and 10 AM.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java 21, Spring Boot 3.3, Maven |
| Web Frontend | React 18, Vite, TypeScript, TanStack Query, Zustand |
| Mobile Frontend | Flutter 3.9, Dart, BLoC, Freezed, GoRouter |
| Database | PostgreSQL 16 + PostGIS |
| Cache | Redis 7 |
| Messaging | Apache Kafka (Confluent 7.6) |
| Auth | JWT + OTP (phone-based) |
| Containers | Docker Compose |
| Orchestration | Kubernetes |
| Maps | Leaflet (web), flutter_map (mobile), OpenStreetMap tiles |

## Architecture

12 microservices behind an API Gateway:

| Service | Port | Description |
|---------|------|-------------|
| API Gateway | 8080 | Routes, CORS, JWT validation |
| Auth | 8081 | OTP login, token issuance |
| User | 8082 | Profiles, addresses |
| Vendor | 8083 | Vendor management |
| Menu | 8084 | Menu items, categories |
| Meal Builder | 8085 | Custom meal composition |
| Order | 8086 | Order lifecycle |
| Payment | 8087 | EcoCash, OneMoney, card payments |
| Delivery | 8088 | Rider assignment, real-time tracking (WebSocket) |
| Notification | 8089 | Push, SMS, email |
| Analytics | 8090 | Event projections |
| Subscription | 8091 | Meal plan subscriptions |

Infrastructure: PostgreSQL (port 5434), Redis (6379), Zookeeper (2181), Kafka (9092).

## Prerequisites

- **Java 21** (JDK)
- **Maven 3.9+**
- **Docker** and **Docker Compose** v2
- **Node.js 18+** and **npm** (for web frontend)
- **Flutter 3.9+** (for mobile frontend, optional)

## Quick Start

### 1. Clone and configure environment

```bash
git clone <repo-url> && cd zim-bite
cp .env.example .env
```

Edit `.env` and set the required values:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=zimbite
JWT_SECRET=your_jwt_secret_at_least_32_chars
```

### 2. Build all backend services

```bash
mvn clean install -DskipTests
```

This compiles all 12 services plus 4 shared libraries (`common-dto`, `common-utils`, `common-security`, `common-messaging`).

### 3. Start everything with Docker

```bash
make up
```

This builds Docker images and starts all infrastructure (Postgres, Redis, Zookeeper, Kafka) and all 12 microservices. Flyway migrations run automatically on startup to create database tables.

Verify containers are healthy:

```bash
make ps
```

Wait until all services show `healthy` or `running`. Infrastructure containers start first; services wait for health checks before launching.

### 4. Start the web frontend

```bash
cd frontend/web
npm install
npm run dev
```

The web app starts at **http://localhost:5173**. It proxies API calls to the gateway at `localhost:8080`.

### 5. Start the mobile app (optional)

```bash
cd frontend/mobile
flutter pub get
dart run build_runner build    # generates Freezed/JSON serialization code
flutter run
```

The mobile app connects to the API gateway. On Android emulator it uses `10.0.2.2:8080` (configured in `.env.dev`).

## Development Workflow

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Build and start all containers |
| `make down` | Stop containers (keeps database volume) |
| `make down-v` | Stop containers and wipe database |
| `make restart` | Rebuild and restart only microservices (keeps infra running) |
| `make logs` | Tail all container logs |
| `make ps` | Show container status and health |
| `make build` | Compile all Maven modules (no Docker) |
| `make test` | Run all backend tests |

### Running a single service locally (outside Docker)

Start only infrastructure:

```bash
make infra-up
```

Then run one service with Maven:

```bash
mvn -pl services/auth-service spring-boot:run
```

The service connects to Postgres on `localhost:5434` and Kafka on `localhost:9092`.

### Running backend tests

```bash
# All services
mvn test

# Single service
mvn -pl services/delivery-service test
```

### Regenerating Flutter models

After modifying any `@freezed` or `@JsonSerializable` class in the mobile app:

```bash
cd frontend/mobile
dart run build_runner build --delete-conflicting-outputs
```

### Web frontend type checking

```bash
cd frontend/web
npx tsc --noEmit
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | Database username |
| `POSTGRES_PASSWORD` | `postgres` | Database password |
| `POSTGRES_DB` | `zimbite` | Database name |
| `JWT_SECRET` | *(required)* | Secret key for JWT signing |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:3000,http://localhost:5173` | Allowed CORS origins |
| `AUTH_OTP_DEV_STATIC_CODE` | `123456` | Static OTP code for development |
| `KAFKA_BOOTSTRAP_SERVERS` | `kafka:9092` | Kafka broker address |
| `REDIS_HOST` | `redis` | Redis host |

## API Endpoints

All requests go through the API Gateway at `http://localhost:8080`.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/login` | POST | Send OTP to phone number |
| `/api/v1/auth/verify-otp` | POST | Verify OTP, receive JWT |
| `/api/v1/vendors` | GET | List vendors |
| `/api/v1/vendors/{id}` | GET | Vendor details |
| `/api/v1/menu/vendors/{id}/items` | GET | Menu items for vendor |
| `/api/v1/meal-builder/calculate` | POST | Calculate custom meal price |
| `/api/v1/meal-builder/presets` | GET | Preset meal templates |
| `/api/v1/orders` | POST | Place an order |
| `/api/v1/orders` | GET | List user orders |
| `/api/v1/payments/initiate` | POST | Initiate payment (requires `Idempotency-Key` header) |
| `/api/v1/deliveries/orders/{orderId}/tracking` | GET | Delivery tracking info |

**WebSocket** (delivery-service, port 8088): Connect via STOMP+SockJS at `/ws`. Subscribe to `/topic/delivery/{id}/location` for live rider location and `/topic/chat/{deliveryId}` for rider chat.

## Payments

EcoCash, OneMoney, Visa/Mastercard, Cash on Delivery.

## Key Features

- Drag-and-drop meal builder with real-time pricing and multi-meal support
- Location-based vendor discovery (PostGIS)
- Delivery rider logistics with live GPS tracking and in-app chat
- Corporate breakfast ordering
- Subscription-based meal plans
- Low-bandwidth optimization for Zimbabwe network conditions
- Offline-first mobile support

## Documentation

Detailed docs are in the [`docs/`](docs/) directory:

- [System Architecture](docs/01-architecture/system-overview.md)
- [Service Catalog](docs/01-architecture/service-catalog.md)
- [Communication Patterns](docs/01-architecture/communication-patterns.md)
- [Database ER Diagram](docs/02-database/er-diagram.md)
- [API Overview](docs/03-api/api-overview.md)
- [Gateway Routes](docs/03-api/gateway-routes.md)
- [Monorepo Layout](docs/04-project-structure/monorepo-layout.md)
- [Docker Strategy](docs/05-deployment/docker-strategy.md)
- [CI/CD Pipeline](docs/05-deployment/ci-cd-pipeline.md)
- [Monitoring](docs/05-deployment/monitoring-observability.md)
