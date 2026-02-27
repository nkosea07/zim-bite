import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/delivery_repository.dart';
import 'delivery_tracking_event.dart';
import 'delivery_tracking_state.dart';

class DeliveryTrackingBloc
    extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  final DeliveryRepository _deliveryRepository;
  Timer? _pollingTimer;
  String? _currentOrderId;

  static const _pollInterval = Duration(seconds: 15);

  DeliveryTrackingBloc(this._deliveryRepository)
      : super(const TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<RefreshTracking>(_onRefreshTracking);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    _cancelTimer();
    _currentOrderId = event.orderId;
    emit(const TrackingLoading());

    // Initial fetch
    await _fetchTracking(emit);

    // Start polling every 15 seconds
    _pollingTimer = Timer.periodic(_pollInterval, (_) {
      if (!isClosed) {
        add(const RefreshTracking());
      }
    });
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    _cancelTimer();
    _currentOrderId = null;
  }

  Future<void> _onRefreshTracking(
    RefreshTracking event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    await _fetchTracking(emit);
  }

  Future<void> _fetchTracking(Emitter<DeliveryTrackingState> emit) async {
    final orderId = _currentOrderId;
    if (orderId == null) return;

    try {
      final tracking = await _deliveryRepository.getTracking(orderId);
      emit(TrackingLoaded(tracking));
    } on ApiException catch (e) {
      emit(TrackingError(e.message));
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  void _cancelTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
