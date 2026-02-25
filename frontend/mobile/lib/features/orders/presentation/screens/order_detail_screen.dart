import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${orderId.substring(0, 8)}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status timeline placeholder
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Status', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    const _StatusStep(label: 'Placed', isCompleted: true),
                    const _StatusStep(label: 'Confirmed', isCompleted: false),
                    const _StatusStep(label: 'Preparing', isCompleted: false),
                    const _StatusStep(label: 'On the way', isCompleted: false),
                    const _StatusStep(label: 'Delivered', isCompleted: false, isLast: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed(
                  RouteNames.deliveryTracking,
                  pathParameters: {'orderId': orderId},
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Track Delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isLast;

  const _StatusStep({required this.label, required this.isCompleted, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.success : AppColors.warmGrey300,
              size: 20,
            ),
            if (!isLast)
              Container(width: 2, height: 24, color: AppColors.warmGrey100),
          ],
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(
          color: isCompleted ? AppColors.warmGrey900 : AppColors.warmGrey500,
          fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
        )),
      ],
    );
  }
}
