import 'package:equatable/equatable.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionsEvent {
  const LoadSubscriptions();
}

class PauseSubscription extends SubscriptionsEvent {
  final String id;

  const PauseSubscription(this.id);

  @override
  List<Object?> get props => [id];
}

class ResumeSubscription extends SubscriptionsEvent {
  final String id;

  const ResumeSubscription(this.id);

  @override
  List<Object?> get props => [id];
}

class CancelSubscription extends SubscriptionsEvent {
  final String id;

  const CancelSubscription(this.id);

  @override
  List<Object?> get props => [id];
}
