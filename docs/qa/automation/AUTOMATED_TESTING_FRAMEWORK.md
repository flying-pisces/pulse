# Automated Testing Framework - Stock Signal AI Trading Alert

## Overview

This document outlines the comprehensive automated testing strategy for the Stock Signal AI Trading Alert Flutter application. The framework covers unit testing, widget testing, integration testing, and performance testing with specific recommendations for tools, patterns, and implementation.

## Table of Contents

1. [Testing Architecture](#testing-architecture)
2. [Unit Testing Framework](#unit-testing-framework)
3. [Widget Testing Framework](#widget-testing-framework)
4. [Integration Testing Framework](#integration-testing-framework)
5. [Performance Testing](#performance-testing)
6. [Test Data Management](#test-data-management)
7. [CI/CD Integration](#cicd-integration)
8. [Testing Tools & Dependencies](#testing-tools--dependencies)
9. [Code Coverage Requirements](#code-coverage-requirements)
10. [Implementation Timeline](#implementation-timeline)

## Testing Architecture

### Testing Pyramid Structure

```
                    E2E Tests (5%)
                 ├─ Critical user journeys
                 ├─ Cross-platform validation
                 └─ Production-like testing

              Integration Tests (20%)
           ├─ API integration testing
           ├─ State management integration
           ├─ Navigation flow testing
           └─ Provider interaction testing

         Widget Tests (35%)
      ├─ UI component testing
      ├─ User interaction testing
      ├─ Visual regression testing
      └─ Accessibility testing

   Unit Tests (40%)
├─ Business logic testing
├─ Model/Entity testing
├─ Provider logic testing
└─ Utility function testing
```

### Test Organization Structure

```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   ├── data/
│   │   ├── models/
│   │   └── repositories/
│   └── presentation/
│       └── providers/
├── widget/
│   ├── pages/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── signals/
│   │   ├── watchlist/
│   │   └── profile/
│   └── widgets/
│       └── common/
├── integration/
│   ├── auth_flow_test.dart
│   ├── navigation_test.dart
│   ├── signal_management_test.dart
│   └── subscription_flow_test.dart
├── performance/
│   ├── app_startup_test.dart
│   ├── navigation_performance_test.dart
│   └── memory_usage_test.dart
├── fixtures/
│   ├── auth_fixtures.dart
│   ├── signal_fixtures.dart
│   └── user_fixtures.dart
├── helpers/
│   ├── test_helpers.dart
│   ├── mock_providers.dart
│   └── widget_test_helpers.dart
└── mocks/
    ├── mock_auth_repository.dart
    ├── mock_signal_repository.dart
    └── mock_api_client.dart
```

## Unit Testing Framework

### Dependencies

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
  mocktail: ^1.0.3
  riverpod_test: ^2.0.0
  fake_async: ^1.3.1
```

### Unit Test Patterns

#### 1. Entity Testing

```dart
// test/unit/domain/entities/signal_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/signal.dart';
import 'package:pulse/domain/entities/user.dart';

void main() {
  group('Signal Entity', () {
    late Signal testSignal;

    setUp(() {
      testSignal = Signal(
        id: '1',
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        type: SignalType.stock,
        action: SignalAction.buy,
        currentPrice: 150.0,
        targetPrice: 160.0,
        stopLoss: 140.0,
        confidence: 0.85,
        reasoning: 'Strong earnings expected',
        createdAt: DateTime(2024, 1, 1),
        status: SignalStatus.active,
        tags: ['tech', 'earnings'],
        requiredTier: SubscriptionTier.premium,
      );
    });

    test('should calculate confidence label correctly', () {
      expect(testSignal.confidenceLabel, equals('High'));
      
      final mediumConfidenceSignal = testSignal.copyWith(confidence: 0.7);
      expect(mediumConfidenceSignal.confidenceLabel, equals('Medium'));
      
      final lowConfidenceSignal = testSignal.copyWith(confidence: 0.5);
      expect(lowConfidenceSignal.confidenceLabel, equals('Low'));
    });

    test('should identify active signal correctly', () {
      expect(testSignal.isActive, isTrue);
      
      final expiredSignal = testSignal.copyWith(status: SignalStatus.expired);
      expect(expiredSignal.isActive, isFalse);
    });

    test('should calculate profitability correctly', () {
      final profitableSignal = testSignal.copyWith(profitLossPercentage: 5.5);
      expect(profitableSignal.isProfitable, isTrue);
      
      final losingSignal = testSignal.copyWith(profitLossPercentage: -2.5);
      expect(losingSignal.isProfitable, isFalse);
    });

    test('should detect expired signals', () {
      final expiredSignal = testSignal.copyWith(
        expiresAt: DateTime(2023, 12, 1),
      );
      expect(expiredSignal.isExpired, isTrue);
      
      final futureSignal = testSignal.copyWith(
        expiresAt: DateTime(2025, 1, 1),
      );
      expect(futureSignal.isExpired, isFalse);
    });

    test('copyWith should update specified fields only', () {
      final updatedSignal = testSignal.copyWith(
        currentPrice: 155.0,
        confidence: 0.90,
      );
      
      expect(updatedSignal.currentPrice, equals(155.0));
      expect(updatedSignal.confidence, equals(0.90));
      expect(updatedSignal.symbol, equals(testSignal.symbol)); // unchanged
      expect(updatedSignal.targetPrice, equals(testSignal.targetPrice)); // unchanged
    });

    test('equals and hashCode should work correctly', () {
      final identicalSignal = Signal(
        id: '1',
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        type: SignalType.stock,
        action: SignalAction.buy,
        currentPrice: 150.0,
        targetPrice: 160.0,
        stopLoss: 140.0,
        confidence: 0.85,
        reasoning: 'Strong earnings expected',
        createdAt: DateTime(2024, 1, 1),
        status: SignalStatus.active,
        tags: ['tech', 'earnings'],
        requiredTier: SubscriptionTier.premium,
      );
      
      expect(testSignal, equals(identicalSignal));
      expect(testSignal.hashCode, equals(identicalSignal.hashCode));
    });
  });
}
```

#### 2. Provider Testing

```dart
// test/unit/presentation/providers/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/domain/entities/user.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthProvider', () {
    late MockAuthRepository mockAuthRepository;
    
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    testProvider(
      'initial state should be unauthenticated',
      provider: authProvider,
      expect: () => [
        const AuthState(isAuthenticated: false, isLoading: false),
      ],
    );

    testProvider(
      'signIn with valid credentials should authenticate user',
      provider: authProvider,
      act: (notifier) async {
        when(mockAuthRepository.signIn(any, any)).thenAnswer(
          (_) async => User(
            id: '1',
            email: 'test@example.com',
            firstName: 'Test',
            lastName: 'User',
            createdAt: DateTime.now(),
            isVerified: true,
            subscriptionTier: SubscriptionTier.free,
          ),
        );
        
        await notifier.signIn('test@example.com', 'password');
      },
      expect: () => [
        const AuthState(isAuthenticated: false, isLoading: false),
        const AuthState(isAuthenticated: false, isLoading: true),
        predicate<AuthState>((state) => 
          state.isAuthenticated && 
          !state.isLoading && 
          state.user?.email == 'test@example.com'
        ),
      ],
    );

    testProvider(
      'signIn with invalid credentials should show error',
      provider: authProvider,
      act: (notifier) async {
        when(mockAuthRepository.signIn(any, any))
            .thenThrow(Exception('Invalid credentials'));
        
        await notifier.signIn('invalid@example.com', 'wrong');
      },
      expect: () => [
        const AuthState(isAuthenticated: false, isLoading: false),
        const AuthState(isAuthenticated: false, isLoading: true),
        predicate<AuthState>((state) => 
          !state.isAuthenticated && 
          !state.isLoading && 
          state.error != null
        ),
      ],
    );

    testProvider(
      'signOut should clear authentication state',
      provider: authProvider,
      seed: () => AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: User(
          id: '1',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
          isVerified: true,
          subscriptionTier: SubscriptionTier.free,
        ),
      ),
      act: (notifier) async {
        when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
        await notifier.signOut();
      },
      expect: () => [
        predicate<AuthState>((state) => state.isAuthenticated),
        predicate<AuthState>((state) => state.isLoading),
        const AuthState(isAuthenticated: false, isLoading: false),
      ],
    );
  });
}
```

#### 3. Repository Testing

```dart
// test/unit/data/repositories/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pulse/data/repositories/auth_repository_impl.dart';
import 'package:pulse/data/datasources/auth_remote_datasource.dart';
import 'package:pulse/domain/entities/user.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource])
void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(mockRemoteDataSource);
    });

    group('signIn', () {
      test('should return User when sign in is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password';
        final userModel = UserModel(
          id: '1',
          email: email,
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
          isVerified: true,
          subscriptionTier: 'free',
        );

        when(mockRemoteDataSource.signIn(email, password))
            .thenAnswer((_) async => userModel);

        // Act
        final result = await repository.signIn(email, password);

        // Assert
        expect(result.email, equals(email));
        expect(result.firstName, equals('Test'));
        verify(mockRemoteDataSource.signIn(email, password));
      });

      test('should throw exception when sign in fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong';

        when(mockRemoteDataSource.signIn(email, password))
            .thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () async => await repository.signIn(email, password),
          throwsA(isA<Exception>()),
        );
        verify(mockRemoteDataSource.signIn(email, password));
      });
    });

    group('signUp', () {
      test('should return User when sign up is successful', () async {
        // Arrange
        final signUpRequest = SignUpRequest(
          email: 'new@example.com',
          password: 'password',
          firstName: 'New',
          lastName: 'User',
        );
        final userModel = UserModel(
          id: '2',
          email: signUpRequest.email,
          firstName: signUpRequest.firstName,
          lastName: signUpRequest.lastName,
          createdAt: DateTime.now(),
          isVerified: false,
          subscriptionTier: 'free',
        );

        when(mockRemoteDataSource.signUp(signUpRequest))
            .thenAnswer((_) async => userModel);

        // Act
        final result = await repository.signUp(signUpRequest);

        // Assert
        expect(result.email, equals(signUpRequest.email));
        expect(result.isVerified, isFalse);
        verify(mockRemoteDataSource.signUp(signUpRequest));
      });
    });
  });
}
```

## Widget Testing Framework

### Widget Test Patterns

#### 1. Page Widget Testing

```dart
// test/widget/pages/auth/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:pulse/presentation/pages/auth/login_page.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';

