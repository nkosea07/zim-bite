import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/orders_bloc.dart';
import '../../bloc/orders_event.dart';
import '../../bloc/orders_state.dart';
import '../../data/models/order_models.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Orders'),
        elevation: 0,
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const ZbLoading(message: 'Loading orders...');
          }

          if (state is OrdersError) {
            return ZbErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<OrdersBloc>().add(const LoadOrders()),
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return const ZbEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle: 'Your order history will appear here',
              );
            }

            return RefreshIndicator(
              color: AppColors.brandOrange,
              onRefresh: () async =>
                  context.read<OrdersBloc>().add(const LoadOrders()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _OrderCard(order: state.orders[index]),
              ),
            );
          }

          return const ZbLoading();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'out_for_delivery':
      case 'out for delivery':
        return AppColors.info;
      case 'preparing':
      case 'confirmed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warmGrey500;
    }
  }

  static String _formatStatus(String status) =>
      status.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(order.createdAt);

    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.orderDetail,
        pathParameters: {'orderId': order.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status colour indicator
            Container(
              width: 5,
              height: 90,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.vendorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatStatus(order.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}  •  $dateStr',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.warmGrey500),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.warmGrey300, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
