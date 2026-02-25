import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zimbite/core/storage/token_storage.dart';
import 'package:zimbite/features/auth/data/models/auth_models.dart';
import 'package:zimbite/features/auth/data/repositories/auth_repository.dart';
import 'package:zimbite/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();

    when(() => tokenStorage.hasTokens).thenAnswer((_) async => false);
    when(() => authRepository.logout()).thenAnswer((_) async {});
  });

  blocTest<AuthBloc, AuthState>(
    'emits OTP required with principal on successful login',
    build: () {
      when(
        () => authRepository.login(
          principal: 'user@example.com',
          password: 'secret123',
        ),
      ).thenAnswer(
        (_) async => LoginChallengeResponse(
          challengeId: 'challenge-1',
          principal: 'user@example.com',
          expiresAt: DateTime.parse('2026-02-25T12:00:00Z'),
          attemptsRemaining: 3,
          status: 'OTP_REQUIRED',
        ),
      );
      return AuthBloc(authRepository, tokenStorage);
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(
        principal: 'user@example.com',
        password: 'secret123',
      ),
    ),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthOtpRequired>()
          .having((s) => s.challengeId, 'challengeId', 'challenge-1')
          .having((s) => s.principal, 'principal', 'user@example.com'),
    ],
    verify: (_) {
      verify(
        () => authRepository.login(
          principal: 'user@example.com',
          password: 'secret123',
        ),
      ).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'uses principal when submitting OTP',
    build: () {
      when(
        () => authRepository.verifyOtp(
          principal: 'user@example.com',
          otp: '123456',
        ),
      ).thenAnswer(
        (_) async => const AuthTokensResponse(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresIn: 900,
        ),
      );
      return AuthBloc(authRepository, tokenStorage);
    },
    act: (bloc) => bloc.add(
      const AuthOtpSubmitted(principal: 'user@example.com', otp: '123456'),
    ),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthAuthenticated>(),
    ],
    verify: (_) {
      verify(
        () => authRepository.verifyOtp(
          principal: 'user@example.com',
          otp: '123456',
        ),
      ).called(1);
    },
  );
}
