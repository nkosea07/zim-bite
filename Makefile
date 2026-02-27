.PHONY: up down restart logs ps build test

# ── Run everything ─────────────────────────────────────────────────────────────

## Build images and start all infra + microservices in the background
up:
	docker compose up -d --build

## Stop and remove all containers (keeps the postgres volume)
down:
	docker compose down

## Stop everything and wipe the postgres volume (fresh DB)
down-v:
	docker compose down -v

## Rebuild and restart only the microservices (keeps infra running)
restart:
	docker compose up -d --build \
		api-gateway auth-service user-service vendor-service \
		menu-service meal-builder-service order-service payment-service \
		delivery-service notification-service analytics-service subscription-service

## Tail logs for all containers (Ctrl-C to stop)
logs:
	docker compose logs -f

## Show container status and health
ps:
	docker compose ps

# ── Build ──────────────────────────────────────────────────────────────────────

## Compile all Maven modules (skips tests)
build:
	mvn clean install -DskipTests

## Run all tests
test:
	mvn test

# ── Legacy targets (kept for compatibility) ────────────────────────────────────

infra-up:
	docker compose up -d postgres redis zookeeper kafka

infra-down:
	docker compose down postgres redis zookeeper kafka
