// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      planName: json['planName'] as String,
      status: json['status'] as String,
      frequency: json['frequency'] as String,
      nextDelivery: json['nextDelivery'] == null
          ? null
          : DateTime.parse(json['nextDelivery'] as String),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorId': instance.vendorId,
      'vendorName': instance.vendorName,
      'planName': instance.planName,
      'status': instance.status,
      'frequency': instance.frequency,
      'nextDelivery': instance.nextDelivery?.toIso8601String(),
      'amount': instance.amount,
    };

_$CreateSubscriptionRequestImpl _$$CreateSubscriptionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSubscriptionRequestImpl(
  vendorId: json['vendorId'] as String,
  planName: json['planName'] as String,
  frequency: json['frequency'] as String,
  deliveryAddressId: json['deliveryAddressId'] as String,
  paymentMethod: json['paymentMethod'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CreateSubscriptionRequestImplToJson(
  _$CreateSubscriptionRequestImpl instance,
) => <String, dynamic>{
  'vendorId': instance.vendorId,
  'planName': instance.planName,
  'frequency': instance.frequency,
  'deliveryAddressId': instance.deliveryAddressId,
  'paymentMethod': instance.paymentMethod,
  'items': instance.items,
};
