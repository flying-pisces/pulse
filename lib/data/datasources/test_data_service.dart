import '../../domain/entities/user.dart';
import '../../domain/entities/signal.dart';
import 'local_database_service.dart';

class TestDataService {
  final LocalDatabaseService _localDb;
  
  TestDataService(this._localDb);

  /// Create test users for different subscription tiers
  Future<void> createTestUsers() async {
    // Clear existing users first
    await _localDb.deleteAllUsers();
    
    final now = DateTime.now();
    
    // 1. Free User - your Gmail for testing
    final freeUser = User(
      id: 'test_free_001',
      email: 'your.email@gmail.com', // Replace with your actual Gmail
      firstName: 'Test',
      lastName: 'Free',
      createdAt: now,
      isVerified: true,
      subscriptionTier: SubscriptionTier.free,
      authProvider: AuthProvider.google,
      providerId: 'google_test_free',
    );
    
    // 2. Basic/Paid User
    final paidUser = User(
      id: 'test_paid_001',
      email: 'paid.user@test.com',
      firstName: 'Test',
      lastName: 'Paid',
      createdAt: now,
      isVerified: true,
      subscriptionTier: SubscriptionTier.basic,
      subscriptionExpiresAt: now.add(Duration(days: 30)),
      authProvider: AuthProvider.email,
      providerId: 'test_paid_001',
    );
    
    // 3. Premium User
    final premiumUser = User(
      id: 'test_premium_001',
      email: 'premium.user@test.com',
      firstName: 'Test',
      lastName: 'Premium',
      createdAt: now,
      isVerified: true,
      subscriptionTier: SubscriptionTier.premium,
      subscriptionExpiresAt: now.add(Duration(days: 365)),
      authProvider: AuthProvider.apple,
      providerId: 'apple_test_premium',
    );
    
    // 4. Pro (Super-Premium) User
    final proUser = User(
      id: 'test_pro_001',
      email: 'pro.user@test.com',
      firstName: 'Test',
      lastName: 'Pro',
      createdAt: now,
      isVerified: true,
      subscriptionTier: SubscriptionTier.pro,
      subscriptionExpiresAt: now.add(Duration(days: 365)),
      authProvider: AuthProvider.google,
      providerId: 'google_test_pro',
    );
    
    // Create users
    await _localDb.createUser(freeUser);
    await _localDb.createUser(paidUser);
    await _localDb.createUser(premiumUser);
    await _localDb.createUser(proUser);
    
    print('✅ Created test users:');
    print('- Free: ${freeUser.email}');
    print('- Paid: ${paidUser.email}');
    print('- Premium: ${premiumUser.email}');
    print('- Pro: ${proUser.email}');
  }

  /// Switch to a specific test user
  Future<void> switchToUser(String userId) async {
    // In a real app, this would set the current session
    // For testing, we'll just verify the user exists
    final user = await _localDb.getUserById(userId);
    if (user != null) {
      print('🔄 Switched to user: ${user.email} (${user.subscriptionTier.displayName})');
    } else {
      print('❌ User not found: $userId');
    }
  }

