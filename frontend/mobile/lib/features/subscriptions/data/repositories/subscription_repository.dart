import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/subscription_models.dart';

class SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepository(this._dio);

  Future<List<Subscription>> getSubscriptions() async {
    final response = await _dio.get(ApiEndpoints.subscriptions);
    return (response.data as List)
        .map((json) => Subscription.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Subscription> getSubscription(String id) async {
    final response = await _dio.get(ApiEndpoints.subscription(id));
    return Subscription.fromJson(response.data);
  }

  Future<void> createSubscription(CreateSubscriptionRequest request) async {
    await _dio.post(ApiEndpoints.subscriptions, data: request.toJson());
  }

  Future<void> pauseSubscription(String id) async {
    await _dio.post(ApiEndpoints.subscriptionPause(id));
  }

  Future<void> resumeSubscription(String id) async {
    await _dio.post(ApiEndpoints.subscriptionResume(id));
  }

  Future<void> cancelSubscription(String id) async {
    await _dio.post(ApiEndpoints.subscriptionCancel(id));
  }
}
