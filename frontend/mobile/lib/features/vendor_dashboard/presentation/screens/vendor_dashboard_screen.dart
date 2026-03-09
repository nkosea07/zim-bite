import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../../menu/data/models/menu_models.dart';
import '../../bloc/vendor_dashboard_bloc.dart';

class VendorDashboardScreen extends StatefulWidget {
  final String vendorId;
  const VendorDashboardScreen({super.key, required this.vendorId});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.vendorId.isNotEmpty) {
      context
          .read<VendorDashboardBloc>()
          .add(LoadVendorDashboard(widget.vendorId));
    }
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
            'Vendor Dashboard',
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
              Tab(text: 'Menu'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
          builder: (context, state) {
            if (state is VendorDashboardLoading ||
                state is VendorDashboardInitial) {
              return const ZbLoading(message: 'Loading dashboard...');
            }

            if (state is VendorDashboardError) {
              return ZbErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<VendorDashboardBloc>()
                    .add(LoadVendorDashboard(widget.vendorId)),
              );
            }

            final loaded = state as VendorDashboardLoaded;

            return TabBarView(
              children: [
                _OverviewTab(
                  stats: loaded.stats,
                  orders: loaded.orders,
                  vendorId: widget.vendorId,
                ),
                _MenuTab(
                  menuItems: loaded.menuItems,
                  vendorId: widget.vendorId,
                ),
                _OrdersTab(
                  orders: loaded.orders,
                  vendorId: widget.vendorId,
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
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> orders;
  final String vendorId;

  const _OverviewTab({
    required this.stats,
    required this.orders,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<VendorDashboardBloc>()
            .add(RefreshVendorDashboard(vendorId));
      },
      color: AppColors.brandOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat cards
          Row(
            children: [
              _StatCard(
                icon: Icons.receipt_long,
                value: '${stats['ordersToday'] ?? 0}',
                label: 'Orders Today',
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.attach_money,
                value: '\$${(stats['revenueToday'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                label: 'Revenue Today',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCard(
                icon: Icons.star,
                value: (stats['rating'] as num?)?.toStringAsFixed(1) ?? '-',
                label: 'Rating',
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.inventory_2_outlined,
                value: '${stats['totalOrders'] ?? 0}',
                label: 'Total Orders',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent orders
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.warmGrey900,
            ),
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: ZbEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle: 'Orders from customers will appear here.',
              ),
            )
          else
            ...orders.take(5).map((o) => _OrderCard(order: o)),
        ],
      ),
    );
  }
}

// ── Menu Tab ──────────────────────────────────────────────────────────────────

class _MenuTab extends StatefulWidget {
  final List<MenuItem> menuItems;
  final String vendorId;

  const _MenuTab({required this.menuItems, required this.vendorId});

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    if (name.isEmpty) return;
    context.read<VendorDashboardBloc>().add(AddMenuItem(
          vendorId: widget.vendorId,
          name: name,
          category: category.isEmpty ? 'Breakfast' : category,
          price: price,
        ));
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
    setState(() => _showAddForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<VendorDashboardBloc>()
            .add(RefreshVendorDashboard(widget.vendorId));
      },
      color: AppColors.brandOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Add item button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showAddForm = !_showAddForm),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandOrange,
                side: const BorderSide(color: AppColors.brandOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(_showAddForm ? Icons.close : Icons.add, size: 18),
              label: Text(_showAddForm ? 'Cancel' : 'Add Menu Item'),
            ),
          ),

          // Add item form
          if (_showAddForm) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            hintText: 'Breakfast',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Menu items list
          if (widget.menuItems.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: ZbEmptyState(
                icon: Icons.restaurant_menu_outlined,
                title: 'No menu items',
                subtitle: 'Add your first breakfast item to get started.',
              ),
            )
          else
            ...widget.menuItems.map((item) => _MenuItemCard(
                  item: item,
                  vendorId: widget.vendorId,
                )),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String vendorId;

  const _MenuItemCard({required this.item, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.warmGrey900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category} · \$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.warmGrey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: item.isAvailable,
            onChanged: (val) {
              context.read<VendorDashboardBloc>().add(
                    ToggleMenuItemAvailability(
                      vendorId: vendorId,
                      itemId: item.id,
                      available: val,
                    ),
                  );
            },
            activeTrackColor: AppColors.brandOrange,
          ),
        ],
      ),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final String vendorId;

  const _OrdersTab({required this.orders, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context
              .read<VendorDashboardBloc>()
              .add(RefreshVendorDashboard(vendorId));
        },
        color: AppColors.brandOrange,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            ZbEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Customer orders will appear here.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<VendorDashboardBloc>()
            .add(RefreshVendorDashboard(vendorId));
      },
      color: AppColors.brandOrange,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
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

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.brandOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = (order['orderId'] ?? order['id'] ?? '') as String;
    final status = (order['status'] ?? 'PENDING') as String;
    final amount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
    final scheduled = order['scheduledFor'] as String?;
    final statusColor = _statusColor(status);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.warmGrey900,
                  ),
                ),
                if (scheduled != null)
                  Text(
                    scheduled,
                    style: const TextStyle(
                      color: AppColors.warmGrey500,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.warmGrey900,
            ),
          ),
        ],
      ),
    );
  }
}
