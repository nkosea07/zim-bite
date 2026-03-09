import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String principal,
    required String password,
  }) = _LoginRequest;
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginChallengeResponse with _$LoginChallengeResponse {
  const factory LoginChallengeResponse({
    required String challengeId,
    required String principal,
    required DateTime expiresAt,
    required int attemptsRemaining,
    required String status,
  }) = _LoginChallengeResponse;
  factory LoginChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginChallengeResponseFromJson(json);
}

@freezed
class OtpVerifyRequest with _$OtpVerifyRequest {
  const factory OtpVerifyRequest({
    required String principal,
    required String otp,
  }) = _OtpVerifyRequest;
  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);
}

@freezed
class AuthTokensResponse with _$AuthTokensResponse {
  const factory AuthTokensResponse({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) = _AuthTokensResponse;
  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensResponseFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String? role,
  }) = _RegisterRequest;
  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
