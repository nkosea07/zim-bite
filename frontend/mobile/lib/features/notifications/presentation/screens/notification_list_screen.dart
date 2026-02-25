import 'package:flutter/material.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {}, // TODO: mark all read
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: const ZbEmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications',
        subtitle: 'You\'re all caught up!',
      ),
    );
  }
}
