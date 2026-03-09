import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../menu/data/models/menu_models.dart';

class VendorDashboardRepository {
  final Dio _dio;

  VendorDashboardRepository(this._dio);

  Future<Map<String, dynamic>> getVendorStats(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.vendorStats(vendorId));
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getVendor(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.vendor(vendorId));
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createVendor({
    required String ownerUserId,
    required String name,
    required String phoneNumber,
    String? description,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.vendors,
      data: {
        'ownerUserId': ownerUserId,
        'name': name,
        'phoneNumber': phoneNumber,
        if (description != null) 'description': description,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<void> updateVendor(
      String vendorId, Map<String, dynamic> data) async {
    await _dio.patch(ApiEndpoints.vendor(vendorId), data: data);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _dio.get(ApiEndpoints.orders);
    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<List<MenuItem>> getMenuItems(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.menuItems(vendorId));
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => MenuItem.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<MenuItem> createMenuItem(
      String vendorId, Map<String, dynamic> data) async {
    final response =
        await _dio.post(ApiEndpoints.menuItems(vendorId), data: data);
    return MenuItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> toggleMenuItemAvailability(
      String itemId, bool available) async {
    await _dio.patch(
      ApiEndpoints.menuItemAvailability(itemId),
      data: {'available': available},
    );
  }

  Future<Map<String, dynamic>> getAnalytics(String vendorId) async {
    final response =
        await _dio.get(ApiEndpoints.vendorDashboardAnalytics(vendorId));
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getReviews(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.vendorReviews(vendorId));
    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
