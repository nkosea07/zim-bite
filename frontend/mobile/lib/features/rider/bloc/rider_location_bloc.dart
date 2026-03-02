import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ── Events ───────────────────────────────────────────────────────────────────

abstract class RiderLocationEvent extends Equatable {
  const RiderLocationEvent();
  @override
  List<Object?> get props => [];
}

class StartLocationBroadcast extends RiderLocationEvent {
  final String deliveryId;
  final String wsUrl;
  const StartLocationBroadcast({required this.deliveryId, required this.wsUrl});
  @override
  List<Object?> get props => [deliveryId, wsUrl];
}

class StopLocationBroadcast extends RiderLocationEvent {}

class _LocationReceived extends RiderLocationEvent {
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  const _LocationReceived(
      {required this.lat, required this.lng, this.heading, this.speed});
  @override
  List<Object?> get props => [lat, lng];
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class RiderLocationState extends Equatable {
  const RiderLocationState();
  @override
  List<Object?> get props => [];
}

class LocationBroadcastIdle extends RiderLocationState {}

class LocationBroadcastActive extends RiderLocationState {
  final double lat;
  final double lng;
  final String deliveryId;
  const LocationBroadcastActive(
      {required this.lat, required this.lng, required this.deliveryId});
  @override
  List<Object?> get props => [lat, lng, deliveryId];
}

class LocationBroadcastError extends RiderLocationState {
  final String message;
  const LocationBroadcastError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class RiderLocationBloc extends Bloc<RiderLocationEvent, RiderLocationState> {
  WebSocketChannel? _channel;
  StreamSubscription<Position>? _positionSub;
  String? _deliveryId;

  RiderLocationBloc() : super(LocationBroadcastIdle()) {
    on<StartLocationBroadcast>(_onStart);
    on<StopLocationBroadcast>(_onStop);
    on<_LocationReceived>(_onLocationReceived);
  }

  Future<void> _onStart(
      StartLocationBroadcast event, Emitter<RiderLocationState> emit) async {
    _deliveryId = event.deliveryId;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        emit(const LocationBroadcastError('Location permission denied'));
        return;
      }

      _channel = WebSocketChannel.connect(Uri.parse(event.wsUrl));

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      _positionSub =
          Geolocator.getPositionStream(locationSettings: settings).listen(
        (pos) {
          add(_LocationReceived(
            lat: pos.latitude,
            lng: pos.longitude,
            heading: pos.heading,
            speed: pos.speed * 3.6,
          ));
        },
      );
    } catch (e) {
      emit(LocationBroadcastError(e.toString()));
    }
  }

  void _onStop(StopLocationBroadcast event, Emitter<RiderLocationState> emit) {
    _positionSub?.cancel();
    _channel?.sink.close();
    _positionSub = null;
    _channel = null;
    _deliveryId = null;
    emit(LocationBroadcastIdle());
  }

  void _onLocationReceived(
      _LocationReceived event, Emitter<RiderLocationState> emit) {
    if (_channel == null || _deliveryId == null) return;
    final payload = jsonEncode(<String, dynamic>{
      'deliveryId': _deliveryId,
      'lat': event.lat,
      'lng': event.lng,
      'heading': event.heading,
      'speedKmh': event.speed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    _channel!.sink.add(payload);

    emit(LocationBroadcastActive(
      lat: event.lat,
      lng: event.lng,
      deliveryId: _deliveryId!,
    ));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _channel?.sink.close();
    return super.close();
  }
}
