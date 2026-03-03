import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_models.freezed.dart';
part 'delivery_models.g.dart';

@freezed
class DeliveryTracking with _$DeliveryTracking {
  const factory DeliveryTracking({
    required String deliveryId,
    required String orderId,
    required String status,
    String? driverName,
    String? driverPhone,
    DateTime? estimatedArrival,
    double? currentLatitude,
    double? currentLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) = _DeliveryTracking;

  factory DeliveryTracking.fromJson(Map<String, dynamic> json) =>
      _$DeliveryTrackingFromJson(json);
}
