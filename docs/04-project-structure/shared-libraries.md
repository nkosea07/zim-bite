# Shared Libraries

Shared modules live under `shared/` and are versioned together in the monorepo.

## Module Catalog

| Module | Purpose | Used By |
|---|---|---|
| `common-dto` | Common request/response models and event payloads | All services |
| `common-utils` | Time, currency, validation, tracing helpers | All services |
| `common-security` | JWT parsing, claim utilities, auth annotations | Gateway + protected services |
| `common-messaging` | Kafka topic constants, producer config helpers, envelope schema | Event-producing/consuming services |

## Dependency Direction

- `common-dto` and `common-utils` have no internal dependencies.
- `common-security` may depend on `common-dto`.
- `common-messaging` may depend on `common-dto`.
- Services depend on shared modules; shared modules do not depend on service code.

## Versioning Rules

- Keep all shared modules in lockstep with parent POM version.
- Breaking contract changes require migration notes and consumer updates in same PR.
- Deprecate fields for one minor release before removal.
