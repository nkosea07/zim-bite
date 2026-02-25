class CartItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String vendorId;
  final String vendorName;

  const CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
  });

  CartItem copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? vendorId,
    String? vendorName,
  }) {
    return CartItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'vendorId': vendorId,
      'vendorName': vendorName,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId &&
          vendorId == other.vendorId;

  @override
  int get hashCode => menuItemId.hashCode ^ vendorId.hashCode;
}

class Cart {
  final List<CartItem> items;
  final String? vendorId;
  final String? vendorName;

  const Cart({
    this.items = const [],
    this.vendorId,
    this.vendorName,
  });

  double get total =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    List<CartItem>? items,
    String? vendorId,
    String? vendorName,
  }) {
    return Cart(
      items: items ?? this.items,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'vendorId': vendorId,
      'vendorName': vendorName,
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      vendorId: json['vendorId'] as String?,
      vendorName: json['vendorName'] as String?,
    );
  }
}
