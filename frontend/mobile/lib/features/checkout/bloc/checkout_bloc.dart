import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/models/checkout_models.dart';
import '../data/repositories/checkout_repository.dart';
import '../../cart/bloc/cart_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _checkoutRepository;
  final CartBloc _cartBloc;

  CheckoutBloc({
    required CheckoutRepository checkoutRepository,
    required CartBloc cartBloc,
  })  : _checkoutRepository = checkoutRepository,
        _cartBloc = cartBloc,
        super(const CheckoutFormState()) {
    on<SetDeliveryAddress>(_onSetDeliveryAddress);
    on<SetScheduledTime>(_onSetScheduledTime);
    on<SetPaymentMethod>(_onSetPaymentMethod);
    on<PlaceOrder>(_onPlaceOrder);
  }

  void _onSetDeliveryAddress(
    SetDeliveryAddress event,
    Emitter<CheckoutState> emit,
  ) {
    final current = _formState;
    emit(current.copyWith(addressId: event.addressId));
  }

  void _onSetScheduledTime(
    SetScheduledTime event,
    Emitter<CheckoutState> emit,
  ) {
    final current = _formState;
    emit(current.copyWith(scheduledTime: event.time));
  }

  void _onSetPaymentMethod(
    SetPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) {
    final current = _formState;
    emit(current.copyWith(paymentMethod: event.method));
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    final formState = _formState;
    if (formState.addressId == null || formState.paymentMethod == null) {
      emit(const CheckoutError('Please select a delivery address and payment method.'));
      emit(formState);
      return;
    }

    final cartState = _cartBloc.state;
    if (cartState.isEmpty) {
      emit(const CheckoutError('Your cart is empty.'));
      emit(formState);
      return;
    }

    if (cartState.vendorId == null) {
      emit(const CheckoutError('No vendor selected.'));
      emit(formState);
      return;
    }

    emit(const CheckoutSubmitting());

    try {
      final request = PlaceOrderRequest(
        vendorId: cartState.vendorId!,
        items: cartState.items
            .map(
              (item) => OrderItemRequest(
                menuItemId: item.menuItemId,
                quantity: item.quantity,
                unitPrice: item.price,
              ),
            )
            .toList(),
        deliveryAddressId: formState.addressId!,
        scheduledFor: formState.scheduledTime != null
            ? _parseScheduledTime(formState.scheduledTime!)
            : null,
        paymentMethod: formState.paymentMethod!,
      );

      final result = await _checkoutRepository.placeOrder(request);
      final orderId = result['id'] as String? ?? result['orderId'] as String? ?? '';
      final status = result['status'] as String? ?? 'pending';

      emit(CheckoutSuccess(orderId: orderId, status: status));
    } on ApiException catch (e) {
      emit(CheckoutError(e.message));
      emit(formState);
    } catch (e) {
      emit(CheckoutError(e.toString()));
      emit(formState);
    }
  }

  CheckoutFormState get _formState {
    final s = state;
    if (s is CheckoutFormState) return s;
    return const CheckoutFormState();
  }

  DateTime _parseScheduledTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 7;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return now;
  }
}
