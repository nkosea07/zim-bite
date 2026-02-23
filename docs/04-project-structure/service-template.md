# Service Template (Spring Boot)

Standard layout for each backend microservice.

```text
services/<service-name>/
  pom.xml
  Dockerfile
  src/main/java/com/zimbite/<service>/
    <Service>Application.java
    config/
    controller/
    service/
    repository/
    model/
      entity/
      dto/
    mapper/
    event/
      producer/
      consumer/
    client/
    exception/
  src/main/resources/
    application.yml
    application-dev.yml
    application-prod.yml
  src/test/java/com/zimbite/<service>/
```

## Layer Responsibilities

| Layer | Responsibility |
|---|---|
| `controller` | HTTP contracts, validation, response mapping |
| `service` | Business orchestration and transaction boundaries |
| `repository` | Persistence access via Spring Data/JPA |
| `model.entity` | DB-bound entities |
| `model.dto` | API request/response contracts |
| `mapper` | Entity/DTO transformations (MapStruct) |
| `event` | Kafka producers/consumers and event schemas |
| `client` | Outbound service clients (Feign/WebClient) |
| `exception` | Domain exceptions + global exception mapping |
| `config` | Security, Kafka, Redis, and service-specific configs |

## Implementation Rules

- Keep controllers thin; move logic to service layer.
- Do not directly query another service database.
- Emit domain events after successful transaction commits.
- Enforce idempotency in command handlers.
- Keep DTOs backward-compatible for additive changes.
