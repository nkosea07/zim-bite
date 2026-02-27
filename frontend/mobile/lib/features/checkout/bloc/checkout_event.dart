import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class SetDeliveryAddress extends CheckoutEvent {
  final String addressId;

  const SetDeliveryAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

class SetScheduledTime extends CheckoutEvent {
  final String time;

  const SetScheduledTime(this.time);

  @override
  List<Object?> get props => [time];
}

class SetPaymentMethod extends CheckoutEvent {
  final String method;

  const SetPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class PlaceOrder extends CheckoutEvent {
  const PlaceOrder();
}
