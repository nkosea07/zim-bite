import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/maps/app_map.dart';
import '../../../../core/widgets/zb_loading.dart';
import '../../../../core/widgets/zb_error_widget.dart';
import '../../bloc/delivery_tracking_bloc.dart';
import '../../bloc/delivery_tracking_event.dart';
import '../../bloc/delivery_tracking_state.dart';
import '../../data/models/delivery_models.dart';
import '../../data/repositories/delivery_repository.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String orderId;

  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  late final DeliveryTrackingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DeliveryTrackingBloc(context.read<DeliveryRepository>());
    _bloc.add(StartTracking(widget.orderId));
  }

  @override
  void dispose() {
    _bloc.add(const StopTracking());
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track Delivery'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _bloc.add(const RefreshTracking()),
                  tooltip: 'Refresh',
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(
          builder: (context, state) {
            if (state is TrackingLoading) {
              return const ZbLoading(message: 'Finding your rider...');
            }

            if (state is TrackingError) {
              return ZbErrorWidget(
                message: state.message,
                onRetry: () => _bloc.add(StartTracking(widget.orderId)),
              );
            }

            final tracking =
                state is TrackingLoaded ? state.tracking : null;

            return _TrackingBody(
              tracking: tracking,
              orderId: widget.orderId,
            );
          },
        ),
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  final DeliveryTracking? tracking;
  final String orderId;

  static const MapCoordinate _harareCenter = MapCoordinate(
    latitude: -17.825166,
    longitude: 31.03351,
  );

  const _TrackingBody({required this.tracking, required this.orderId});

  MapCoordinate get _driverPosition {
    final t = tracking;
    if (t?.currentLatitude != null && t?.currentLongitude != null) {
      return MapCoordinate(
          latitude: t!.currentLatitude!, longitude: t.currentLongitude!);
    }
    return _harareCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map fills entire screen
        Positioned.fill(
          child: AppMap(
            center: _driverPosition,
            zoom: 14,
            pins: [
              MapPin(
                id: 'driver',
                position: _driverPosition,
                color: AppColors.brandOrange,
              ),
              // Approximate destination (centre of Harare)
              const MapPin(
                id: 'destination',
                position: _harareCenter,
                color: AppColors.info,
              ),
            ],
          ),
        ),

        // Map provider label
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6),
              ],
            ),
            child: const Text(
              'OpenStreetMap',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.warmGrey700,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Bottom draggable info sheet
        DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.65,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -2)),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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

                  // Status chip
                  _StatusChip(status: tracking?.status ?? 'Pending'),
                  const SizedBox(height: 16),

                  // ETA
                  _EtaRow(estimatedArrival: tracking?.estimatedArrival),
                  const SizedBox(height: 16),

                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Driver info
                  _DriverInfo(
                    driverName: tracking?.driverName,
                    driverPhone: tracking?.driverPhone,
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _color() {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'out_for_delivery':
      case 'out for delivery':
        return AppColors.info;
      case 'picked_up':
      case 'en_route':
        return AppColors.brandOrange;
      default:
        return AppColors.warmGrey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final label = status.replaceAll('_', ' ').toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EtaRow extends StatelessWidget {
  final DateTime? estimatedArrival;

  const _EtaRow({this.estimatedArrival});

  @override
  Widget build(BuildContext context) {
    final eta = estimatedArrival != null
        ? DateFormat('h:mm a').format(estimatedArrival!)
        : 'Calculating...';

    final diff = estimatedArrival?.difference(DateTime.now());
    final minsLeft = diff != null && diff.inMinutes > 0
        ? '${diff.inMinutes} min away'
        : null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.brandOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time,
              color: AppColors.brandOrange, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimated Arrival',
                style: TextStyle(
                    color: AppColors.warmGrey500, fontSize: 12)),
            Text(eta,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18)),
            if (minsLeft != null)
              Text(minsLeft,
                  style: const TextStyle(
                      color: AppColors.brandOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _DriverInfo extends StatelessWidget {
  final String? driverName;
  final String? driverPhone;

  const _DriverInfo({this.driverName, this.driverPhone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.warmGrey100,
          child: const Icon(Icons.person, color: AppColors.warmGrey500, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName ?? 'Assigning rider...',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
              if (driverPhone != null)
                Text(driverPhone!,
                    style: const TextStyle(
                        color: AppColors.warmGrey500, fontSize: 13)),
            ],
          ),
        ),
            if (driverPhone != null)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${driverPhone ?? ''}...')),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.phone,
                  color: AppColors.success, size: 22),
            ),
          ),
      ],
    );
  }
}
