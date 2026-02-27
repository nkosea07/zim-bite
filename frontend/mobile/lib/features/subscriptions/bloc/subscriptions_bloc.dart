import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/subscription_repository.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionsBloc(this._subscriptionRepository)
      : super(const SubscriptionsInitial()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
    on<PauseSubscription>(_onPauseSubscription);
    on<ResumeSubscription>(_onResumeSubscription);
    on<CancelSubscription>(_onCancelSubscription);
  }

  Future<void> _onLoadSubscriptions(
    LoadSubscriptions event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(const SubscriptionsLoading());
    try {
      final subscriptions = await _subscriptionRepository.getSubscriptions();
      emit(SubscriptionsLoaded(subscriptions));
    } on ApiException catch (e) {
      emit(SubscriptionsError(e.message));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> _onPauseSubscription(
    PauseSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    try {
      await _subscriptionRepository.pauseSubscription(event.id);
      add(const LoadSubscriptions());
    } on ApiException catch (e) {
      emit(SubscriptionsError(e.message));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> _onResumeSubscription(
    ResumeSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    try {
      await _subscriptionRepository.resumeSubscription(event.id);
      add(const LoadSubscriptions());
    } on ApiException catch (e) {
      emit(SubscriptionsError(e.message));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    try {
      await _subscriptionRepository.cancelSubscription(event.id);
      add(const LoadSubscriptions());
    } on ApiException catch (e) {
      emit(SubscriptionsError(e.message));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }
}
