import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/constants/env_config.dart';
import '../models/market_data_models.dart';

/// PocketBase service for backend communication
class PocketBaseService {
  late final PocketBase _pb;
  final Logger _logger = Logger();
  
  PocketBaseService() {
    _pb = PocketBase(EnvConfig.pocketbaseUrl);
    
    // Enable auto cancellation for pending requests on route change
    _pb.cancelAllRequests();
  }

  /// Get PocketBase instance
  PocketBase get pb => _pb;

  /// Check if user is authenticated
  bool get isAuthenticated => _pb.authStore.isValid;

  /// Get current user
  RecordModel? get currentUser => _pb.authStore.model;

  /// Get current user ID
  String? get currentUserId => _pb.authStore.model?.id;

  /// Authentication Methods
  
  /// Sign in with email and password
  Future<RecordAuth> signInWithEmailPassword(String email, String password) async {
    try {
      final authData = await _pb.collection('users').authWithPassword(email, password);
      _logger.i('User signed in successfully: ${authData.record.id}');
      return authData;
    } catch (e) {
      _logger.e('Sign in failed: $e');
      rethrow;
    }
  }

  /// Register new user with email and password
  Future<RecordModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? profileImageUrl,
    String subscriptionTier = 'free',
    String authProvider = 'email',
  }) async {
    try {
      final userData = {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'firstName': firstName,
        'lastName': lastName,
        'profileImageUrl': profileImageUrl,
        'isVerified': false,
        'subscriptionTier': subscriptionTier,
        'authProvider': authProvider,
      };

      final record = await _pb.collection('users').create(body: userData);
      _logger.i('User registered successfully: ${record.id}');
      return record;
    } catch (e) {
      _logger.e('Registration failed: $e');
      rethrow;
    }
  }

  /// Sign in with OAuth (Google/Apple)
  Future<RecordAuth> signInWithOAuth(String provider, {
    Map<String, dynamic>? createData,
  }) async {
    try {
      final authData = await _pb.collection('users').authWithOAuth2(
        provider,
        createData: createData,
      );
      _logger.i('OAuth sign in successful: ${authData.record.id}');
      return authData;
    } catch (e) {
      _logger.e('OAuth sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _pb.authStore.clear();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _pb.collection('users').requestPasswordReset(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e) {
      _logger.e('Password reset failed: $e');
      rethrow;
    }
  }

  /// User Management
  
  /// Get user profile
  Future<RecordModel?> getUserProfile(String userId) async {
    try {
      final user = await _pb.collection('users').getOne(userId);
      return user;
    } catch (e) {
      _logger.e('Failed to get user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<RecordModel> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final updatedUser = await _pb.collection('users').update(userId, body: data);
      _logger.i('User profile updated: $userId');
      return updatedUser;
    } catch (e) {
      _logger.e('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Update subscription
  Future<RecordModel> updateSubscription(String userId, String tier, DateTime? expiresAt) async {
    try {
      final data = {
        'subscriptionTier': tier,
        'subscriptionExpiresAt': expiresAt?.toIso8601String(),
      };
      
      final updatedUser = await _pb.collection('users').update(userId, body: data);
      _logger.i('Subscription updated for user: $userId to tier: $tier');
      return updatedUser;
    } catch (e) {
      _logger.e('Failed to update subscription: $e');
      rethrow;
    }
  }

  /// Signals Management
  
  /// Get signals list with pagination and filtering
  Future<ResultList<RecordModel>> getSignals({
    int page = 1,
    int perPage = 20,
    String? filter,
    String sort = '-created',
  }) async {
    try {
      final signals = await _pb.collection('signals').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      return signals;
    } catch (e) {
      _logger.e('Failed to get signals: $e');
      rethrow;
    }
  }

  /// Get single signal
  Future<RecordModel?> getSignal(String signalId) async {
    try {
      final signal = await _pb.collection('signals').getOne(signalId);
      return signal;
    } catch (e) {
      _logger.e('Failed to get signal: $e');
      return null;
    }
  }

  /// Subscribe to signals real-time updates
  Stream<RecordModel> subscribeToSignals({String? filter}) {
    return _pb.collection('signals').subscribe(
      filter: filter,
    );
  }

  /// Create signal (admin only)
  Future<RecordModel> createSignal(Map<String, dynamic> signalData) async {
    try {
      final signal = await _pb.collection('signals').create(body: signalData);
      _logger.i('Signal created: ${signal.id}');
      return signal;
    } catch (e) {
      _logger.e('Failed to create signal: $e');
      rethrow;
    }
  }

  /// Update signal (admin only)
  Future<RecordModel> updateSignal(String signalId, Map<String, dynamic> data) async {
    try {
      final signal = await _pb.collection('signals').update(signalId, body: data);
      _logger.i('Signal updated: $signalId');
      return signal;
    } catch (e) {
      _logger.e('Failed to update signal: $e');
      rethrow;
    }
  }

  /// Watchlist Management
  
  /// Get user's watchlist
  Future<ResultList<RecordModel>> getWatchlist({
    int page = 1,
    int perPage = 50,
    String sort = '-addedAt',
  }) async {
    try {
      if (!isAuthenticated) throw Exception('User not authenticated');
      
      final filter = 'userId = "${currentUserId}"';
      final watchlist = await _pb.collection('watchlistItems').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      return watchlist;
    } catch (e) {
      _logger.e('Failed to get watchlist: $e');
      rethrow;
    }
  }

  /// Add item to watchlist
  Future<RecordModel> addToWatchlist({
    required String symbol,
    required String companyName,
    required String type,
    required double currentPrice,
    required double priceChange,
    required double priceChangePercent,
    bool isPriceAlertEnabled = false,
    double? priceAlertTarget,
    String? notes,
  }) async {
    try {
      if (!isAuthenticated) throw Exception('User not authenticated');
      
      final data = {
        'userId': currentUserId,
        'symbol': symbol,
        'companyName': companyName,
        'type': type,
        'currentPrice': currentPrice,
        'priceChange': priceChange,
        'priceChangePercent': priceChangePercent,
        'addedAt': DateTime.now().toIso8601String(),
        'isPriceAlertEnabled': isPriceAlertEnabled,
        'priceAlertTarget': priceAlertTarget,
        'notes': notes,
      };

      final item = await _pb.collection('watchlistItems').create(body: data);
      _logger.i('Added to watchlist: $symbol');
      return item;
    } catch (e) {
      _logger.e('Failed to add to watchlist: $e');
      rethrow;
    }
  }

  /// Remove item from watchlist
  Future<void> removeFromWatchlist(String itemId) async {
    try {
      await _pb.collection('watchlistItems').delete(itemId);
      _logger.i('Removed from watchlist: $itemId');
    } catch (e) {
      _logger.e('Failed to remove from watchlist: $e');
      rethrow;
    }
  }

  /// Update watchlist item
  Future<RecordModel> updateWatchlistItem(String itemId, Map<String, dynamic> data) async {
    try {
      final item = await _pb.collection('watchlistItems').update(itemId, body: data);
      _logger.i('Watchlist item updated: $itemId');
      return item;
    } catch (e) {
      _logger.e('Failed to update watchlist item: $e');
      rethrow;
    }
  }

  /// Check if symbol is in watchlist
  Future<bool> isInWatchlist(String symbol) async {
    try {
      if (!isAuthenticated) return false;
      
      final filter = 'userId = "${currentUserId}" && symbol = "$symbol"';
      final result = await _pb.collection('watchlistItems').getList(
        page: 1,
        perPage: 1,
        filter: filter,
      );
      return result.items.isNotEmpty;
    } catch (e) {
      _logger.e('Failed to check watchlist: $e');
      return false;
    }
  }

  /// Subscribe to watchlist real-time updates
  Stream<RecordModel> subscribeToWatchlist() {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    final filter = 'userId = "${currentUserId}"';
    return _pb.collection('watchlistItems').subscribe(filter: filter);
  }

  /// Utility Methods
  
  /// Get file URL for uploaded files
  String getFileUrl(RecordModel record, String filename, {String thumb = ''}) {
    return _pb.getFileUrl(record, filename, thumb: thumb);
  }

  /// Upload file
  Future<RecordModel> uploadFile(String collection, String recordId, String fieldName, String filePath) async {
    try {
      final record = await _pb.collection(collection).update(recordId, files: [
        http.MultipartFile.fromPath(fieldName, filePath),
      ]);
      return record;
    } catch (e) {
      _logger.e('Failed to upload file: $e');
      rethrow;
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final health = await _pb.health.check();
      return health.code == 200;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _pb.cancelAllRequests();
  }
}

/// Provider for PocketBase service
final pocketBaseServiceProvider = Provider<PocketBaseService>((ref) {
  return PocketBaseService();
});

/// Provider for authentication state
final authStateProvider = StreamProvider<RecordModel?>((ref) {
  final pocketBase = ref.watch(pocketBaseServiceProvider);
  
  return Stream.fromFuture(Future.value(pocketBase.currentUser))
      .asyncExpand((user) async* {
    yield user;
    
    // Listen to auth store changes
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      final currentUser = pocketBase.currentUser;
      if (currentUser?.id != user?.id) {
        yield currentUser;
        user = currentUser;
      }
    }
  });
});

/// Provider for current user profile
final currentUserProvider = FutureProvider<RecordModel?>((ref) async {
  final pocketBase = ref.watch(pocketBaseServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await pocketBase.getUserProfile(user.id);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});