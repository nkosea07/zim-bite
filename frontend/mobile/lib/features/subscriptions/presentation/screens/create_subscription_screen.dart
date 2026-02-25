import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CreateSubscriptionScreen extends StatelessWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Subscription')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat, size: 64, color: AppColors.warmGrey300),
            SizedBox(height: 16),
            Text('Subscription setup coming soon'),
            Text('Choose vendor, meals, and delivery frequency',
                style: TextStyle(color: AppColors.warmGrey500)),
          ],
        ),
      ),
    );
  }
}
