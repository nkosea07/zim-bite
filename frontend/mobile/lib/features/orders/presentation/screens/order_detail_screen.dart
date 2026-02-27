import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../bloc/orders_bloc.dart';
import '../../bloc/orders_event.dart';
import '../../bloc/orders_state.dart';
import '../../data/models/order_models.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(LoadOrderDetail(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Order #${widget.orderId.substring(0, 8).toUpperCase()}'),
        elevation: 0,
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const ZbLoading(message: 'Loading order details...');
          }

          if (state is OrdersError) {
            return ZbErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<OrdersBloc>()
                  .add(LoadOrderDetail(widget.orderId)),
            );
          }

          if (state is OrderDetailLoaded) {
            return _OrderDetailBody(detail: state.detail);
          }

          return const ZbLoading();
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final OrderDetail detail;

  const _OrderDetailBody({required this.detail});

  static const List<_StatusStep> _steps = [
    _StatusStep(key: 'placed',           label: 'Order Placed'),
    _StatusStep(key: 'confirmed',        label: 'Confirmed'),
    _StatusStep(key: 'preparing',        label: 'Preparing'),
    _StatusStep(key: 'out_for_delivery', label: 'Out for Delivery'),
    _StatusStep(key: 'delivered',        label: 'Delivered'),
  ];

  int get _currentStepIndex {
    final s = detail.status.toLowerCase();
    for (var i = 0; i < _steps.length; i++) {
      if (_steps[i].key == s) return i;
    }
    if (s == 'cancelled') return -1;
    return 0; // default to 'placed'
  }

  bool get _isActive {
    final s = detail.status.toLowerCase();
    return s != 'delivered' && s != 'cancelled';
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentStepIndex;
    final dateStr =
        DateFormat('d MMM yyyy, h:mm a').format(detail.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status timeline
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Status',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...List.generate(_steps.length, (i) {
                  final isCompleted = idx == -1 ? false : i <= idx;
                  final isActive = idx == -1 ? false : i == idx;
                  final isLast = i == _steps.length - 1;
                  return _StatusRow(
                    label: _steps[i].label,
                    isCompleted: isCompleted,
                    isActive: isActive,
                    isLast: isLast,
                  );
                }),
                if (detail.status.toLowerCase() == 'cancelled')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Order Cancelled',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...detail.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item.name} × ${item.quantity}',
                              style:
                                  const TextStyle(color: AppColors.warmGrey700)),
                        ),
                        Text(
                          '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                      '\$${detail.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.brandOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delivery info
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Info',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: detail.deliveryAddress,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Placed',
                  value: dateStr,
                ),
                if (detail.scheduledFor != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Scheduled',
                    value: DateFormat('d MMM yyyy, h:mm a')
                        .format(detail.scheduledFor!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment info
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.payment,
                  label: 'Status',
                  value: detail.paymentStatus.toUpperCase(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Track delivery button (only for active orders)
          if (_isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pushNamed(
                  RouteNames.deliveryTracking,
                  pathParameters: {'orderId': detail.id},
                ),
                icon: const Icon(Icons.map_outlined,
                    color: AppColors.brandOrange),
                label: const Text('Track Delivery',
                    style: TextStyle(color: AppColors.brandOrange)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandOrange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusStep {
  final String key;
  final String label;

  const _StatusStep({required this.key, required this.label});
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const _StatusRow({
    required this.label,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.brandOrange
            : AppColors.warmGrey300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : isActive
                        ? AppColors.brandOrange
                        : Colors.transparent,
                border: Border.all(color: iconColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isActive
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.success : AppColors.warmGrey100,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isCompleted || isActive
                  ? AppColors.warmGrey900
                  : AppColors.warmGrey500,
              fontWeight: isCompleted || isActive
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.warmGrey500),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.warmGrey500, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
