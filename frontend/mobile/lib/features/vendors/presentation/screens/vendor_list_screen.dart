import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';

class VendorListScreen extends StatelessWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // TODO: populate from BLoC
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.warmGrey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: AppColors.warmGrey500),
              ),
              title: const Text('Vendor Name'),
              subtitle: const Text('Category • \$\$ • 30 min'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(
                RouteNames.vendorDetail,
                pathParameters: {'vendorId': 'id'},
              ),
            ),
          );
        },
      ),
    );
  }
}
