import 'package:equatable/equatable.dart';
import '../data/models/subscription_models.dart';

abstract class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

class SubscriptionsInitial extends SubscriptionsState {
  const SubscriptionsInitial();
}

class SubscriptionsLoading extends SubscriptionsState {
  const SubscriptionsLoading();
}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<Subscription> subscriptions;

  const SubscriptionsLoaded(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionsError extends SubscriptionsState {
  final String message;

  const SubscriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