import '../../../helpers/widget_test_helpers.dart';
import '../../../mocks/mock_providers.dart';

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
    });

    testWidgets('should display login form elements', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to access your trading signals'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('should validate email field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      // Find email field
      final emailField = find.byKey(const Key('email_field'));
      await tester.enterText(emailField, 'invalid-email');
      
      // Try to submit form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, '123'); // Too short

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should call signIn when form is valid and submitted', (tester) async {
      when(mockAuthNotifier.state).thenReturn(
        const AuthState(isAuthenticated: false, isLoading: false),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      verify(mockAuthNotifier.signIn('test@example.com', 'password123')).called(1);
    });

    testWidgets('should show loading state during authentication', (tester) async {
      when(mockAuthNotifier.state).thenReturn(
        const AuthState(isAuthenticated: false, isLoading: true),
      );

      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      final passwordField = find.byKey(const Key('password_field'));
      final toggleButton = find.byKey(const Key('password_toggle'));
      
      // Initially password should be obscured
      expect((tester.widget(passwordField) as TextFormField).obscureText, isTrue);
      
      // Tap toggle button
      await tester.tap(toggleButton);
      await tester.pump();
      
      // Password should now be visible
      expect((tester.widget(passwordField) as TextFormField).obscureText, isFalse);
    });

    testWidgets('should navigate to registration page', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => mockAuthNotifier),
          ],
        ),
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify navigation occurred (would need router mock)
      // This test would be more complex with actual navigation testing
    });
  });
}
```

#### 2. Common Widget Testing

```dart
// test/widget/widgets/common/signal_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/signal.dart';
import 'package:pulse/presentation/widgets/common/signal_card.dart';

