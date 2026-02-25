import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String vendorId,
    required String vendorName,
    required String status,
    required double totalAmount,
    required DateTime createdAt,
    required int itemCount,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
class OrderDetail with _$OrderDetail {
  const factory OrderDetail({
    required String id,
    required String vendorId,
    required String vendorName,
    required String status,
    required double totalAmount,
    required DateTime createdAt,
    required int itemCount,
    required List<OrderItem> items,
    required String deliveryAddress,
    required String paymentStatus,
    DateTime? scheduledFor,
  }) = _OrderDetail;

  factory OrderDetail.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailFromJson(json);
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String menuItemId,
    required String name,
    required int quantity,
    required double unitPrice,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
