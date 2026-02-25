import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_models.freezed.dart';
part 'vendor_models.g.dart';

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required String city,
    required double rating,
    required int reviewCount,
    required bool isOpen,
    required double latitude,
    required double longitude,
    required List<String> categories,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}

@freezed
class VendorDetail with _$VendorDetail {
  const factory VendorDetail({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required String city,
    required double rating,
    required int reviewCount,
    required bool isOpen,
    required double latitude,
    required double longitude,
    required List<String> categories,
    required String address,
    required String phone,
    required String openingHours,
    required double deliveryFee,
    required double minimumOrder,
    required int estimatedDeliveryMinutes,
  }) = _VendorDetail;

  factory VendorDetail.fromJson(Map<String, dynamic> json) =>
      _$VendorDetailFromJson(json);
}

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String vendorId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    required DateTime createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}

@freezed
class CreateReviewRequest with _$CreateReviewRequest {
  const factory CreateReviewRequest({
    required String vendorId,
    required int rating,
    required String comment,
  }) = _CreateReviewRequest;

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);
}
