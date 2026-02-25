import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderId;

  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Delivery')),
      body: Column(
        children: [
          // Map placeholder
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.warmGrey50,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 64, color: AppColors.warmGrey300),
                    SizedBox(height: 8),
                    Text('Google Maps will appear here',
                        style: TextStyle(color: AppColors.warmGrey500)),
                    Text('With live driver location (15s polling)',
                        style: TextStyle(color: AppColors.warmGrey500, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          // Bottom info sheet
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  const _InfoRow(icon: Icons.person_outline, label: 'Driver', value: 'Assigning...'),
                  const SizedBox(height: 12),
                  const _InfoRow(icon: Icons.access_time, label: 'ETA', value: 'Calculating...'),
                  const SizedBox(height: 12),
                  const _InfoRow(icon: Icons.local_shipping_outlined, label: 'Status', value: 'Pending'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.warmGrey500),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: AppColors.warmGrey500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
