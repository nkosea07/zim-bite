import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class LoadOrderDetail extends OrdersEvent {
  final String orderId;

  const LoadOrderDetail(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
