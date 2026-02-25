import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MealBuilderScreen extends StatelessWidget {
  const MealBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Builder')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lunch_dining, size: 64, color: AppColors.warmGrey300),
            SizedBox(height: 16),
            Text('Build your custom meal'),
            Text('Select components, see price & calories in real-time',
                style: TextStyle(color: AppColors.warmGrey500)),
          ],
        ),
      ),
    );
  }
}
