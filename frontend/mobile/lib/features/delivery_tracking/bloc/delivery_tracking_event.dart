import 'package:equatable/equatable.dart';

abstract class DeliveryTrackingEvent extends Equatable {
  const DeliveryTrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTracking extends DeliveryTrackingEvent {
  final String orderId;

  const StartTracking(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StopTracking extends DeliveryTrackingEvent {
  const StopTracking();
}

class RefreshTracking extends DeliveryTrackingEvent {
  const RefreshTracking();
}
