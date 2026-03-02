import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/maps/app_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../bloc/rider_dashboard_bloc.dart';
import '../../bloc/rider_location_bloc.dart';
import '../../data/models/rider_models.dart';
import '../../data/repositories/rider_repository.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final String deliveryId;

  const ActiveDeliveryScreen({super.key, required this.deliveryId});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  late final RiderLocationBloc _locationBloc;
  late final RiderDashboardBloc _dashboardBloc;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = RiderLocationBloc();
    _dashboardBloc = context.read<RiderDashboardBloc>();

    final wsUrl =
        '${EnvConfig.wsBaseUrl}/rider/location/${widget.deliveryId}';
    _locationBloc.add(StartLocationBroadcast(
      deliveryId: widget.deliveryId,
      wsUrl: wsUrl,
    ));
  }

  @override
  void dispose() {
    _locationBloc.add(StopLocationBroadcast());
    _locationBloc.close();
    super.dispose();
  }

  RiderDelivery? _findDelivery(RiderDashboardState state) {
    if (state is RiderDashboardLoaded) {
      final all = [...state.active, ...state.available];
      try {
        return all.firstWhere((d) => d.id == widget.deliveryId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _updateStatus(String newStatus, RiderDelivery delivery) async {
    setState(() => _updatingStatus = true);
    try {
      await context
          .read<RiderRepository>()
          .updateStatus(deliveryId: delivery.id, status: newStatus);
      if (mounted) {
        _dashboardBloc.add(RefreshRiderDashboard(
          lat: delivery.pickupLat,
          lng: delivery.pickupLng,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Future<void> _confirmDelivered(RiderDelivery delivery) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: Text(
          'Confirm delivery at\n"${delivery.deliveryAddress}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _updateStatus('DELIVERED', delivery);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _locationBloc),
        BlocProvider.value(value: _dashboardBloc),
      ],
      child: Scaffold(
        body: BlocBuilder<RiderDashboardBloc, RiderDashboardState>(
          builder: (context, dashState) {
            if (dashState is RiderDashboardLoading ||
                dashState is RiderDashboardInitial) {
              return const ZbLoading(message: 'Loading delivery...');
            }

            final delivery = _findDelivery(dashState);

            if (delivery == null) {
              return ZbErrorWidget(
                message: 'Delivery not found.',
                onRetry: () => _dashboardBloc.add(
                  RefreshRiderDashboard(lat: -17.8292, lng: 31.0522),
                ),
              );
            }

            return _DeliveryBody(
              delivery: delivery,
              locationBloc: _locationBloc,
              updatingStatus: _updatingStatus,
              onPickedUp: () => _updateStatus('PICKED_UP', delivery),
              onDelivered: () => _confirmDelivered(delivery),
              onCallCustomer: delivery.customerPhone != null
                  ? () => _launchPhone(delivery.customerPhone!)
                  : null,
              onChat: () =>
                  context.push('/rider/chat/${delivery.id}'),
              onNavigate: () => _launchNavigation(
                delivery.dropoffLat,
                delivery.dropoffLng,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeliveryBody extends StatelessWidget {
  final RiderDelivery delivery;
  final RiderLocationBloc locationBloc;
  final bool updatingStatus;
  final VoidCallback onPickedUp;
  final VoidCallback onDelivered;
  final VoidCallback? onCallCustomer;
  final VoidCallback onChat;
  final VoidCallback onNavigate;

  static const MapCoordinate _harare =
      MapCoordinate(latitude: -17.8292, longitude: 31.0522);

  const _DeliveryBody({
    required this.delivery,
    required this.locationBloc,
    required this.updatingStatus,
    required this.onPickedUp,
    required this.onDelivered,
    this.onCallCustomer,
    required this.onChat,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen map
        Positioned.fill(
          child: BlocBuilder<RiderLocationBloc, RiderLocationState>(
            bloc: locationBloc,
            builder: (context, locState) {
              final riderPos = locState is LocationBroadcastActive
                  ? MapCoordinate(
                      latitude: locState.lat,
                      longitude: locState.lng,
                    )
                  : _harare;

              return AppMap(
                center: MapCoordinate(
                  latitude: delivery.pickupLat,
                  longitude: delivery.pickupLng,
                ),
                zoom: 13,
                pins: [
                  MapPin(
                    id: 'pickup',
                    position: MapCoordinate(
                      latitude: delivery.pickupLat,
                      longitude: delivery.pickupLng,
                    ),
                    color: AppColors.success,
                  ),
                  MapPin(
                    id: 'dropoff',
                    position: MapCoordinate(
                      latitude: delivery.dropoffLat,
                      longitude: delivery.dropoffLng,
                    ),
                    color: AppColors.error,
                  ),
                  MapPin(
                    id: 'rider',
                    position: riderPos,
                    color: AppColors.info,
                  ),
                ],
              );
            },
          ),
        ),

        // Back button overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.pop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back, color: AppColors.warmGrey900),
              ),
            ),
          ),
        ),

        // Draggable bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.42,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.warmGrey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Status timeline
                  _StatusTimeline(status: delivery.status),
                  const SizedBox(height: 20),

                  // Action card
                  _ActionCard(
                    delivery: delivery,
                    updatingStatus: updatingStatus,
                    onPickedUp: onPickedUp,
                    onDelivered: onDelivered,
                  ),
                  const SizedBox(height: 16),

                  // Quick actions
                  Row(
                    children: [
                      _QuickActionButton(
                        icon: Icons.phone_outlined,
                        label: 'Call',
                        color: AppColors.success,
                        onTap: onCallCustomer,
                      ),
                      const SizedBox(width: 10),
                      _QuickActionButton(
                        icon: Icons.chat_outlined,
                        label: 'Chat',
                        color: AppColors.info,
                        onTap: onChat,
                      ),
                      const SizedBox(width: 10),
                      _QuickActionButton(
                        icon: Icons.navigation_outlined,
                        label: 'Navigate',
                        color: AppColors.brandOrange,
                        onTap: onNavigate,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  static const _steps = ['ASSIGNED', 'PICKED_UP', 'DELIVERED'];

  int get _currentIndex {
    final idx = _steps.indexOf(status.toUpperCase());
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex;
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = (i + 1) ~/ 2;
          final filled = stepIndex <= current;
          return Expanded(
            child: Container(
              height: 3,
              color: filled ? AppColors.brandOrange : AppColors.warmGrey100,
            ),
          );
        }
        // Step circle
        final stepIndex = i ~/ 2;
        final done = stepIndex < current;
        final active = stepIndex == current;
        final label = _steps[stepIndex]
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0] + w.substring(1).toLowerCase())
            .join(' ');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active
                    ? AppColors.brandOrange
                    : AppColors.warmGrey100,
                border: Border.all(
                  color: active
                      ? AppColors.brandOrange
                      : done
                          ? AppColors.brandOrange
                          : AppColors.warmGrey300,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : active
                      ? const Icon(Icons.circle, size: 10, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? AppColors.brandOrange
                    : AppColors.warmGrey500,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final RiderDelivery delivery;
  final bool updatingStatus;
  final VoidCallback onPickedUp;
  final VoidCallback onDelivered;

  const _ActionCard({
    required this.delivery,
    required this.updatingStatus,
    required this.onPickedUp,
    required this.onDelivered,
  });

  @override
  Widget build(BuildContext context) {
    final isAssigned = delivery.status.toUpperCase() == 'ASSIGNED';
    final isPickedUp = delivery.status.toUpperCase() == 'PICKED_UP';

    if (!isAssigned && !isPickedUp) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 10),
            Text(
              'Delivery completed',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmGrey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAssigned
                ? 'Head to ${delivery.vendorName}'
                : 'Deliver to customer',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.warmGrey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAssigned ? delivery.pickupAddress : delivery.deliveryAddress,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.warmGrey500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: updatingStatus
                  ? null
                  : isAssigned
                      ? onPickedUp
                      : onDelivered,
              child: updatingStatus
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isAssigned ? "I've Arrived" : 'Mark Delivered',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: onTap != null
                ? color.withValues(alpha: 0.1)
                : AppColors.warmGrey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap != null
                  ? color.withValues(alpha: 0.3)
                  : AppColors.warmGrey300,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: onTap != null ? color : AppColors.warmGrey300,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? color : AppColors.warmGrey300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