import '../../../fixtures/signal_fixtures.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('SignalCard Widget Tests', () {
    late Signal testSignal;

    setUp(() {
      testSignal = SignalFixtures.buySignal;
    });

    testWidgets('should display signal information correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: testSignal),
        ),
      );

      expect(find.text(testSignal.symbol), findsOneWidget);
      expect(find.text(testSignal.companyName), findsOneWidget);
      expect(find.text(testSignal.action.displayName), findsOneWidget);
      expect(find.text('\$${testSignal.currentPrice}'), findsOneWidget);
      expect(find.text('\$${testSignal.targetPrice}'), findsOneWidget);
    });

    testWidgets('should display buy signal with correct color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: testSignal),
        ),
      );

      final actionChip = tester.widget<Chip>(find.byKey(const Key('action_chip')));
      expect(actionChip.backgroundColor, equals(Colors.green));
    });

    testWidgets('should display sell signal with correct color', (tester) async {
      final sellSignal = testSignal.copyWith(action: SignalAction.sell);
      
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: sellSignal),
        ),
      );

      final actionChip = tester.widget<Chip>(find.byKey(const Key('action_chip')));
      expect(actionChip.backgroundColor, equals(Colors.red));
    });

    testWidgets('should show confidence indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: testSignal),
        ),
      );

      expect(find.text(testSignal.confidenceLabel), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(
            signal: testSignal,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SignalCard));
      expect(tapped, isTrue);
    });

    testWidgets('should display profit/loss indicator when available', (tester) async {
      final profitableSignal = testSignal.copyWith(profitLossPercentage: 5.5);
      
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: profitableSignal),
        ),
      );

      expect(find.text('+5.5%'), findsOneWidget);
      
      final profitIndicator = tester.widget<Text>(find.text('+5.5%'));
      expect(profitIndicator.style?.color, equals(Colors.green));
    });

    testWidgets('should show expired state visually', (tester) async {
      final expiredSignal = testSignal.copyWith(
        status: SignalStatus.expired,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: SignalCard(signal: expiredSignal),
        ),
      );

      expect(find.text('EXPIRED'), findsOneWidget);
      
      // Check that card has muted appearance
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.grey[100]));
    });
  });
}
```

#### 3. Golden Tests for Visual Regression

```dart
// test/widget/golden/login_page_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:pulse/presentation/pages/auth/login_page.dart';

