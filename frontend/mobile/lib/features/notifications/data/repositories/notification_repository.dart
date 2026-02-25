import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<AppNotification>> getNotifications({bool? unreadOnly}) async {
    final queryParams = <String, dynamic>{};
    if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.post(ApiEndpoints.notificationRead(id));
  }

  Future<NotificationPreferences> getPreferences() async {
    final response = await _dio.get(ApiEndpoints.notificationPreferences);
    return NotificationPreferences.fromJson(response.data);
  }

  Future<void> updatePreferences(NotificationPreferences prefs) async {
    await _dio.patch(
      ApiEndpoints.notificationPreferences,
      data: prefs.toJson(),
    );
  }
}
