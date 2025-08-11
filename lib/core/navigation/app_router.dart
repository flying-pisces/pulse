import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/subscription/subscription_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/signals/signals_page.dart';
import '../../presentation/pages/watchlist/watchlist_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.uri.toString();
      
      // Handle authentication redirects
      if (!isAuthenticated && _requiresAuth(location)) {
        return '/login';
      }
      
      // Redirect authenticated users away from auth pages
      if (isAuthenticated && _isAuthPage(location)) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Subscription
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      
      // Main App Routes
      ShellRoute(
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardHomePage(),
          ),
          GoRoute(
            path: '/signals',
            name: 'signals',
            builder: (context, state) => const SignalsPage(),
            routes: [
              GoRoute(
                path: '/detail/:id',
                name: 'signal-detail',
                builder: (context, state) {
                  final signalId = state.pathParameters['id']!;
                  return SignalDetailPage(signalId: signalId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/watchlist',
            name: 'watchlist',
            builder: (context, state) => const WatchlistPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

bool _requiresAuth(String location) {
  final authRequiredPaths = [
    '/dashboard',
    '/signals',
    '/watchlist',
    '/profile',
    '/subscription',
  ];
  
  return authRequiredPaths.any((path) => location.startsWith(path));
}

bool _isAuthPage(String location) {
  final authPaths = [
    '/login',
    '/register',
    '/forgot-password',
    '/onboarding',
  ];
  
  return authPaths.contains(location);
}

// Placeholder widgets that will be implemented
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Home'),
    );
  }
}

class SignalDetailPage extends StatelessWidget {
  final String signalId;
  
  const SignalDetailPage({super.key, required this.signalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signal Detail')),
      body: Center(
        child: Text('Signal ID: $signalId'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}