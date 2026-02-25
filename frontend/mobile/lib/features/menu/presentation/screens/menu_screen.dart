import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MenuScreen extends StatelessWidget {
  final String vendorId;

  const MenuScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64, color: AppColors.warmGrey300),
            SizedBox(height: 16),
            Text('Menu items will appear here'),
            Text('Grouped by category with search',
                style: TextStyle(color: AppColors.warmGrey500)),
          ],
        ),
      ),
    );
  }
}
