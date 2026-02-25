import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../checkout/data/models/checkout_models.dart';

part 'subscription_models.freezed.dart';
part 'subscription_models.g.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String vendorId,
    required String vendorName,
    required String planName,
    required String status,
    required String frequency,
    DateTime? nextDelivery,
    required double amount,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class CreateSubscriptionRequest with _$CreateSubscriptionRequest {
  const factory CreateSubscriptionRequest({
    required String vendorId,
    required String planName,
    required String frequency,
    required String deliveryAddressId,
    required String paymentMethod,
    required List<OrderItemRequest> items,
  }) = _CreateSubscriptionRequest;

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionRequestFromJson(json);
}
