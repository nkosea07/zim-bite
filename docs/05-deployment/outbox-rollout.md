# Outbox Rollout

## Goal

Enable transactional outbox publishing safely in non-local environments for `order-service` and `payment-service`.

## Profiles

- Local default (`application.yml`): `outbox.publisher.enabled=false`
- Production (`application-prod.yml`): `outbox.publisher.enabled=true`

## Required Env Vars

- `SPRING_PROFILES_ACTIVE=prod`
- `OUTBOX_BATCH_SIZE` (recommended: `200`)
- `OUTBOX_PUBLISHER_DELAY_MS` (recommended: `1000`)

## Rollout Steps

1. Deploy with profile `prod` while keeping existing consumers unchanged.
2. Verify outbox tables backlog is draining:
   - `ordering.outbox_events`
   - `payment_mgmt.outbox_events`
3. Verify topic emission rate and DLQ metrics are healthy.
4. Alert when unpublished rows older than 2 minutes exceed threshold.

## Rollback

1. Set `OUTBOX_PUBLISHER_ENABLED=false` and redeploy.
2. Keep rows intact for replay once issue is resolved.

## Operational Notes

- Publishers are scheduled pullers and can be horizontally scaled.
- Consumers must remain idempotent because delivery is at-least-once.
