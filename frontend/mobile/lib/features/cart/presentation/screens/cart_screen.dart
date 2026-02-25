import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: connect to CartBloc — for now always show empty state
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ZbEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        subtitle: 'Browse restaurants to add items',
        action: ElevatedButton(
          onPressed: () => context.pushNamed(RouteNames.vendors),
          child: const Text('Browse Restaurants'),
        ),
      ),
    );
  }
}
