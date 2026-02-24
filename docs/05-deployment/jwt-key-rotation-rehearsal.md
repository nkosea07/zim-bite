# JWT Key Rotation Rehearsal

## Goal

Rehearse JWT signing key rotation for `auth-service` and `api-gateway` to validate cutover behavior and rollback steps.

## Automated Rehearsal Check

Run:

```bash
./scripts/run-jwt-rotation-rehearsal.sh
```

This executes `JwtKeyRotationRehearsalTest`, which verifies:

- tokens signed with the old key are valid before rotation
- old-key tokens are rejected by the new validator after rotation
- new-key tokens validate after rotation

## Environment Prerequisites

- Non-production environment (staging recommended)
- Distinct `JWT_SECRET` values:
  - `JWT_SECRET_OLD`
  - `JWT_SECRET_NEW`

## Rehearsal Procedure

1. Deploy `auth-service` and `api-gateway` with `JWT_SECRET=$JWT_SECRET_OLD`.
2. Authenticate and capture one access token (`token_old`).
3. Rotate both services to `JWT_SECRET=$JWT_SECRET_NEW` in the same release window.
4. Authenticate again and capture `token_new`.
5. Verify expected behavior:
   - gateway rejects `token_old` with `401`
   - gateway accepts `token_new` and forwards user headers
6. Confirm auth and gateway logs show no JWT parsing/signature errors for `token_new`.

## Rollback

1. Revert both `auth-service` and `api-gateway` to `JWT_SECRET=$JWT_SECRET_OLD`.
2. Re-test protected endpoint access with a newly issued token.
3. Record incident notes and timing in deployment log.

## Notes

- Current implementation uses a single active signing key, so old access tokens are expected to become invalid immediately after rotation.
- Keep access token TTL short during rotation windows to reduce user disruption.
