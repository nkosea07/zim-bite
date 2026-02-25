import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    required String phone,
    String? email,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    required String label,
    required String street,
    required String city,
    required double latitude,
    required double longitude,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@freezed
class CreateAddressRequest with _$CreateAddressRequest {
  const factory CreateAddressRequest({
    required String label,
    required String street,
    required String city,
    required double latitude,
    required double longitude,
  }) = _CreateAddressRequest;

  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressRequestFromJson(json);
}
