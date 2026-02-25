import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/menu_models.dart';

class MenuRepository {
  final Dio _dio;

  MenuRepository(this._dio);

  Future<List<MenuItem>> getMenuItems(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.menuItems(vendorId));
    return (response.data as List)
        .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MenuItem> getMenuItem(String itemId) async {
    final response = await _dio.get(ApiEndpoints.menuItem(itemId));
    return MenuItem.fromJson(response.data);
  }
}
