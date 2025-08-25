import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import '../models/market_data_models.dart';
import '../../domain/entities/user.dart';

/// Repository for user operations using PocketBase
class PocketBaseUserRepository {
  final PocketBaseService _pocketBase;

  PocketBaseUserRepository(this._pocketBase);

  /// Sign in with email and password
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final authData = await _pocketBase.signInWithEmailPassword(email, password);
      return _mapRecordToUser(authData.record);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Register new user
  Future<User> registerWithEmailPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? profileImageUrl,
  }) async {
    try {
      final record = await _pocketBase.registerWithEmailPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
      );
      
      // After registration, sign in the user
      await _pocketBase.signInWithEmailPassword(email, password);
      
      return _mapRecordToUser(record);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Sign in with OAuth (Google/Apple)
  Future<User> signInWithOAuth(String provider, {
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    try {
      final createData = <String, dynamic>{};
      
      if (firstName != null) createData['firstName'] = firstName;
      if (lastName != null) createData['lastName'] = lastName;
      if (profileImageUrl != null) createData['profileImageUrl'] = profileImageUrl;
      createData['subscriptionTier'] = 'free';
      createData['authProvider'] = provider;

      final authData = await _pocketBase.signInWithOAuth(provider, createData: createData);
      return _mapRecordToUser(authData.record);
    } catch (e) {
      throw Exception('Failed to sign in with OAuth: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _pocketBase.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _pocketBase.sendPasswordReset(email);
    } catch (e) {
      throw Exception('Failed to send password reset: $e');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _pocketBase.currentUser;
      if (currentUser == null) return null;
      
      // Get fresh user data from server
      final userRecord = await _pocketBase.getUserProfile(currentUser.id);
      if (userRecord == null) return null;
      
      return _mapRecordToUser(userRecord);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    bool? isVerified,
  }) async {
    try {
      final currentUser = _pocketBase.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final data = <String, dynamic>{};
      
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
      if (isVerified != null) data['isVerified'] = isVerified;

      final updatedRecord = await _pocketBase.updateUserProfile(currentUser.id, data);
      return _mapRecordToUser(updatedRecord);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update subscription
  Future<User> updateSubscription(SubscriptionTier tier, DateTime? expiresAt) async {
    try {
      final currentUser = _pocketBase.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final updatedRecord = await _pocketBase.updateSubscription(
        currentUser.id,
        tier.name,
        expiresAt,
      );
      
      return _mapRecordToUser(updatedRecord);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  /// Check authentication status
  bool get isAuthenticated => _pocketBase.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => _pocketBase.currentUserId;

  /// Check if user has valid subscription
  Future<bool> hasValidSubscription(SubscriptionTier requiredTier) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Check if subscription is not expired
      if (user.subscriptionExpiresAt != null && 
          user.subscriptionExpiresAt!.isBefore(DateTime.now())) {
        return false;
      }

      // Check tier hierarchy: free < basic < premium < pro
      final tierValues = {
        SubscriptionTier.free: 0,
        SubscriptionTier.basic: 1,
        SubscriptionTier.premium: 2,
        SubscriptionTier.pro: 3,
      };

      final userTierValue = tierValues[user.subscriptionTier] ?? 0;
      final requiredTierValue = tierValues[requiredTier] ?? 0;

      return userTierValue >= requiredTierValue;
    } catch (e) {
      return false;
    }
  }

  /// Get subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return SubscriptionStatus.none;

      if (user.subscriptionExpiresAt != null && 
          user.subscriptionExpiresAt!.isBefore(DateTime.now())) {
        return SubscriptionStatus.expired;
      }

      switch (user.subscriptionTier) {
        case SubscriptionTier.free:
          return SubscriptionStatus.free;
        case SubscriptionTier.basic:
          return SubscriptionStatus.active;
        case SubscriptionTier.premium:
          return SubscriptionStatus.active;
        case SubscriptionTier.pro:
          return SubscriptionStatus.active;
      }
    } catch (e) {
      return SubscriptionStatus.none;
    }
  }

  /// Upload profile image
  Future<User> uploadProfileImage(String imagePath) async {
    try {
      final currentUser = _pocketBase.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final updatedRecord = await _pocketBase.uploadFile(
        'users',
        currentUser.id,
        'profileImageUrl',
        imagePath,
      );

      return _mapRecordToUser(updatedRecord);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final currentUser = _pocketBase.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Note: This would require admin permissions in PocketBase
      // For now, we'll just sign out and let admin handle deletion
      await signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Map PocketBase record to User entity
  User _mapRecordToUser(RecordModel record) {
    return User(
      id: record.id,
      email: record.data['email'] ?? '',
      firstName: record.data['firstName'] ?? '',
      lastName: record.data['lastName'] ?? '',
      profileImageUrl: record.data['profileImageUrl'],
      createdAt: DateTime.parse(record.created),
      isVerified: record.data['isVerified'] ?? false,
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == record.data['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiresAt: record.data['subscriptionExpiresAt'] != null
          ? DateTime.parse(record.data['subscriptionExpiresAt'])
          : null,
      authProvider: AuthProvider.values.firstWhere(
        (e) => e.name == record.data['authProvider'],
        orElse: () => AuthProvider.email,
      ),
      providerId: record.data['providerId'],
      providerData: record.data['providerData'],
    );
  }
}

/// Subscription status enum
enum SubscriptionStatus {
  none,
  free,
  active,
  expired,
}

/// Provider for PocketBase user repository
final pocketBaseUserRepositoryProvider = Provider<PocketBaseUserRepository>((ref) {
  final pocketBase = ref.watch(pocketBaseServiceProvider);
  return PocketBaseUserRepository(pocketBase);
});

/// Provider for current user
final currentUserProfileProvider = FutureProvider<User?>((ref) async {
  final repository = ref.watch(pocketBaseUserRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final repository = ref.watch(pocketBaseUserRepositoryProvider);
  return repository.isAuthenticated;
});

/// Provider for subscription status
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((ref) async {
  final repository = ref.watch(pocketBaseUserRepositoryProvider);
  return repository.getSubscriptionStatus();
});

/// Provider for checking subscription access
final hasSubscriptionAccessProvider = FutureProvider.family<bool, SubscriptionTier>((ref, requiredTier) async {
  final repository = ref.watch(pocketBaseUserRepositoryProvider);
  return repository.hasValidSubscription(requiredTier);
});