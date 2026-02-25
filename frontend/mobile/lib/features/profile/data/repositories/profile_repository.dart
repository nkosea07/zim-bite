import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_models.dart';
import '../../../vendors/data/models/vendor_models.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    final response = await _dio.get(ApiEndpoints.userMe);
    return UserProfile.fromJson(response.data);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dio.patch(ApiEndpoints.userMe, data: data);
  }

  Future<List<Address>> getAddresses() async {
    final response = await _dio.get(ApiEndpoints.userAddresses);
    return (response.data as List)
        .map((json) => Address.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAddress(CreateAddressRequest request) async {
    await _dio.post(ApiEndpoints.userAddresses, data: request.toJson());
  }

  Future<List<Vendor>> getFavorites() async {
    final response = await _dio.get(ApiEndpoints.userFavorites);
    return (response.data as List)
        .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
