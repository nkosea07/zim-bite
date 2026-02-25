import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zimbite/core/network/api_endpoints.dart';
import 'package:zimbite/core/storage/token_storage.dart';
import 'package:zimbite/features/auth/data/models/auth_models.dart';
import 'package:zimbite/features/auth/data/repositories/auth_repository.dart';

class MockDio extends Mock implements Dio {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockDio dio;
  late MockTokenStorage tokenStorage;
  late AuthRepository repository;

  setUp(() {
    dio = MockDio();
    tokenStorage = MockTokenStorage();
    repository = AuthRepository(dio, tokenStorage);

    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  });

  test('login sends principal and password', () async {
    Map<String, dynamic>? capturedBody;

    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((
      invocation,
    ) async {
      final data = invocation.namedArguments[#data] as Map<dynamic, dynamic>;
      capturedBody = data.map((key, value) => MapEntry(key as String, value));
      return Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        data: {
          'challengeId': 'challenge-1',
          'principal': 'user@example.com',
          'expiresAt': '2026-02-25T12:00:00Z',
          'attemptsRemaining': 3,
          'status': 'OTP_REQUIRED',
        },
      );
    });

    await repository.login(principal: 'user@example.com', password: 'secret123');

    expect(capturedBody, {
      'principal': 'user@example.com',
      'password': 'secret123',
    });
  });

  test('verifyOtp sends principal and persists tokens', () async {
    Map<String, dynamic>? capturedBody;

    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((
      invocation,
    ) async {
      final data = invocation.namedArguments[#data] as Map<dynamic, dynamic>;
      capturedBody = data.map((key, value) => MapEntry(key as String, value));
      return Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.verifyOtp),
        data: {
          'accessToken': 'new-access-token',
          'refreshToken': 'new-refresh-token',
          'expiresIn': 900,
        },
      );
    });

    await repository.verifyOtp(principal: 'user@example.com', otp: '123456');

    expect(capturedBody, {
      'principal': 'user@example.com',
      'otp': '123456',
    });
    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      ),
    ).called(1);
  });

  test('register sends backend-required fields', () async {
    Map<String, dynamic>? capturedBody;

    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((
      invocation,
    ) async {
      final data = invocation.namedArguments[#data] as Map<dynamic, dynamic>;
      capturedBody = data.map((key, value) => MapEntry(key as String, value));
      return Response<void>(
        requestOptions: RequestOptions(path: ApiEndpoints.register),
      );
    });

    await repository.register(
      const RegisterRequest(
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        phoneNumber: '+263771234567',
        password: 'secret123',
      ),
    );

    expect(capturedBody, {
      'firstName': 'Jane',
      'lastName': 'Doe',
      'email': 'jane@example.com',
      'phoneNumber': '+263771234567',
      'password': 'secret123',
    });
  });

  test('logout only clears local tokens', () async {
    await repository.logout();

    verify(() => tokenStorage.clearTokens()).called(1);
    verifyNever(() => dio.post(any(), data: any(named: 'data')));
  });
}
