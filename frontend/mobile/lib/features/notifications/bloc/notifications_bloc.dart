import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/notification_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _notificationRepository;

  NotificationsBloc(this._notificationRepository)
      : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllRead>(_onMarkAllRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      final notifications = await _notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } on ApiException catch (e) {
      emit(NotificationsError(e.message));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistically update local state
    final updated = current.notifications.map((n) {
      if (n.id == event.id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    emit(NotificationsLoaded(updated));

    try {
      await _notificationRepository.markAsRead(event.id);
    } on ApiException catch (_) {
      // Revert on failure
      emit(current);
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistically mark all as read
    final updated =
        current.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationsLoaded(updated));

    try {
      // Mark each unread notification via API
      for (final n in current.notifications.where((n) => !n.isRead)) {
        await _notificationRepository.markAsRead(n.id);
      }
    } on ApiException catch (_) {
      emit(current);
    } catch (_) {
      emit(current);
    }
  }
}