import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_providers.dart';

void main() {
  group('LoginPage Golden Tests', () {
    testGoldens('login page renders correctly', (tester) async {
      await loadAppFonts();
      
      final widget = createTestWidget(
        child: const LoginPage(),
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier()),
        ],
      );

      await tester.pumpWidgetBuilder(
        widget,
        surfaceSize: const Size(375, 812), // iPhone X size
      );

      await screenMatchesGolden(tester, 'login_page');
    });

    testGoldens('login page with loading state', (tester) async {
      await loadAppFonts();
      
      final mockAuth = MockAuthNotifier();
      when(mockAuth.state).thenReturn(
        const AuthState(isAuthenticated: false, isLoading: true),
      );

      final widget = createTestWidget(
        child: const LoginPage(),
        overrides: [
          authProvider.overrideWith(() => mockAuth),
        ],
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'login_page_loading');
    });

    testGoldens('login page with error state', (tester) async {
      await loadAppFonts();
      
      final mockAuth = MockAuthNotifier();
      when(mockAuth.state).thenReturn(
        const AuthState(
          isAuthenticated: false, 
          isLoading: false,
          error: 'Invalid credentials',
        ),
      );

      final widget = createTestWidget(
        child: const LoginPage(),
        overrides: [
          authProvider.overrideWith(() => mockAuth),
        ],
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'login_page_error');
    });

    testGoldens('login page dark theme', (tester) async {
      await loadAppFonts();
      
      final widget = createTestWidget(
        child: const LoginPage(),
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier()),
        ],
        themeMode: ThemeMode.dark,
      );

      await tester.pumpWidgetBuilder(widget);
      await screenMatchesGolden(tester, 'login_page_dark');
    });
  });
}
```

## Integration Testing Framework

### Integration Test Structure

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Stock Signal App Integration Tests', () {
    testWidgets('complete authentication flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test app launch and splash screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should navigate to onboarding or login
      expect(find.text('Welcome Back'), findsOneWidget);
      
      // Test login flow
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'demo@stocksignal.ai',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password',
      );
      
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('navigation between main tabs', (tester) async {
      // Assume user is already authenticated
      await _authenticateUser(tester);
      
      // Test navigation to each tab
      await tester.tap(find.text('Signals'));
      await tester.pumpAndSettle();
      expect(find.text('Trading Signals'), findsOneWidget);
      
      await tester.tap(find.text('Watchlist'));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('subscription upgrade flow', (tester) async {
      await _authenticateUser(tester);
      
      // Navigate to premium feature that requires upgrade
      await tester.tap(find.text('Signals'));
      await tester.pumpAndSettle();
      
      // Try to access premium signal (assuming this triggers upgrade flow)
      await tester.tap(find.byKey(const Key('premium_signal')));
      await tester.pumpAndSettle();
      
      // Should show subscription page
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(find.text('Premium Plan'), findsOneWidget);
      
      // Test subscription selection
      await tester.tap(find.text('Choose Premium'));
      await tester.pumpAndSettle();
      
      // Should show payment screen (mock)
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('signal detail view and navigation', (tester) async {
      await _authenticateUser(tester);
      
      await tester.tap(find.text('Signals'));
      await tester.pumpAndSettle();
      
      // Tap on first signal
      await tester.tap(find.byType(SignalCard).first);
      await tester.pumpAndSettle();
      
      // Should show signal detail
      expect(find.text('Signal Details'), findsOneWidget);
      expect(find.byType(Chart), findsOneWidget); // Assuming chart widget exists
      
      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Should return to signals list
      expect(find.text('Trading Signals'), findsOneWidget);
    });
  });
}

Future<void> _authenticateUser(WidgetTester tester) async {
  // Helper function to authenticate user for tests
  await tester.enterText(
    find.byKey(const Key('email_field')), 
    'demo@stocksignal.ai',
  );
  await tester.enterText(
    find.byKey(const Key('password_field')), 
    'password',
  );
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
```

