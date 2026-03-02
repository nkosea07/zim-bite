import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/rider_models.dart';

class RiderRepository {
  final Dio _dio;

  RiderRepository(Dio dio) : _dio = dio;

  Future<List<RiderDelivery>> getAvailableDeliveries({
    required double lat,
    required double lng,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.riderAvailableDeliveries,
      queryParameters: {'lat': lat, 'lng': lng},
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => RiderDelivery.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RiderDelivery> acceptDelivery({
    required String deliveryId,
    required double riderLat,
    required double riderLng,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.acceptDelivery(deliveryId),
      data: {'riderLat': riderLat, 'riderLng': riderLng},
    );
    return RiderDelivery.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RiderDelivery>> getActiveDeliveries() async {
    final response = await _dio.get(ApiEndpoints.riderActiveDeliveries);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => RiderDelivery.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus({
    required String deliveryId,
    required String status,
  }) async {
    await _dio.patch(
      ApiEndpoints.updateDeliveryStatus(deliveryId),
      data: {'status': status},
    );
  }

  Future<List<ChatMessage>> getChatHistory(String deliveryId) async {
    final response = await _dio.get(ApiEndpoints.deliveryChat(deliveryId));
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
