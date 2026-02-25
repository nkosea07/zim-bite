// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryTrackingImpl _$$DeliveryTrackingImplFromJson(
  Map<String, dynamic> json,
) => _$DeliveryTrackingImpl(
  deliveryId: json['deliveryId'] as String,
  orderId: json['orderId'] as String,
  status: json['status'] as String,
  driverName: json['driverName'] as String?,
  driverPhone: json['driverPhone'] as String?,
  estimatedArrival: json['estimatedArrival'] == null
      ? null
      : DateTime.parse(json['estimatedArrival'] as String),
  currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
  currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$DeliveryTrackingImplToJson(
  _$DeliveryTrackingImpl instance,
) => <String, dynamic>{
  'deliveryId': instance.deliveryId,
  'orderId': instance.orderId,
  'status': instance.status,
  'driverName': instance.driverName,
  'driverPhone': instance.driverPhone,
  'estimatedArrival': instance.estimatedArrival?.toIso8601String(),
  'currentLatitude': instance.currentLatitude,
  'currentLongitude': instance.currentLongitude,
};
