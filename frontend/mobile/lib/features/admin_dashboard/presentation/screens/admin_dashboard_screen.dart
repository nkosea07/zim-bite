import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/admin_dashboard_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardBloc>().add(LoadAdminDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: AppColors.warmGrey900,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.brandOrange,
            labelColor: AppColors.brandOrange,
            unselectedLabelColor: AppColors.warmGrey500,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Vendors'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (context, state) {
            if (state is AdminDashboardLoading ||
                state is AdminDashboardInitial) {
              return const ZbLoading(message: 'Loading dashboard...');
            }

            if (state is AdminDashboardError) {
              return ZbErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<AdminDashboardBloc>()
                    .add(LoadAdminDashboard()),
              );
            }

            final loaded = state as AdminDashboardLoaded;

            return TabBarView(
              children: [
                _OverviewTab(
                  overview: loaded.overview,
                  vendors: loaded.vendors,
                ),
                _VendorsTab(vendors: loaded.vendors),
                _AnalyticsTab(
                  overview: loaded.overview,
                  revenue: loaded.revenue,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> vendors;

  const _OverviewTab({required this.overview, required this.vendors});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardBloc>().add(RefreshAdminDashboard());
      },
      color: AppColors.brandOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _StatCard(
                icon: Icons.storefront,
                value: '${overview['activeVendors'] ?? 0}',
                label: 'Vendors',
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.delivery_dining,
                value: '${overview['activeRiders'] ?? 0}',
                label: 'Riders',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                icon: Icons.receipt_long,
                value: '${overview['ordersToday'] ?? 0}',
                label: 'Orders Today',
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.attach_money,
                value:
                    '\$${(overview['revenueToday'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                label: 'Revenue Today',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Vendors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.warmGrey900,
            ),
          ),
          const SizedBox(height: 12),
          if (vendors.isEmpty)
            const ZbEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No vendors',
              subtitle: 'Vendors will appear here once they register.',
            )
          else
            ...vendors.take(5).map((v) => _VendorCard(vendor: v)),
        ],
      ),
    );
  }
}

// ── Vendors Tab ───────────────────────────────────────────────────────────────

class _VendorsTab extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;
  const _VendorsTab({required this.vendors});

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AdminDashboardBloc>().add(RefreshAdminDashboard());
        },
        color: AppColors.brandOrange,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            ZbEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No vendors',
              subtitle: 'Vendors will appear once they register.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardBloc>().add(RefreshAdminDashboard());
      },
      color: AppColors.brandOrange,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vendors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _VendorCard(vendor: vendors[i]),
      ),
    );
  }
}

// ── Analytics Tab ─────────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> revenue;

  const _AnalyticsTab({required this.overview, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardBloc>().add(RefreshAdminDashboard());
      },
      color: AppColors.brandOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _StatCard(
                icon: Icons.receipt_long,
                value: '${overview['ordersToday'] ?? 0}',
                label: 'Orders Today',
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.attach_money,
                value:
                    '\$${(overview['revenueToday'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                label: 'Revenue Today',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Revenue Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.warmGrey900,
            ),
          ),
          const SizedBox(height: 12),
          if (revenue.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Center(
                child: Text(
                  'No revenue data yet.',
                  style: TextStyle(
                    color: AppColors.warmGrey500,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            _RevenueChart(data: revenue),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.warmGrey900,
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
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final name = vendor['name'] ?? 'Unknown';
    final city = vendor['city'] ?? '';
    final isOpen = vendor['open'] == true;
    final rating = (vendor['rating'] as num?)?.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront,
                color: AppColors.brandOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.warmGrey900,
                  ),
                ),
                Text(
                  city as String,
                  style: const TextStyle(
                    color: AppColors.warmGrey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (rating != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.warmGrey700,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warmGrey300.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                color: isOpen ? AppColors.success : AppColors.warmGrey500,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxAmount =
        data.map((d) => (d['amount'] as num?)?.toDouble() ?? 0).fold(0.0, (a, b) => a > b ? a : b);
    final barMax = maxAmount > 0 ? maxAmount : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final amount = (d['amount'] as num?)?.toDouble() ?? 0;
                final pct = amount / barMax;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.warmGrey500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: pct * 120,
                          decoration: BoxDecoration(
                            color: AppColors.brandOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.map((d) {
              return Expanded(
                child: Text(
                  (d['period'] ?? '') as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.warmGrey500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
