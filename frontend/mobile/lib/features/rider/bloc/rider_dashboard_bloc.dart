import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/rider_models.dart';
import '../data/repositories/rider_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class RiderDashboardEvent extends Equatable {
  const RiderDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadRiderDashboard extends RiderDashboardEvent {
  final double lat;
  final double lng;
  const LoadRiderDashboard({required this.lat, required this.lng});
  @override
  List<Object?> get props => [lat, lng];
}

class RefreshRiderDashboard extends RiderDashboardEvent {
  final double lat;
  final double lng;
  const RefreshRiderDashboard({required this.lat, required this.lng});
  @override
  List<Object?> get props => [lat, lng];
}

class AcceptRiderDelivery extends RiderDashboardEvent {
  final String deliveryId;
  final double riderLat;
  final double riderLng;
  const AcceptRiderDelivery({
    required this.deliveryId,
    required this.riderLat,
    required this.riderLng,
  });
  @override
  List<Object?> get props => [deliveryId, riderLat, riderLng];
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class RiderDashboardState extends Equatable {
  const RiderDashboardState();
  @override
  List<Object?> get props => [];
}

class RiderDashboardInitial extends RiderDashboardState {}

class RiderDashboardLoading extends RiderDashboardState {}

class RiderDashboardLoaded extends RiderDashboardState {
  final List<RiderDelivery> available;
  final List<RiderDelivery> active;
  const RiderDashboardLoaded({required this.available, required this.active});
  @override
  List<Object?> get props => [available, active];
}

class RiderDashboardError extends RiderDashboardState {
  final String message;
  const RiderDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class RiderDashboardBloc
    extends Bloc<RiderDashboardEvent, RiderDashboardState> {
  final RiderRepository _repository;
  Timer? _refreshTimer;
  double _lastLat = -17.8292;
  double _lastLng = 31.0522;

  RiderDashboardBloc(this._repository) : super(RiderDashboardInitial()) {
    on<LoadRiderDashboard>(_onLoad);
    on<RefreshRiderDashboard>(_onRefresh);
    on<AcceptRiderDelivery>(_onAccept);
  }

  Future<void> _onLoad(
      LoadRiderDashboard event, Emitter<RiderDashboardState> emit) async {
    _lastLat = event.lat;
    _lastLng = event.lng;
    emit(RiderDashboardLoading());
    await _fetchAndEmit(event.lat, event.lng, emit);
    _startAutoRefresh();
  }

  Future<void> _onRefresh(
      RefreshRiderDashboard event, Emitter<RiderDashboardState> emit) async {
    _lastLat = event.lat;
    _lastLng = event.lng;
    await _fetchAndEmit(event.lat, event.lng, emit);
  }

  Future<void> _onAccept(
      AcceptRiderDelivery event, Emitter<RiderDashboardState> emit) async {
    try {
      await _repository.acceptDelivery(
        deliveryId: event.deliveryId,
        riderLat: event.riderLat,
        riderLng: event.riderLng,
      );
      await _fetchAndEmit(_lastLat, _lastLng, emit);
    } catch (e) {
      emit(RiderDashboardError(e.toString()));
    }
  }

  Future<void> _fetchAndEmit(
      double lat, double lng, Emitter<RiderDashboardState> emit) async {
    try {
      final available =
          await _repository.getAvailableDeliveries(lat: lat, lng: lng);
      final active = await _repository.getActiveDeliveries();
      emit(RiderDashboardLoaded(available: available, active: active));
    } catch (e) {
      emit(RiderDashboardError(e.toString()));
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(RefreshRiderDashboard(lat: _lastLat, lng: _lastLng));
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
