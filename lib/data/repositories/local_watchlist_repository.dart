import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/entities/signal.dart';
import '../datasources/local_database_service.dart';

class LocalWatchlistRepository {
  final LocalDatabaseService _databaseService;

  LocalWatchlistRepository(this._databaseService);

  Future<List<WatchlistItem>> getAllWatchlistItems() async {
    return await _databaseService.getAllWatchlistItems();
  }

  Future<List<WatchlistItem>> getWatchlistItemsByType(SignalType type) async {
    return await _databaseService.getWatchlistItemsByType(type);
  }

  Future<WatchlistItem?> getWatchlistItemById(String id) async {
    return await _databaseService.getWatchlistItemById(id);
  }

  Future<WatchlistItem?> getWatchlistItemBySymbol(String symbol) async {
    return await _databaseService.getWatchlistItemBySymbol(symbol);
  }

  Future<WatchlistItem> addToWatchlist(WatchlistItem item) async {
    return await _databaseService.addToWatchlist(item);
  }

  Future<WatchlistItem> updateWatchlistItem(WatchlistItem item) async {
    return await _databaseService.updateWatchlistItem(item);
  }

  Future<void> removeFromWatchlist(String id) async {
    await _databaseService.removeFromWatchlist(id);
  }

  Future<void> removeFromWatchlistBySymbol(String symbol) async {
    await _databaseService.removeFromWatchlistBySymbol(symbol);
  }

  Future<void> clearWatchlist() async {
    await _databaseService.clearWatchlist();
  }

  Future<bool> isInWatchlist(String symbol) async {
    return await _databaseService.isInWatchlist(symbol);
  }

  Future<List<WatchlistItem>> searchWatchlist(String query) async {
    return await _databaseService.searchWatchlist(query);
  }

  Stream<List<WatchlistItem>> watchWatchlist() {
    return _databaseService.watchWatchlist();
  }

  Future<int> getWatchlistCount() async {
    return await _databaseService.getWatchlistCount();
  }

  Future<List<WatchlistItem>> getWatchlistItemsWithAlerts() async {
    return await _databaseService.getWatchlistItemsWithAlerts();
  }

  Future<List<WatchlistItem>> getTriggeredAlerts() async {
    return await _databaseService.getTriggeredAlerts();
  }

  Future<void> updatePrices(List<Map<String, dynamic>> priceUpdates) async {
    await _databaseService.updatePrices(priceUpdates);
  }

  Future<List<WatchlistItem>> getPaginatedWatchlist({
    int page = 0,
    int limit = 20,
    SignalType? type,
  }) async {
    final offset = page * limit;
    return await _databaseService.getPaginatedWatchlist(
      limit: limit,
      offset: offset,
      type: type,
    );
  }

  Future<void> batchSaveWatchlistItems(List<WatchlistItem> items) async {
    await _databaseService.batchInsertWatchlistItems(items);
  }

  // Toggle watchlist status for a symbol
  Future<bool> toggleWatchlist(WatchlistItem item) async {
    final isInWatchlist = await this.isInWatchlist(item.symbol);
    
    if (isInWatchlist) {
      await removeFromWatchlistBySymbol(item.symbol);
      return false;
    } else {
      await addToWatchlist(item);
      return true;
    }
  }

  // Bulk update prices from market data
  Future<void> updatePricesFromMarketData(Map<String, Map<String, double>> marketData) async {
    final updates = <Map<String, dynamic>>[];
    
    for (final entry in marketData.entries) {
      final symbol = entry.key;
      final data = entry.value;
      
      updates.add({
        'symbol': symbol,
        'currentPrice': data['price'] ?? 0.0,
        'priceChange': data['change'] ?? 0.0,
        'priceChangePercent': data['changePercent'] ?? 0.0,
      });
    }
    
    if (updates.isNotEmpty) {
      await updatePrices(updates);
    }
  }
}

final localWatchlistRepositoryProvider = Provider<LocalWatchlistRepository>((ref) {
  final databaseService = ref.watch(localDatabaseServiceProvider);
  return LocalWatchlistRepository(databaseService);
});