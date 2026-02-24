#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

spec_paths=$(rg -n '^  /' docs/03-api/specs/*.yaml | wc -l | tr -d ' ')
controller_files=$(find services -path '*/src/main/java/*/controller/*.java' -type f)
implemented_endpoints=$(echo "$controller_files" | xargs rg -n '@GetMapping|@PostMapping|@PatchMapping|@PutMapping|@DeleteMapping' | rg -v 'PingController' | wc -l | tr -d ' ')

echo "OpenAPI paths: $spec_paths"
echo "Implemented endpoints: $implemented_endpoints"

if [[ "$implemented_endpoints" -lt "$spec_paths" ]]; then
  echo "ERROR: Implemented endpoints ($implemented_endpoints) are fewer than spec paths ($spec_paths)."
  exit 1
fi

check_pattern() {
  local file="$1"
  local pattern="$2"
  if ! rg -q "$pattern" "$file"; then
    echo "ERROR: Missing pattern '$pattern' in $file"
    exit 1
  fi
}

check_pattern services/order-service/src/main/java/com/zimbite/order/controller/OrderController.java '@PostMapping\("/\{orderId\}/cancel"\)'
check_pattern services/order-service/src/main/java/com/zimbite/order/controller/OrderController.java '@GetMapping\("/\{orderId\}/status"\)'
check_pattern services/payment-service/src/main/java/com/zimbite/payment/controller/PaymentController.java '@PostMapping\("/refunds/\{paymentId\}"\)'
check_pattern services/delivery-service/src/main/java/com/zimbite/delivery/controller/DeliveryController.java '@GetMapping\("/orders/\{orderId\}/tracking"\)'
check_pattern services/user-service/src/main/java/com/zimbite/user/controller/UserProfileController.java '@GetMapping\("/order-history"\)'
check_pattern services/menu-service/src/main/java/com/zimbite/menu/controller/MenuItemController.java '@PatchMapping\("/items/\{itemId\}/availability"\)'
check_pattern services/vendor-service/src/main/java/com/zimbite/vendor/controller/VendorController.java '@GetMapping\("/\{vendorId\}/stats"\)'
check_pattern services/meal-builder-service/src/main/java/com/zimbite/mealbuilder/controller/MealBuilderController.java '@PostMapping\("/calculate"\)'
check_pattern services/notification-service/src/main/java/com/zimbite/notification/controller/NotificationController.java '@PatchMapping\("/preferences"\)'
check_pattern services/analytics-service/src/main/java/com/zimbite/analytics/controller/AnalyticsController.java '@GetMapping\("/revenue"\)'

echo "OpenAPI drift checks passed."
