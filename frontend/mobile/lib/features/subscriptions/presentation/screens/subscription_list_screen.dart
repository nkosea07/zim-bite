import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class SubscriptionListScreen extends StatelessWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: ZbEmptyState(
        icon: Icons.repeat,
        title: 'No active subscriptions',
        subtitle: 'Set up recurring meal deliveries',
        action: ElevatedButton(
          onPressed: () => context.pushNamed(RouteNames.createSubscription),
          child: const Text('Create Subscription'),
        ),
      ),
    );
  }
}
