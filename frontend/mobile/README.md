# ZimBite Mobile

Flutter client for ZimBite.

## Environment files

The app loads environment files at startup:

- `.env.dev` for `main.dart` and `main_dev.dart`
- `.env.prod` for `main_prod.dart`

Loading is non-fatal. If a file is missing, startup continues and defaults are used.

Supported keys:

- `API_BASE_URL` (default: `http://10.0.2.2:8080`)
- `GOOGLE_MAPS_API_KEY` (default: empty)
- `MAP_PROVIDER` (`osm` or `google`)
  - default in debug/dev: `osm`
  - default in release/prod: `google`
  - `.env.dev` should set `MAP_PROVIDER=osm`
  - `.env.prod` should set `MAP_PROVIDER=google`

## Map provider strategy

- Development uses OpenStreetMap tiles via `flutter_map`.
- Production uses `google_maps_flutter`.
- The app map abstraction is `AppMap` in
  `lib/core/maps/app_map.dart`, and provider selection is in
  `EnvConfig.resolveMapProvider`.

## Auth API contract (mobile -> auth-service)

### Login request

`POST /api/v1/auth/login`

```json
{
  "principal": "user@example.com",
  "password": "secret123"
}
```

### Login response

```json
{
  "challengeId": "uuid",
  "principal": "user@example.com",
  "expiresAt": "2026-02-25T16:00:00Z",
  "attemptsRemaining": 3,
  "status": "OTP_REQUIRED"
}
```

### OTP verification request

`POST /api/v1/auth/verify-otp`

```json
{
  "principal": "user@example.com",
  "otp": "123456"
}
```

### Registration request

`POST /api/v1/auth/register`

```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane@example.com",
  "phoneNumber": "+263771234567",
  "password": "secret123"
}
```

## Local checks

From `frontend/mobile`:

```bash
flutter analyze
flutter test
```
