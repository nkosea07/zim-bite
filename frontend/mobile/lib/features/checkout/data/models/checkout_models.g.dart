// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemRequestImpl _$$OrderItemRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OrderItemRequestImpl(
  menuItemId: json['menuItemId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
);

Map<String, dynamic> _$$OrderItemRequestImplToJson(
  _$OrderItemRequestImpl instance,
) => <String, dynamic>{
  'menuItemId': instance.menuItemId,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
};

_$PlaceOrderRequestImpl _$$PlaceOrderRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PlaceOrderRequestImpl(
  vendorId: json['vendorId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddressId: json['deliveryAddressId'] as String,
  scheduledFor: json['scheduledFor'] == null
      ? null
      : DateTime.parse(json['scheduledFor'] as String),
  paymentMethod: json['paymentMethod'] as String,
);

Map<String, dynamic> _$$PlaceOrderRequestImplToJson(
  _$PlaceOrderRequestImpl instance,
) => <String, dynamic>{
  'vendorId': instance.vendorId,
  'items': instance.items,
  'deliveryAddressId': instance.deliveryAddressId,
  'scheduledFor': instance.scheduledFor?.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
};

_$PaymentInitiateRequestImpl _$$PaymentInitiateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentInitiateRequestImpl(
  orderId: json['orderId'] as String,
  method: json['method'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
);

Map<String, dynamic> _$$PaymentInitiateRequestImplToJson(
  _$PaymentInitiateRequestImpl instance,
) => <String, dynamic>{
  'orderId': instance.orderId,
  'method': instance.method,
  'amount': instance.amount,
  'currency': instance.currency,
};

_$PaymentInitiateResponseImpl _$$PaymentInitiateResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentInitiateResponseImpl(
  paymentId: json['paymentId'] as String,
  redirectUrl: json['redirectUrl'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$$PaymentInitiateResponseImplToJson(
  _$PaymentInitiateResponseImpl instance,
) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'redirectUrl': instance.redirectUrl,
  'status': instance.status,
};
