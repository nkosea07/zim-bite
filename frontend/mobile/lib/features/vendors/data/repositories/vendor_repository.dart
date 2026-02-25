import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/vendor_models.dart';

class VendorRepository {
  final Dio _dio;

  VendorRepository(this._dio);

  Future<List<Vendor>> getVendors({
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (radiusKm != null) queryParams['radiusKm'] = radiusKm;

    final response = await _dio.get(
      ApiEndpoints.vendors,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data as List)
        .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<VendorDetail> getVendor(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.vendor(vendorId));
    return VendorDetail.fromJson(response.data);
  }

  Future<List<Review>> getVendorReviews(String vendorId) async {
    final response = await _dio.get(ApiEndpoints.vendorReviews(vendorId));
    return (response.data as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createReview(CreateReviewRequest request) async {
    await _dio.post(
      ApiEndpoints.vendorReviews(request.vendorId),
      data: request.toJson(),
    );
  }
}
