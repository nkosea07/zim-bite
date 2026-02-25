import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZimBite',
          style: TextStyle(
            color: AppColors.brandOrange,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.pushNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            GestureDetector(
              onTap: () => context.pushNamed(RouteNames.vendors),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.warmGrey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warmGrey100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.warmGrey500),
                    SizedBox(width: 12),
                    Text(
                      'Search restaurants...',
                      style: TextStyle(color: AppColors.warmGrey500, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.restaurant_menu,
                  label: 'Restaurants',
                  onTap: () => context.pushNamed(RouteNames.vendors),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.lunch_dining,
                  label: 'Meal Builder',
                  onTap: () => context.pushNamed(RouteNames.mealBuilder),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.repeat,
                  label: 'Subscriptions',
                  onTap: () => context.pushNamed(RouteNames.subscriptions),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart',
                  onTap: () => context.pushNamed(RouteNames.cart),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Popular section placeholder
            Text('Popular Near You', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Vendor carousel will appear here',
                  style: TextStyle(color: AppColors.warmGrey500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandOrange, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
