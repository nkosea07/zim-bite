import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.brandOrange.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 32, color: AppColors.brandOrange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Name', style: Theme.of(context).textTheme.titleMedium),
                        Text('+263 7X XXX XXXX',
                            style: TextStyle(color: AppColors.warmGrey500)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.pushNamed(RouteNames.editProfile),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _ProfileMenuItem(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            onTap: () => context.pushNamed(RouteNames.addresses),
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_outline,
            label: 'Favorites',
            onTap: () => context.pushNamed(RouteNames.favorites),
          ),
          _ProfileMenuItem(
            icon: Icons.repeat,
            label: 'Subscriptions',
            onTap: () => context.pushNamed(RouteNames.subscriptions),
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => context.pushNamed(RouteNames.notifications),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Logout', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brandOrange),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
