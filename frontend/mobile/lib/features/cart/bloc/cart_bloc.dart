import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/cart_models.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final item = event.item;
    final currentItems = List<CartItem>.from(state.items);

    // If the item is from a different vendor, clear first
    if (state.vendorId != null && state.vendorId != item.vendorId) {
      emit(CartState(
        items: [item],
        vendorId: item.vendorId,
        currency: state.currency,
      ));
      return;
    }

    final existingIndex =
        currentItems.indexWhere((i) => i.menuItemId == item.menuItemId);

    if (existingIndex >= 0) {
      currentItems[existingIndex] = currentItems[existingIndex].copyWith(
        quantity: currentItems[existingIndex].quantity + item.quantity,
      );
    } else {
      currentItems.add(item);
    }

    emit(state.copyWith(
      items: currentItems,
      vendorId: item.vendorId,
    ));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .where((item) => item.menuItemId != event.menuItemId)
        .toList();

    emit(state.copyWith(
      items: updatedItems,
      vendorId: updatedItems.isEmpty ? null : state.vendorId,
    ));
  }

  void _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.menuItemId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.menuItemId == event.menuItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
