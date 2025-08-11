import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../data/datasources/auth_service.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState(isAuthenticated: false, isLoading: false));

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user for demo
      if (email == 'demo@stocksignal.ai' && password == 'password') {
        final user = User(
          id: '1',
          email: email,
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
          isVerified: true,
          subscriptionTier: SubscriptionTier.premium,
          subscriptionExpiresAt: DateTime.now().add(const Duration(days: 30)),
          authProvider: AuthProvider.email,
        );
        
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signUp(String email, String password, String firstName, String lastName) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        isVerified: false,
        subscriptionTier: SubscriptionTier.free,
        authProvider: AuthProvider.email,
      );
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Google OAuth Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // Create user from OAuth result
      final names = result.name?.split(' ') ?? ['', ''];
      final firstName = names.isNotEmpty ? names[0] : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final user = User(
        id: result.providerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: result.email ?? '',
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: result.photoUrl,
        createdAt: DateTime.now(),
        isVerified: true, // OAuth providers are considered verified
        subscriptionTier: SubscriptionTier.free,
        authProvider: AuthProvider.google,
        providerId: result.providerId,
        providerData: result.additionalUserInfo,
      );
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Apple OAuth Sign In
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signInWithApple();
      if (result == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // Create user from OAuth result
      final names = result.name?.split(' ') ?? ['', ''];
      final firstName = names.isNotEmpty ? names[0] : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final user = User(
        id: result.providerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: result.email ?? '',
        firstName: firstName.isNotEmpty ? firstName : 'Apple',
        lastName: lastName.isNotEmpty ? lastName : 'User',
        createdAt: DateTime.now(),
        isVerified: true, // OAuth providers are considered verified
        subscriptionTier: SubscriptionTier.free,
        authProvider: AuthProvider.apple,
        providerId: result.providerId,
        providerData: result.additionalUserInfo,
      );
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Sign out from OAuth providers
      await _authService.signOut();
      
      // Clear local state
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check if user is already signed in (useful for app initialization)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn) {
        final currentUser = await _authService.getCurrentUser();
        if (currentUser != null) {
          final names = currentUser.name?.split(' ') ?? ['', ''];
          final firstName = names.isNotEmpty ? names[0] : '';
          final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

          final user = User(
            id: currentUser.providerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            email: currentUser.email ?? '',
            firstName: firstName,
            lastName: lastName,
            profileImageUrl: currentUser.photoUrl,
            createdAt: DateTime.now(),
            isVerified: true,
            subscriptionTier: SubscriptionTier.free,
            authProvider: AuthProvider.google, // Assuming Google for existing users
            providerId: currentUser.providerId,
            providerData: currentUser.additionalUserInfo,
          );
          
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl();
});

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});