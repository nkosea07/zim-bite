import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/rider_dashboard_bloc.dart';
import '../../data/models/rider_models.dart';

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Earnings',
          style: TextStyle(
            color: AppColors.warmGrey900,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.warmGrey900),
      ),
      body: BlocBuilder<RiderDashboardBloc, RiderDashboardState>(
        builder: (context, state) {
          final List<RiderDelivery> active =
              state is RiderDashboardLoaded ? state.active : [];
          final List<RiderDelivery> all =
              state is RiderDashboardLoaded
                  ? [...state.active, ...state.available]
                  : [];

          final deliveredCount = active
              .where((d) => d.status.toUpperCase() == 'DELIVERED')
              .length;
          final totalEarned = active
              .where((d) => d.status.toUpperCase() == 'DELIVERED')
              .fold(0.0, (sum, d) => sum + d.totalAmount * 0.15);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards row
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.local_shipping_outlined,
                      label: 'Deliveries',
                      value: '$deliveredCount',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.attach_money,
                      label: 'Total Earned',
                      value: '\$${totalEarned.toStringAsFixed(2)}',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tip card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandOrange,
                      AppColors.brandOrangeLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined,
                        color: Colors.white, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Breakfast Rush Tip',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete deliveries before 10 AM for breakfast rush bonuses!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payout info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.info, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your payout is 15% of each delivery\'s total order amount.',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Earnings content
              if (deliveredCount == 0 && all.isEmpty)
                const ZbEmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No earnings yet',
                  subtitle:
                      'Complete deliveries to see your earnings here.',
                )
              else if (deliveredCount == 0)
                const ZbEmptyState(
                  icon: Icons.hourglass_empty_outlined,
                  title: 'No completed deliveries',
                  subtitle:
                      'Finish your active deliveries to record earnings.',
                )
              else ...[
                const Text(
                  'Recent Deliveries',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.warmGrey900,
                  ),
                ),
                const SizedBox(height: 12),
                ...active
                    .where((d) => d.status.toUpperCase() == 'DELIVERED')
                    .map((d) => _EarningsRow(delivery: d)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.warmGrey500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final RiderDelivery delivery;

  const _EarningsRow({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final payout = delivery.totalAmount * 0.15;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.vendorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.warmGrey900,
                  ),
                ),
                Text(
                  delivery.deliveryAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warmGrey500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '\$${payout.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
