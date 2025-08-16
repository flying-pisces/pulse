import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pulse/data/database/database.dart';
import 'package:pulse/domain/entities/user.dart';
import 'package:pulse/domain/entities/signal.dart';
import 'package:pulse/domain/entities/watchlist_item.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Database Tests', () {
    late AppDatabase database;

    setUp(() {
      // Create an in-memory database for testing
      database = AppDatabaseTest.testDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    test('should create and retrieve a user', () async {
      final user = User(
        id: const Uuid().v4(),
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        isVerified: false,
        subscriptionTier: SubscriptionTier.free,
        authProvider: AuthProvider.email,
      );

      // Create user using the DAO pattern through the service
      final userDao = database.userDao;
      await userDao.createUser(user);

      // Retrieve user
      final retrievedUser = await userDao.getUserById(user.id);

      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.email, equals(user.email));
      expect(retrievedUser.firstName, equals(user.firstName));
      expect(retrievedUser.lastName, equals(user.lastName));
    });

    test('should create and retrieve a signal', () async {
      final signal = Signal(
        id: const Uuid().v4(),
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        type: SignalType.stock,
        action: SignalAction.buy,
        currentPrice: 150.0,
        targetPrice: 170.0,
        stopLoss: 140.0,
        confidence: 0.85,
        reasoning: 'Strong quarterly earnings expected',
        createdAt: DateTime.now(),
        status: SignalStatus.active,
        tags: ['tech', 'growth'],
        requiredTier: SubscriptionTier.free,
      );

      final signalDao = database.signalDao;
      await signalDao.createSignal(signal);

      final retrievedSignal = await signalDao.getSignalById(signal.id);

      expect(retrievedSignal, isNotNull);
      expect(retrievedSignal!.symbol, equals(signal.symbol));
      expect(retrievedSignal.action, equals(signal.action));
      expect(retrievedSignal.confidence, equals(signal.confidence));
    });

    test('should create and retrieve a watchlist item', () async {
      final watchlistItem = WatchlistItem(
        id: const Uuid().v4(),
        symbol: 'TSLA',
        companyName: 'Tesla, Inc.',
        type: SignalType.stock,
        currentPrice: 250.0,
        priceChange: 5.0,
        priceChangePercent: 2.0,
        addedAt: DateTime.now(),
        isPriceAlertEnabled: true,
        priceAlertTarget: 300.0,
      );

      final watchlistDao = database.watchlistDao;
      await watchlistDao.addToWatchlist(watchlistItem);

      final retrievedItem = await watchlistDao.getWatchlistItemById(watchlistItem.id);

      expect(retrievedItem, isNotNull);
      expect(retrievedItem!.symbol, equals(watchlistItem.symbol));
      expect(retrievedItem.isPriceAlertEnabled, equals(true));
      expect(retrievedItem.priceAlertTarget, equals(300.0));
    });

    test('should query active signals', () async {
      // Create multiple signals with different statuses
      final activeSignal = Signal(
        id: const Uuid().v4(),
        symbol: 'GOOGL',
        companyName: 'Alphabet Inc.',
        type: SignalType.stock,
        action: SignalAction.buy,
        currentPrice: 100.0,
        targetPrice: 110.0,
        stopLoss: 95.0,
        confidence: 0.8,
        reasoning: 'AI developments',
        createdAt: DateTime.now(),
        status: SignalStatus.active,
        tags: ['tech'],
        requiredTier: SubscriptionTier.free,
      );

      final expiredSignal = Signal(
        id: const Uuid().v4(),
        symbol: 'MSFT',
        companyName: 'Microsoft Corporation',
        type: SignalType.stock,
        action: SignalAction.sell,
        currentPrice: 200.0,
        targetPrice: 180.0,
        stopLoss: 210.0,
        confidence: 0.7,
        reasoning: 'Market correction expected',
        createdAt: DateTime.now(),
        status: SignalStatus.expired,
        tags: ['tech'],
        requiredTier: SubscriptionTier.basic,
      );

      final signalDao = database.signalDao;
      await signalDao.createSignal(activeSignal);
      await signalDao.createSignal(expiredSignal);

      final activeSignals = await signalDao.getActiveSignals();

      expect(activeSignals.length, equals(1));
      expect(activeSignals.first.symbol, equals('GOOGL'));
    });

    test('should search watchlist items', () async {
      final appleItem = WatchlistItem(
        id: const Uuid().v4(),
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        type: SignalType.stock,
        currentPrice: 150.0,
        priceChange: 2.0,
        priceChangePercent: 1.3,
        addedAt: DateTime.now(),
        isPriceAlertEnabled: false,
      );

      final teslaItem = WatchlistItem(
        id: const Uuid().v4(),
        symbol: 'TSLA',
        companyName: 'Tesla, Inc.',
        type: SignalType.stock,
        currentPrice: 250.0,
        priceChange: -5.0,
        priceChangePercent: -2.0,
        addedAt: DateTime.now(),
        isPriceAlertEnabled: false,
      );

      final watchlistDao = database.watchlistDao;
      await watchlistDao.addToWatchlist(appleItem);
      await watchlistDao.addToWatchlist(teslaItem);

      final searchResults = await watchlistDao.searchWatchlist('Apple');

      expect(searchResults.length, equals(1));
      expect(searchResults.first.symbol, equals('AAPL'));
    });
  });
}

// Extension to create test database
extension AppDatabaseTest on AppDatabase {
  static AppDatabase testDatabase() {
    return AppDatabase.withExecutor(NativeDatabase.memory());
  }
}