## Performance Testing

### Performance Test Implementation

```dart
// test/performance/app_startup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pulse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('app startup performance', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      print('App startup time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('navigation performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Authenticate user first
      await _authenticateUser(tester);
      
      // Test navigation performance
      final stopwatch = Stopwatch();
      
      for (final tab in ['Signals', 'Watchlist', 'Profile', 'Dashboard']) {
        stopwatch.reset();
        stopwatch.start();
        
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Each navigation should be under 300ms
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        print('Navigation to $tab: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('memory usage during extended use', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _authenticateUser(tester);
      
      // Perform various operations to test memory usage
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Signals'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Watchlist'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Dashboard'));
        await tester.pumpAndSettle();
      }
      
      // Memory usage tests would require additional platform-specific code
      // This is a placeholder for actual memory monitoring
    });
  });
}
```

## Test Data Management

### Test Fixtures

```dart
// test/fixtures/signal_fixtures.dart
import 'package:pulse/domain/entities/signal.dart';
import 'package:pulse/domain/entities/user.dart';

class SignalFixtures {
  static Signal get buySignal => Signal(
    id: '1',
    symbol: 'AAPL',
    companyName: 'Apple Inc.',
    type: SignalType.stock,
    action: SignalAction.buy,
    currentPrice: 150.00,
    targetPrice: 165.00,
    stopLoss: 140.00,
    confidence: 0.85,
    reasoning: 'Strong earnings report expected, bullish technical indicators',
    createdAt: DateTime(2024, 1, 15, 10, 30),
    status: SignalStatus.active,
    tags: ['tech', 'earnings', 'momentum'],
    requiredTier: SubscriptionTier.premium,
  );

  static Signal get sellSignal => Signal(
    id: '2',
    symbol: 'TSLA',
    companyName: 'Tesla Inc.',
    type: SignalType.stock,
    action: SignalAction.sell,
    currentPrice: 220.00,
    targetPrice: 200.00,
    stopLoss: 235.00,
    confidence: 0.70,
    reasoning: 'Overvalued at current levels, potential pullback expected',
    createdAt: DateTime(2024, 1, 15, 14, 45),
    status: SignalStatus.active,
    tags: ['automotive', 'overvalued'],
    requiredTier: SubscriptionTier.free,
  );

  static Signal get cryptoSignal => Signal(
    id: '3',
    symbol: 'BTC',
    companyName: 'Bitcoin',
    type: SignalType.crypto,
    action: SignalAction.buy,
    currentPrice: 45000.00,
    targetPrice: 50000.00,
    stopLoss: 42000.00,
    confidence: 0.75,
    reasoning: 'Breaking resistance level, institutional adoption increasing',
    createdAt: DateTime(2024, 1, 15, 16, 20),
    status: SignalStatus.active,
    tags: ['cryptocurrency', 'breakout'],
    requiredTier: SubscriptionTier.premium,
  );

  static Signal get expiredSignal => Signal(
    id: '4',
    symbol: 'NVDA',
    companyName: 'NVIDIA Corporation',
    type: SignalType.stock,
    action: SignalAction.buy,
    currentPrice: 800.00,
    targetPrice: 850.00,
    stopLoss: 750.00,
    confidence: 0.80,
    reasoning: 'AI boom driving demand for chips',
    createdAt: DateTime(2024, 1, 10, 9, 15),
    expiresAt: DateTime(2024, 1, 12, 16, 0),
    status: SignalStatus.expired,
    tags: ['AI', 'semiconductors'],
    requiredTier: SubscriptionTier.premium,
    profitLossPercentage: -2.5,
  );

  static List<Signal> get allSignals => [
    buySignal,
    sellSignal,
    cryptoSignal,
    expiredSignal,
  ];

  static List<Signal> get activeSignals => allSignals
      .where((signal) => signal.status == SignalStatus.active)
      .toList();

  static List<Signal> get premiumSignals => allSignals
      .where((signal) => signal.requiredTier == SubscriptionTier.premium)
      .toList();
}
```

