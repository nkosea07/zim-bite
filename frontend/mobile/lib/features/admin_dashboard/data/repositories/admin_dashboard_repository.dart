import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';

class AdminDashboardRepository {
  final Dio _dio;

  AdminDashboardRepository(this._dio);

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _dio.get(ApiEndpoints.adminOverview);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getVendors() async {
    final response = await _dio.get(ApiEndpoints.vendors);
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getRevenueTrends() async {
    final response = await _dio.get(ApiEndpoints.revenueTrends);
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }
}
