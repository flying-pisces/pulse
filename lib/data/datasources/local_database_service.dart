import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/daos/user_dao.dart';
import '../database/daos/signal_dao.dart';
import '../database/daos/watchlist_dao.dart';
import '../database/converters.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/signal.dart';
import '../../domain/entities/watchlist_item.dart';

class LocalDatabaseService {
  late final AppDatabase _database;
  late final UserDao _userDao;
  late final SignalDao _signalDao;
  late final WatchlistDao _watchlistDao;

  LocalDatabaseService() {
    _database = AppDatabase();
    _userDao = UserDao(_database);
    _signalDao = SignalDao(_database);
    _watchlistDao = WatchlistDao(_database);
  }

  // User operations
  Future<User?> getCurrentUser() => _userDao.getCurrentUser();
  Future<User?> getUserById(String id) => _userDao.getUserById(id);
  Future<User?> getUserByEmail(String email) => _userDao.getUserByEmail(email);
  Future<User> createUser(User user) => _userDao.createUser(user);
  Future<User> updateUser(User user) => _userDao.updateUser(user);
  Future<void> deleteUser(String id) => _userDao.deleteUser(id);
  Future<void> deleteAllUsers() => _userDao.deleteAllUsers();
  Future<bool> hasUsers() => _userDao.hasUsers();
  Stream<User?> watchCurrentUser() => _userDao.watchCurrentUser();

  // Signal operations
  Future<List<Signal>> getAllSignals() => _signalDao.getAllSignals();
  Future<List<Signal>> getActiveSignals() => _signalDao.getActiveSignals();
  Future<List<Signal>> getSignalsByType(SignalType type) => _signalDao.getSignalsByType(type);
  Future<List<Signal>> getSignalsBySubscriptionTier(SubscriptionTier tier) => _signalDao.getSignalsBySubscriptionTier(tier);
  Future<Signal?> getSignalById(String id) => _signalDao.getSignalById(id);
  Future<Signal> createSignal(Signal signal) => _signalDao.createSignal(signal);
  Future<Signal> updateSignal(Signal signal) => _signalDao.updateSignal(signal);
  Future<void> deleteSignal(String id) => _signalDao.deleteSignal(id);
  Future<void> deleteAllSignals() => _signalDao.deleteAllSignals();
  Future<List<Signal>> searchSignals(String query) => _signalDao.searchSignals(query);
  Stream<List<Signal>> watchActiveSignals() => _signalDao.watchActiveSignals();
  Stream<Signal?> watchSignalById(String id) => _signalDao.watchSignalById(id);
  Future<int> getSignalsCount() => _signalDao.getSignalsCount();
  Future<List<Signal>> getPaginatedSignals({
    int limit = 20,
    int offset = 0,
    SignalStatus? status,
  }) => _signalDao.getPaginatedSignals(limit: limit, offset: offset, status: status);
  Future<void> markExpiredSignals() => _signalDao.markExpiredSignals();

  // Watchlist operations
  Future<List<WatchlistItem>> getAllWatchlistItems() => _watchlistDao.getAllWatchlistItems();
  Future<List<WatchlistItem>> getWatchlistItemsByType(SignalType type) => _watchlistDao.getWatchlistItemsByType(type);
  Future<WatchlistItem?> getWatchlistItemById(String id) => _watchlistDao.getWatchlistItemById(id);
  Future<WatchlistItem?> getWatchlistItemBySymbol(String symbol) => _watchlistDao.getWatchlistItemBySymbol(symbol);
  Future<WatchlistItem> addToWatchlist(WatchlistItem item) => _watchlistDao.addToWatchlist(item);
  Future<WatchlistItem> updateWatchlistItem(WatchlistItem item) => _watchlistDao.updateWatchlistItem(item);
  Future<void> removeFromWatchlist(String id) => _watchlistDao.removeFromWatchlist(id);
  Future<void> removeFromWatchlistBySymbol(String symbol) => _watchlistDao.removeFromWatchlistBySymbol(symbol);
  Future<void> clearWatchlist() => _watchlistDao.clearWatchlist();
  Future<bool> isInWatchlist(String symbol) => _watchlistDao.isInWatchlist(symbol);
  Future<List<WatchlistItem>> searchWatchlist(String query) => _watchlistDao.searchWatchlist(query);
  Stream<List<WatchlistItem>> watchWatchlist() => _watchlistDao.watchWatchlist();
  Stream<WatchlistItem?> watchWatchlistItemById(String id) => _watchlistDao.watchWatchlistItemById(id);
  Future<int> getWatchlistCount() => _watchlistDao.getWatchlistCount();
  Future<List<WatchlistItem>> getWatchlistItemsWithAlerts() => _watchlistDao.getWatchlistItemsWithAlerts();
  Future<List<WatchlistItem>> getTriggeredAlerts() => _watchlistDao.getTriggeredAlerts();
  Future<void> updatePrices(List<Map<String, dynamic>> priceUpdates) => _watchlistDao.updatePrices(priceUpdates);
  Future<List<WatchlistItem>> getPaginatedWatchlist({
    int limit = 20,
    int offset = 0,
    SignalType? type,
  }) => _watchlistDao.getPaginatedWatchlist(limit: limit, offset: offset, type: type);

  // Database operations
  Future<void> close() async {
    await _database.close();
  }

  Future<void> clearAllData() async {
    await _userDao.deleteAllUsers();
    await _signalDao.deleteAllSignals();
    await _watchlistDao.clearWatchlist();
  }

  // Batch operations for performance
  Future<void> batchInsertSignals(List<Signal> signals) async {
    await _database.batch((batch) {
      for (final signal in signals) {
        batch.insert(_database.signals, DatabaseConverters.signalToCompanion(signal));
      }
    });
  }

  Future<void> batchInsertWatchlistItems(List<WatchlistItem> items) async {
    await _database.batch((batch) {
      for (final item in items) {
        batch.insert(_database.watchlistItems, DatabaseConverters.watchlistItemToCompanion(item));
      }
    });
  }

  // Migration helpers for data sync
  Future<Map<String, dynamic>> exportData() async {
    return {
      'users': await _userDao.getAllUsers(),
      'signals': await _signalDao.getAllSignals(),
      'watchlist': await _watchlistDao.getAllWatchlistItems(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await clearAllData();
    
    // Import users
    if (data['users'] != null) {
      for (final userData in data['users'] as List) {
        if (userData is User) {
          await _userDao.createUser(userData);
        }
      }
    }
    
    // Import signals
    if (data['signals'] != null) {
      for (final signalData in data['signals'] as List) {
        if (signalData is Signal) {
          await _signalDao.createSignal(signalData);
        }
      }
    }
    
    // Import watchlist
    if (data['watchlist'] != null) {
      for (final watchlistData in data['watchlist'] as List) {
        if (watchlistData is WatchlistItem) {
          await _watchlistDao.addToWatchlist(watchlistData);
        }
      }
    }
  }

  // Health check
  Future<bool> isDatabaseHealthy() async {
    try {
      await _database.customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Riverpod provider
final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});