### Mock Data Providers

```dart
// test/helpers/mock_providers.dart
import 'package:mockito/mockito.dart';
import 'package:pulse/presentation/providers/auth_provider.dart';
import 'package:pulse/presentation/providers/signals_provider.dart';

class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  AuthState get state => const AuthState(
    isAuthenticated: false,
    isLoading: false,
  );
}

class MockSignalsNotifier extends Mock implements SignalsNotifier {
  @override
  SignalsState get state => SignalsState(
    signals: SignalFixtures.allSignals,
    isLoading: false,
    filter: SignalFilter(),
  );
}
```

## CI/CD Integration

### GitHub Actions Configuration

```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
    - name: Analyze code
      run: flutter analyze
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Run integration tests
      run: flutter test integration_test/
      
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        
  widget_test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Run widget tests
      run: flutter test test/widget/
      
    - name: Run golden tests
      run: flutter test --update-goldens test/widget/golden/
      
  performance_test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.8.1'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Run performance tests
      run: flutter test test/performance/
      
    - name: Upload performance results
      uses: actions/upload-artifact@v3
      with:
        name: performance-results
        path: test/performance/results/
```

## Code Coverage Requirements

### Coverage Targets

- **Overall Coverage:** 85%
- **Unit Tests:** 90%
- **Widget Tests:** 80%
- **Integration Tests:** 70% (focused on critical paths)

### Coverage Configuration

```yaml
# coverage/lcov.info configuration
test:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/main.dart"
    - "lib/generated/**"
    - "test/**"
```

### Coverage Script

```bash
#!/bin/bash
# scripts/coverage.sh

echo "Running tests with coverage..."
flutter test --coverage

echo "Filtering coverage data..."
lcov --remove coverage/lcov.info \
  'lib/generated/**' \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/main.dart' \
  -o coverage/lcov_filtered.info

echo "Generating HTML coverage report..."
genhtml coverage/lcov_filtered.info -o coverage/html

echo "Coverage report generated in coverage/html/index.html"

# Check coverage threshold
COVERAGE=$(lcov --summary coverage/lcov_filtered.info | grep "lines" | grep -o "[0-9.]*%" | head -1 | sed 's/%//')
THRESHOLD=85

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "ERROR: Coverage $COVERAGE% is below threshold $THRESHOLD%"
  exit 1
else
  echo "SUCCESS: Coverage $COVERAGE% meets threshold $THRESHOLD%"
fi
```

## Implementation Timeline

### Phase 1: Foundation (Week 1-2)
- Set up testing infrastructure and dependencies
- Create test helpers and utilities
- Implement basic unit tests for entities and providers
- Set up CI/CD pipeline

### Phase 2: Core Testing (Week 3-4)
- Implement comprehensive unit tests
- Create widget tests for all major components
- Set up golden tests for visual regression
- Implement mock data and fixtures

### Phase 3: Integration Testing (Week 5-6)
- Develop integration tests for critical user journeys
- Implement performance testing framework
- Create API integration test mocks
- Set up end-to-end testing scenarios

### Phase 4: Optimization (Week 7-8)
- Optimize test execution speed
- Implement parallel test execution
- Fine-tune coverage requirements
- Create comprehensive test documentation

### Phase 5: Maintenance (Ongoing)
- Regular test maintenance and updates
- New feature test coverage
- Performance regression testing
- Test framework updates and improvements

---

This automated testing framework provides comprehensive coverage for the Stock Signal AI Trading Alert app, ensuring high quality and reliability through systematic testing at all levels of the application architecture.