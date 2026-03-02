import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../../../core/widgets/zb_empty_state.dart';
import '../../bloc/rider_dashboard_bloc.dart';
import '../../data/models/rider_models.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  double _currentLat = -17.8292;
  double _currentLng = 31.0522;

  @override
  void initState() {
    super.initState();
    _loadWithLocation();
  }

  Future<void> _loadWithLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      }
    } catch (_) {
      // Fall back to Harare centre coordinates
    }
    if (mounted) {
      context.read<RiderDashboardBloc>().add(
            LoadRiderDashboard(lat: _currentLat, lng: _currentLng),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Rider Dashboard',
            style: TextStyle(
              color: AppColors.warmGrey900,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            BlocBuilder<RiderDashboardBloc, RiderDashboardState>(
              builder: (context, state) {
                final activeCount = state is RiderDashboardLoaded
                    ? state.active.length
                    : 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => context.push('/rider/earnings'),
                    icon: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.brandOrange, size: 20),
                    label: Text(
                      activeCount > 0 ? '$activeCount active' : 'Earnings',
                      style: const TextStyle(
                        color: AppColors.brandOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.brandOrange,
            labelColor: AppColors.brandOrange,
            unselectedLabelColor: AppColors.warmGrey500,
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'Active'),
            ],
          ),
        ),
        body: BlocBuilder<RiderDashboardBloc, RiderDashboardState>(
          builder: (context, state) {
            if (state is RiderDashboardLoading ||
                state is RiderDashboardInitial) {
              return const ZbLoading(message: 'Loading deliveries...');
            }

            if (state is RiderDashboardError) {
              return ZbErrorWidget(
                message: state.message,
                onRetry: _loadWithLocation,
              );
            }

            final loaded = state as RiderDashboardLoaded;

            return TabBarView(
              children: [
                _AvailableTab(
                  deliveries: loaded.available,
                  currentLat: _currentLat,
                  currentLng: _currentLng,
                  onRefresh: () async {
                    context.read<RiderDashboardBloc>().add(
                          RefreshRiderDashboard(
                              lat: _currentLat, lng: _currentLng),
                        );
                  },
                ),
                _ActiveTab(
                  deliveries: loaded.active,
                  onRefresh: () async {
                    context.read<RiderDashboardBloc>().add(
                          RefreshRiderDashboard(
                              lat: _currentLat, lng: _currentLng),
                        );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Available Tab ─────────────────────────────────────────────────────────────

class _AvailableTab extends StatelessWidget {
  final List<RiderDelivery> deliveries;
  final double currentLat;
  final double currentLng;
  final Future<void> Function() onRefresh;

  const _AvailableTab({
    required this.deliveries,
    required this.currentLat,
    required this.currentLng,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (deliveries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.brandOrange,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            ZbEmptyState(
              icon: Icons.delivery_dining_outlined,
              title: 'No available deliveries',
              subtitle: 'New orders will appear here automatically.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.brandOrange,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return _AvailableDeliveryCard(
            delivery: delivery,
            currentLat: currentLat,
            currentLng: currentLng,
          );
        },
      ),
    );
  }
}

class _AvailableDeliveryCard extends StatelessWidget {
  final RiderDelivery delivery;
  final double currentLat;
  final double currentLng;

  const _AvailableDeliveryCard({
    required this.delivery,
    required this.currentLat,
    required this.currentLng,
  });

  void _showAcceptSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Accept Delivery?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmGrey900,
                ),
              ),
              const SizedBox(height: 16),
              _SheetInfoRow(
                icon: Icons.store_outlined,
                label: 'Pickup',
                value: delivery.vendorName,
              ),
              const SizedBox(height: 10),
              _SheetInfoRow(
                icon: Icons.place_outlined,
                label: 'Drop-off',
                value: delivery.deliveryAddress,
              ),
              const SizedBox(height: 10),
              _SheetInfoRow(
                icon: Icons.attach_money,
                label: 'Payout',
                value:
                    '\$${(delivery.totalAmount * 0.15).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.read<RiderDashboardBloc>().add(
                              AcceptRiderDelivery(
                                deliveryId: delivery.id,
                                riderLat: currentLat,
                                riderLng: currentLng,
                              ),
                            );
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final payout = delivery.totalAmount * 0.15;
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delivery_dining,
                      color: AppColors.brandOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.vendorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.warmGrey900,
                        ),
                      ),
                      Text(
                        'Order #${delivery.orderId.substring(0, 8)}',
                        style: const TextStyle(
                          color: AppColors.warmGrey500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${payout.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AddressRow(
              icon: Icons.radio_button_checked,
              iconColor: AppColors.success,
              label: delivery.pickupAddress,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 14,
                child: VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.warmGrey300),
              ),
            ),
            _AddressRow(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: delivery.deliveryAddress,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _showAcceptSheet(context),
                child: const Text(
                  'Accept',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Tab ────────────────────────────────────────────────────────────────

class _ActiveTab extends StatelessWidget {
  final List<RiderDelivery> deliveries;
  final Future<void> Function() onRefresh;

  const _ActiveTab({required this.deliveries, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (deliveries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.brandOrange,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            ZbEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No active deliveries',
              subtitle: 'Accept an available delivery to get started.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.brandOrange,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return _ActiveDeliveryCard(delivery: delivery);
        },
      ),
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  final RiderDelivery delivery;

  const _ActiveDeliveryCard({required this.delivery});

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return AppColors.info;
      case 'PICKED_UP':
        return AppColors.brandOrange;
      case 'DELIVERED':
        return AppColors.success;
      default:
        return AppColors.warmGrey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(delivery.status);
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    delivery.vendorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.warmGrey900,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    delivery.status.replaceAll('_', ' '),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _AddressRow(
              icon: Icons.radio_button_checked,
              iconColor: AppColors.success,
              label: delivery.pickupAddress,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 12,
                child: VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.warmGrey300),
              ),
            ),
            _AddressRow(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: delivery.deliveryAddress,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandOrange,
                  side: const BorderSide(color: AppColors.brandOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () =>
                    context.push('/rider/delivery/${delivery.id}'),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text(
                  'Open Map',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.warmGrey700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SheetInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SheetInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.warmGrey500),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.warmGrey500,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.warmGrey900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