  /// Create sample signals for testing
  Future<void> createTestSignals() async {
    await _localDb.deleteAllSignals();
    
    final now = DateTime.now();
    
    final signals = [
      Signal(
        id: 'signal_ipo_001',
        symbol: 'CRCL',
        title: 'Hot IPO Momentum Play',
        description: 'Circle Internet Financial going public with massive retail interest',
        signalType: SignalType.ipo,
        direction: SignalDirection.bullish,
        entryPrice: 15.50,
        targetPrice: 35.00,
        stopLoss: 12.00,
        confidence: 85,
        requiredTier: SubscriptionTier.basic,
        status: SignalStatus.active,
        createdAt: now.subtract(Duration(hours: 2)),
        expiresAt: now.add(Duration(days: 1)),
        tags: ['IPO', 'momentum', 'retail'],
        metadata: {
          'market_cap': '2.1B',
          'ipo_price': '15.50',
          'day_1_high': '34.55',
          'volume': '25.6M'
        },
      ),
      
      Signal(
        id: 'signal_crypto_001',
        symbol: 'BTC',
        title: 'Bitcoin 150K Moonshot',
        description: 'Institutional accumulation phase, targeting $150K by year-end',
        signalType: SignalType.crypto,
        direction: SignalDirection.bullish,
        entryPrice: 97500.00,
        targetPrice: 150000.00,
        stopLoss: 85000.00,
        confidence: 75,
        requiredTier: SubscriptionTier.premium, // Premium only
        status: SignalStatus.active,
        createdAt: now.subtract(Duration(hours: 1)),
        expiresAt: now.add(Duration(days: 7)),
        tags: ['crypto', 'YOLO', 'institutional'],
        metadata: {
          'whale_activity': 'high',
          'institutional_inflow': '2.3B',
          'rsi': '65',
          'fear_greed': '72'
        },
      ),
      
      Signal(
        id: 'signal_options_001',
        symbol: 'TSLA',
        title: 'Iron Condor Theta Gang',
        description: 'Sideways movement expected, collect premium decay',
        signalType: SignalType.options,
        direction: SignalDirection.neutral,
        entryPrice: 245.00,
        targetPrice: 250.00,
        stopLoss: 230.00,
        confidence: 70,
        requiredTier: SubscriptionTier.basic,
        status: SignalStatus.active,
        createdAt: now.subtract(Duration(minutes: 30)),
        expiresAt: now.add(Duration(days: 14)),
        tags: ['options', 'theta', 'neutral'],
        metadata: {
          'iv_rank': '45',
          'theta_decay': '0.15',
          'probability': '68%',
          'max_profit': '1200'
        },
      ),
    ];
    
    for (final signal in signals) {
      await _localDb.createSignal(signal);
    }
    
    print('✅ Created ${signals.length} test signals');
  }

  /// Get current user info for testing
  Future<void> printCurrentUser() async {
    final user = await _localDb.getCurrentUser();
    if (user != null) {
      print('👤 Current User: ${user.email}');
      print('   Tier: ${user.subscriptionTier.displayName}');
      print('   Verified: ${user.isVerified}');
      print('   Active: ${user.isSubscriptionActive}');
    } else {
      print('❌ No current user');
    }
  }

  /// Test subscription tier access
  Future<void> testTierAccess() async {
    final user = await _localDb.getCurrentUser();
    if (user == null) return;
    
    final signals = await _localDb.getAllSignals();
    final accessibleSignals = signals.where((signal) => 
      _canAccessSignal(user.subscriptionTier, signal.requiredTier)
    ).toList();
    
    print('🔐 Access Test for ${user.subscriptionTier.displayName}:');
    print('   Total signals: ${signals.length}');
    print('   Accessible: ${accessibleSignals.length}');
    
    for (final signal in accessibleSignals) {
      print('   ✅ ${signal.symbol}: ${signal.title}');
    }
    
    final blockedSignals = signals.where((signal) => 
      !_canAccessSignal(user.subscriptionTier, signal.requiredTier)
    ).toList();
    
    for (final signal in blockedSignals) {
      print('   ❌ ${signal.symbol}: ${signal.title} (Requires ${signal.requiredTier.displayName})');
    }
  }

  bool _canAccessSignal(SubscriptionTier userTier, SubscriptionTier requiredTier) {
    const tierOrder = [
      SubscriptionTier.free,
      SubscriptionTier.basic,
      SubscriptionTier.premium,
      SubscriptionTier.pro,
    ];
    
    return tierOrder.indexOf(userTier) >= tierOrder.indexOf(requiredTier);
  }

  /// Clean up test data
  Future<void> cleanupTestData() async {
    await _localDb.clearAllData();
    print('🧹 Cleaned up all test data');
  }
}