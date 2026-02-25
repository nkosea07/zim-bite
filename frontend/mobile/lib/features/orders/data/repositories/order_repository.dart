import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/order_models.dart';

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  Future<List<Order>> getOrders() async {
    final response = await _dio.get(ApiEndpoints.orders);
    return (response.data as List)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDetail> getOrder(String orderId) async {
    final response = await _dio.get(ApiEndpoints.order(orderId));
    return OrderDetail.fromJson(response.data);
  }

  Future<void> cancelOrder(String orderId) async {
    await _dio.post(ApiEndpoints.cancelOrder(orderId));
  }
}
