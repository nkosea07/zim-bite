import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutFormState extends CheckoutState {
  final String? addressId;
  final String? scheduledTime;
  final String? paymentMethod;

  const CheckoutFormState({
    this.addressId,
    this.scheduledTime,
    this.paymentMethod,
  });

  bool get isReadyToPlace =>
      addressId != null && paymentMethod != null;

  CheckoutFormState copyWith({
    String? addressId,
    String? scheduledTime,
    String? paymentMethod,
  }) {
    return CheckoutFormState(
      addressId: addressId ?? this.addressId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [addressId, scheduledTime, paymentMethod];
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

class CheckoutSuccess extends CheckoutState {
  final String orderId;
  final String status;

  const CheckoutSuccess({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
