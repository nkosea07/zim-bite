#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODULES="services/auth-service,services/order-service,services/payment-service,services/delivery-service,services/notification-service"
TESTS="AuthServiceOtpTest,OrderServiceTest,PaymentServiceTest,PaymentEventConsumerTest,NotificationQueryServiceTest"

echo "Running core-flow smoke tests for modules: $MODULES"
echo "Smoke tests: $TESTS"

mvn -B \
  -pl "$MODULES" \
  -am \
  -Dtest="$TESTS" \
  -Dsurefire.failIfNoSpecifiedTests=false \
  test

echo "Core-flow smoke tests passed."
