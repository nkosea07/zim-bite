import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository(this._dio, this._tokenStorage);

  Future<LoginChallengeResponse> login({
    required String principal,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: LoginRequest(principal: principal, password: password).toJson(),
    );
    return LoginChallengeResponse.fromJson(response.data);
  }

  Future<AuthTokensResponse> verifyOtp({
    required String principal,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: OtpVerifyRequest(principal: principal, otp: otp).toJson(),
    );
    final tokens = AuthTokensResponse.fromJson(response.data);
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiEndpoints.register, data: request.toJson());
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}
