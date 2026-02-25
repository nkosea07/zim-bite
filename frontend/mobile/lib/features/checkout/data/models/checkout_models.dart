import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_models.freezed.dart';
part 'checkout_models.g.dart';

@freezed
class OrderItemRequest with _$OrderItemRequest {
  const factory OrderItemRequest({
    required String menuItemId,
    required int quantity,
    required double unitPrice,
  }) = _OrderItemRequest;

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRequestFromJson(json);
}

@freezed
class PlaceOrderRequest with _$PlaceOrderRequest {
  const factory PlaceOrderRequest({
    required String vendorId,
    required List<OrderItemRequest> items,
    required String deliveryAddressId,
    DateTime? scheduledFor,
    required String paymentMethod,
  }) = _PlaceOrderRequest;

  factory PlaceOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceOrderRequestFromJson(json);
}

@freezed
class PaymentInitiateRequest with _$PaymentInitiateRequest {
  const factory PaymentInitiateRequest({
    required String orderId,
    required String method,
    required double amount,
    required String currency,
  }) = _PaymentInitiateRequest;

  factory PaymentInitiateRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentInitiateRequestFromJson(json);
}

@freezed
class PaymentInitiateResponse with _$PaymentInitiateResponse {
  const factory PaymentInitiateResponse({
    required String paymentId,
    String? redirectUrl,
    required String status,
  }) = _PaymentInitiateResponse;

  factory PaymentInitiateResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentInitiateResponseFromJson(json);
}
