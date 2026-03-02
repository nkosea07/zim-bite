import 'package:freezed_annotation/freezed_annotation.dart';

part 'rider_models.freezed.dart';
part 'rider_models.g.dart';

@freezed
class RiderDelivery with _$RiderDelivery {
  const factory RiderDelivery({
    required String id,
    required String orderId,
    @Default('Vendor') String vendorName,
    @Default('Pickup location') String pickupAddress,
    @Default('Delivery address') String deliveryAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    @Default(0.0) double totalAmount,
    required String status,
    String? customerId,
    String? customerPhone,
  }) = _RiderDelivery;

  factory RiderDelivery.fromJson(Map<String, dynamic> json) =>
      _$RiderDeliveryFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String deliveryId,
    required String senderId,
    required String senderRole,
    required String body,
    required DateTime sentAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class LocationUpdate with _$LocationUpdate {
  const factory LocationUpdate({
    required String deliveryId,
    required double lat,
    required double lng,
    double? heading,
    double? speedKmh,
    required int timestamp,
  }) = _LocationUpdate;

  factory LocationUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateFromJson(json);
}
