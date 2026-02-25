import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery address section
            Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined, color: AppColors.brandOrange),
                title: const Text('Select delivery address'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}, // TODO: address picker
              ),
            ),
            const SizedBox(height: 24),

            // Payment method section
            Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment, color: AppColors.brandOrange),
                title: const Text('EcoCash'),
                subtitle: const Text('Mobile money'),
                trailing: const Icon(Icons.check_circle, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 24),

            // Order summary
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: '\$0.00'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Delivery fee', value: '\$0.00'),
                    const Divider(height: 24),
                    _SummaryRow(label: 'Total', value: '\$0.00', isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ZbButton(
            label: 'Place Order',
            onPressed: () {}, // TODO: place order via BLoC
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
