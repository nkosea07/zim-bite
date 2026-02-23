# Docker Strategy

## Image Build Pattern

Use multi-stage Dockerfiles for each service:

1. Build stage using Maven image to compile and package jar.
2. Runtime stage using slim JRE base image.
3. Run as non-root user.

## Example Template

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY services/order-service ./services/order-service
COPY shared ./shared
RUN mvn -pl services/order-service -am clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /opt/app
RUN useradd -m zimbite
USER zimbite
COPY --from=build /app/services/order-service/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Local Development

- `docker-compose.yml`: PostgreSQL, Redis, Kafka, Zookeeper.
- `docker-compose.services.yml`: all microservices for integration runs.
- Use `.env` for local secrets only; production secrets are not baked in images.
