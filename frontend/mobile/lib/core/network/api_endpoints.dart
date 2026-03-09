class ApiEndpoints {
  ApiEndpoints._();

  static const String _base = '/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = '$_base/auth/login';
  static const String verifyOtp = '$_base/auth/verify-otp';
  static const String register = '$_base/auth/register';
  static const String refreshToken = '$_base/auth/refresh';

  // ── Users ─────────────────────────────────────────────────────────────
  static const String userMe = '$_base/users/profile';
  static const String userAddresses = '$_base/users/addresses';
  static const String userFavorites = '$_base/users/favorites';

  /// Returns `/api/v1/users/favorites/{vendorId}`.
  static String userFavorite(String vendorId) =>
      '$_base/users/favorites/$vendorId';

  // ── Vendors ───────────────────────────────────────────────────────────
  static const String vendors = '$_base/vendors';

  /// Returns `/api/v1/vendors/{id}`.
  static String vendor(String id) => '$_base/vendors/$id';

  /// Returns `/api/v1/vendors/{id}/reviews`.
  static String vendorReviews(String id) => '$_base/vendors/$id/reviews';

  // ── Menu ──────────────────────────────────────────────────────────────

  /// Returns `/api/v1/menu/vendors/{vendorId}/items`.
  static String menuItems(String vendorId) =>
      '$_base/menu/vendors/$vendorId/items';

  /// Returns `/api/v1/menu/items/{id}`.
  static String menuItem(String id) => '$_base/menu/items/$id';

  // ── Meal Builder ──────────────────────────────────────────────────────
  static const String mealBuilderComponents = '$_base/meal-builder/components';
  static const String mealBuilderPresets = '$_base/meal-builder/presets';
  static const String mealBuilderCalculate = '$_base/meal-builder/calculate';

  // ── Orders ────────────────────────────────────────────────────────────
  static const String orders = '$_base/orders';

  /// Returns `/api/v1/orders/{id}`.
  static String order(String id) => '$_base/orders/$id';

  /// Returns `/api/v1/orders/{id}/cancel`.
  static String cancelOrder(String id) => '$_base/orders/$id/cancel';

  // ── Payments ──────────────────────────────────────────────────────────
  static const String paymentsInitiate = '$_base/payments/initiate';

  /// Returns `/api/v1/payments/{id}/status`.
  static String paymentStatus(String id) => '$_base/payments/$id/status';

  // ── Deliveries ────────────────────────────────────────────────────────

  /// Returns `/api/v1/deliveries/order/{orderId}`.
  static String deliveryByOrder(String orderId) =>
      '$_base/deliveries/order/$orderId';

  /// Returns `/api/v1/deliveries/{id}/track`.
  static String deliveryTrack(String id) => '$_base/deliveries/$id/track';

  // ── Notifications ─────────────────────────────────────────────────────
  static const String notifications = '$_base/notifications';

  /// Returns `/api/v1/notifications/{id}/read`.
  static String notificationRead(String id) =>
      '$_base/notifications/$id/read';

  static const String notificationsReadAll = '$_base/notifications/read-all';
  static const String notificationPreferences =
      '$_base/notifications/preferences';

  // ── Analytics ─────────────────────────────────────────────────────────
  static const String analyticsSummary = '$_base/analytics/me/summary';

  // ── Subscriptions ─────────────────────────────────────────────────────
  static const String subscriptions = '$_base/subscriptions';

  /// Returns `/api/v1/subscriptions/{id}`.
  static String subscription(String id) => '$_base/subscriptions/$id';

  /// Returns `/api/v1/subscriptions/{id}/pause`.
  static String subscriptionPause(String id) =>
      '$_base/subscriptions/$id/pause';

  /// Returns `/api/v1/subscriptions/{id}/resume`.
  static String subscriptionResume(String id) =>
      '$_base/subscriptions/$id/resume';

  /// Returns `/api/v1/subscriptions/{id}/cancel`.
  static String subscriptionCancel(String id) =>
      '$_base/subscriptions/$id/cancel';

  /// Returns `/api/v1/deliveries/orders/{orderId}/tracking`.
  static String deliveryTracking(String orderId) =>
      '$_base/deliveries/orders/$orderId/tracking';

  // ── Rider ─────────────────────────────────────────────────────────────────
  static const String riderAvailableDeliveries =
      '$_base/deliveries/rider/available';
  static const String riderActiveDeliveries =
      '$_base/deliveries/rider/active';

  /// Returns `/api/v1/deliveries/{deliveryId}/accept`.
  static String acceptDelivery(String deliveryId) =>
      '$_base/deliveries/$deliveryId/accept';

  /// Returns `/api/v1/deliveries/{deliveryId}/status`.
  static String updateDeliveryStatus(String deliveryId) =>
      '$_base/deliveries/$deliveryId/status';

  /// Returns `/api/v1/deliveries/{deliveryId}/chat`.
  static String deliveryChat(String deliveryId) =>
      '$_base/deliveries/$deliveryId/chat';

  // ── Vendor Dashboard ────────────────────────────────────────────────────
  /// Returns `/api/v1/vendors/{id}/stats`.
  static String vendorStats(String vendorId) =>
      '$_base/vendors/$vendorId/stats';

  /// Returns `/api/v1/menu/items/{itemId}/availability`.
  static String menuItemAvailability(String itemId) =>
      '$_base/menu/items/$itemId/availability';

  // ── Analytics ───────────────────────────────────────────────────────────
  /// Returns `/api/v1/analytics/vendor/{vendorId}/dashboard`.
  static String vendorDashboardAnalytics(String vendorId) =>
      '$_base/analytics/vendor/$vendorId/dashboard';

  static const String adminOverview = '$_base/analytics/admin/overview';

  static const String revenueTrends = '$_base/analytics/revenue';
}
