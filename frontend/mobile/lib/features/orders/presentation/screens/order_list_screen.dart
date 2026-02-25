import 'package:flutter/material.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: const ZbEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        subtitle: 'Your order history will appear here',
      ),
      // TODO: replace with BlocBuilder that shows order list
    );
  }
}
