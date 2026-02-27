import 'package:equatable/equatable.dart';
import '../data/models/cart_models.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final CartItem item;

  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String menuItemId;

  const RemoveFromCart(this.menuItemId);

  @override
  List<Object?> get props => [menuItemId];
}

class UpdateCartQuantity extends CartEvent {
  final String menuItemId;
  final int quantity;

  const UpdateCartQuantity(this.menuItemId, this.quantity);

  @override
  List<Object?> get props => [menuItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}
