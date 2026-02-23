.PHONY: build test infra-up infra-down

build:
	mvn clean install -DskipTests

test:
	mvn test

infra-up:
	docker-compose up -d

infra-down:
	docker-compose down -v
