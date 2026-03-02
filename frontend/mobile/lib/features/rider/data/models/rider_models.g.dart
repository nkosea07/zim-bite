// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RiderDeliveryImpl _$$RiderDeliveryImplFromJson(Map<String, dynamic> json) =>
    _$RiderDeliveryImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      vendorName: json['vendorName'] as String? ?? 'Vendor',
      pickupAddress: json['pickupAddress'] as String? ?? 'Pickup location',
      deliveryAddress: json['deliveryAddress'] as String? ?? 'Delivery address',
      pickupLat: (json['pickupLat'] as num).toDouble(),
      pickupLng: (json['pickupLng'] as num).toDouble(),
      dropoffLat: (json['dropoffLat'] as num).toDouble(),
      dropoffLng: (json['dropoffLng'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      customerId: json['customerId'] as String?,
      customerPhone: json['customerPhone'] as String?,
    );

Map<String, dynamic> _$$RiderDeliveryImplToJson(_$RiderDeliveryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'vendorName': instance.vendorName,
      'pickupAddress': instance.pickupAddress,
      'deliveryAddress': instance.deliveryAddress,
      'pickupLat': instance.pickupLat,
      'pickupLng': instance.pickupLng,
      'dropoffLat': instance.dropoffLat,
      'dropoffLng': instance.dropoffLng,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'customerId': instance.customerId,
      'customerPhone': instance.customerPhone,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      deliveryId: json['deliveryId'] as String,
      senderId: json['senderId'] as String,
      senderRole: json['senderRole'] as String,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deliveryId': instance.deliveryId,
      'senderId': instance.senderId,
      'senderRole': instance.senderRole,
      'body': instance.body,
      'sentAt': instance.sentAt.toIso8601String(),
    };

_$LocationUpdateImpl _$$LocationUpdateImplFromJson(Map<String, dynamic> json) =>
    _$LocationUpdateImpl(
      deliveryId: json['deliveryId'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$$LocationUpdateImplToJson(
  _$LocationUpdateImpl instance,
) => <String, dynamic>{
  'deliveryId': instance.deliveryId,
  'lat': instance.lat,
  'lng': instance.lng,
  'heading': instance.heading,
  'speedKmh': instance.speedKmh,
  'timestamp': instance.timestamp,
};
