import 'package:equatable/equatable.dart';
import '../data/models/cart_models.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final String? vendorId;
  final String currency;

  const CartState({
    this.items = const [],
    this.vendorId,
    this.currency = 'USD',
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? vendorId,
    String? currency,
  }) {
    return CartState(
      items: items ?? this.items,
      vendorId: vendorId ?? this.vendorId,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [items, vendorId, currency];
}
