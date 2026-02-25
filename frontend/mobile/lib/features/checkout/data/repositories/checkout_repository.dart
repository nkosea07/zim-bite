import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/checkout_models.dart';

class CheckoutRepository {
  final Dio _dio;

  CheckoutRepository(this._dio);

  Future<Map<String, dynamic>> placeOrder(PlaceOrderRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.orders,
      data: request.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<PaymentInitiateResponse> initiatePayment(
    PaymentInitiateRequest request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.paymentsInitiate,
      data: request.toJson(),
    );
    return PaymentInitiateResponse.fromJson(response.data);
  }
}
