import 'package:equatable/equatable.dart';
import '../data/models/delivery_models.dart';

abstract class DeliveryTrackingState extends Equatable {
  const DeliveryTrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends DeliveryTrackingState {
  const TrackingInitial();
}

class TrackingLoading extends DeliveryTrackingState {
  const TrackingLoading();
}

class TrackingLoaded extends DeliveryTrackingState {
  final DeliveryTracking tracking;

  const TrackingLoaded(this.tracking);

  @override
  List<Object?> get props => [tracking];
}

class TrackingError extends DeliveryTrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
