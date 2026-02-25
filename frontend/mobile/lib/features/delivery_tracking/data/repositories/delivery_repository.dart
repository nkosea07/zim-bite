import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/delivery_models.dart';

class DeliveryRepository {
  final Dio _dio;

  DeliveryRepository(this._dio);

  Future<DeliveryTracking> getTracking(String orderId) async {
    final response = await _dio.get(ApiEndpoints.deliveryTracking(orderId));
    return DeliveryTracking.fromJson(response.data);
  }
}
