// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  city: json['city'] as String,
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  isOpen: json['isOpen'] as bool,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'city': instance.city,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isOpen': instance.isOpen,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'categories': instance.categories,
    };

_$VendorDetailImpl _$$VendorDetailImplFromJson(Map<String, dynamic> json) =>
    _$VendorDetailImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      city: json['city'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      isOpen: json['isOpen'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      address: json['address'] as String,
      phone: json['phone'] as String,
      openingHours: json['openingHours'] as String,
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      minimumOrder: (json['minimumOrder'] as num).toDouble(),
      estimatedDeliveryMinutes: (json['estimatedDeliveryMinutes'] as num)
          .toInt(),
    );

Map<String, dynamic> _$$VendorDetailImplToJson(_$VendorDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'city': instance.city,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isOpen': instance.isOpen,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'categories': instance.categories,
      'address': instance.address,
      'phone': instance.phone,
      'openingHours': instance.openingHours,
      'deliveryFee': instance.deliveryFee,
      'minimumOrder': instance.minimumOrder,
      'estimatedDeliveryMinutes': instance.estimatedDeliveryMinutes,
    };

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
  id: json['id'] as String,
  vendorId: json['vendorId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorId': instance.vendorId,
      'userId': instance.userId,
      'userName': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CreateReviewRequestImpl _$$CreateReviewRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateReviewRequestImpl(
  vendorId: json['vendorId'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$$CreateReviewRequestImplToJson(
  _$CreateReviewRequestImpl instance,
) => <String, dynamic>{
  'vendorId': instance.vendorId,
  'rating': instance.rating,
  'comment': instance.comment,
};
