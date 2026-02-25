import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zimbite/features/auth/data/models/auth_models.dart';
import 'package:zimbite/features/auth/data/repositories/auth_repository.dart';
import 'package:zimbite/features/auth/presentation/screens/register_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Finder _fieldByKey(String key) {
  return find.byKey(Key(key));
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RegisterRequest(
        firstName: 'Fallback',
        lastName: 'User',
        email: 'fallback@example.com',
        phoneNumber: '+263771234567',
        password: 'fallback123',
      ),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    AuthRepository authRepository,
  ) async {
    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: authRepository,
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
  }

  testWidgets('shows required validation errors on empty submit', (
    tester,
  ) async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.register(any())).thenAnswer((_) async {});

    await pumpScreen(tester, authRepository);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('First name is required'), findsOneWidget);
    expect(find.text('Last name is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authRepository.register(any()));
  });

  testWidgets('shows password length validation error', (tester) async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.register(any())).thenAnswer((_) async {});

    await pumpScreen(tester, authRepository);

    await tester.enterText(_fieldByKey('register.firstName'), 'Jane');
    await tester.enterText(_fieldByKey('register.lastName'), 'Doe');
    await tester.enterText(_fieldByKey('register.phoneNumber'), '+263771234567');
    await tester.enterText(_fieldByKey('register.email'), 'jane@example.com');
    await tester.enterText(_fieldByKey('register.password'), 'short');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    verifyNever(() => authRepository.register(any()));
  });

  testWidgets('maps form fields to backend register payload', (tester) async {
    final authRepository = MockAuthRepository();
    when(() => authRepository.register(any())).thenThrow(Exception('network'));

    await pumpScreen(tester, authRepository);

    await tester.enterText(_fieldByKey('register.firstName'), 'Jane');
    await tester.enterText(_fieldByKey('register.lastName'), 'Doe');
    await tester.enterText(_fieldByKey('register.phoneNumber'), '+263771234567');
    await tester.enterText(_fieldByKey('register.email'), 'jane@example.com');
    await tester.enterText(_fieldByKey('register.password'), 'secret123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => authRepository.register(captureAny())).captured.single
            as RegisterRequest;
    expect(captured.firstName, 'Jane');
    expect(captured.lastName, 'Doe');
    expect(captured.phoneNumber, '+263771234567');
    expect(captured.email, 'jane@example.com');
    expect(captured.password, 'secret123');
  });
}
