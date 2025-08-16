import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import '../datasources/pocketbase_service.dart';
import '../models/market_data_models.dart';
import '../../domain/entities/watchlist_item.dart';

/// Repository for watchlist operations using PocketBase
class PocketBaseWatchlistRepository {
  final PocketBaseService _pocketBase;

  PocketBaseWatchlistRepository(this._pocketBase);

  /// Get user's watchlist
  Future<List<WatchlistItem>> getWatchlist({
    int page = 1,
    int perPage = 50,
    String sort = '-addedAt',
  }) async {
    try {
      final result = await _pocketBase.getWatchlist(
        page: page,
        perPage: perPage,
        sort: sort,
      );

      return result.items.map((record) => _mapRecordToWatchlistItem(record)).toList();
    } catch (e) {
      throw Exception('Failed to fetch watchlist: $e');
    }
  }

  /// Add item to watchlist
  Future<WatchlistItem> addToWatchlist({
    required String symbol,
    required String companyName,
    required SignalType type,
    required double currentPrice,
    required double priceChange,
    required double priceChangePercent,
    bool isPriceAlertEnabled = false,
    double? priceAlertTarget,
    String? notes,
  }) async {
    try {
      final record = await _pocketBase.addToWatchlist(
        symbol: symbol,
        companyName: companyName,
        type: type.name,
        currentPrice: currentPrice,
        priceChange: priceChange,
        priceChangePercent: priceChangePercent,
        isPriceAlertEnabled: isPriceAlertEnabled,
        priceAlertTarget: priceAlertTarget,
        notes: notes,
      );

      return _mapRecordToWatchlistItem(record);
    } catch (e) {
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  /// Remove item from watchlist
  Future<void> removeFromWatchlist(String itemId) async {
    try {
      await _pocketBase.removeFromWatchlist(itemId);
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  /// Remove item by symbol
  Future<void> removeFromWatchlistBySymbol(String symbol) async {
    try {
      final watchlist = await getWatchlist();
      final item = watchlist.where((item) => item.symbol == symbol).firstOrNull;
      
      if (item != null) {
        await removeFromWatchlist(item.id);
      }
    } catch (e) {
      throw Exception('Failed to remove from watchlist by symbol: $e');
    }
  }

  /// Update watchlist item
  Future<WatchlistItem> updateWatchlistItem(String itemId, {
    double? currentPrice,
    double? priceChange,
    double? priceChangePercent,
    bool? isPriceAlertEnabled,
    double? priceAlertTarget,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (currentPrice != null) data['currentPrice'] = currentPrice;
      if (priceChange != null) data['priceChange'] = priceChange;
      if (priceChangePercent != null) data['priceChangePercent'] = priceChangePercent;
      if (isPriceAlertEnabled != null) data['isPriceAlertEnabled'] = isPriceAlertEnabled;
      if (priceAlertTarget != null) data['priceAlertTarget'] = priceAlertTarget;
      if (notes != null) data['notes'] = notes;

      final record = await _pocketBase.updateWatchlistItem(itemId, data);
      return _mapRecordToWatchlistItem(record);
    } catch (e) {
      throw Exception('Failed to update watchlist item: $e');
    }
  }

  /// Update prices for watchlist items
  Future<List<WatchlistItem>> updateWatchlistPrices(Map<String, MarketData> marketDataMap) async {
    try {
      final watchlist = await getWatchlist();
      final updatedItems = <WatchlistItem>[];

      for (final item in watchlist) {
        final marketData = marketDataMap[item.symbol];
        if (marketData != null) {
          final updatedItem = await updateWatchlistItem(
            item.id,
            currentPrice: marketData.currentPrice,
            priceChange: marketData.priceChange,
            priceChangePercent: marketData.priceChangePercent,
          );
          updatedItems.add(updatedItem);
        } else {
          updatedItems.add(item);
        }
      }

      return updatedItems;
    } catch (e) {
      throw Exception('Failed to update watchlist prices: $e');
    }
  }

  /// Check if symbol is in watchlist
  Future<bool> isInWatchlist(String symbol) async {
    try {
      return await _pocketBase.isInWatchlist(symbol);
    } catch (e) {
      return false;
    }
  }

  /// Get watchlist item by symbol
  Future<WatchlistItem?> getWatchlistItemBySymbol(String symbol) async {
    try {
      final watchlist = await getWatchlist();
      return watchlist.where((item) => item.symbol == symbol).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Subscribe to real-time watchlist updates
  Stream<WatchlistItem> subscribeToWatchlist() {
    try {
      return _pocketBase.subscribeToWatchlist()
          .map((record) => _mapRecordToWatchlistItem(record));
    } catch (e) {
      throw Exception('Failed to subscribe to watchlist: $e');
    }
  }

  /// Get symbols from watchlist
  Future<List<String>> getWatchlistSymbols() async {
    try {
      final watchlist = await getWatchlist();
      return watchlist.map((item) => item.symbol).toList();
    } catch (e) {
      throw Exception('Failed to get watchlist symbols: $e');
    }
  }

  /// Get watchlist count
  Future<int> getWatchlistCount() async {
    try {
      final watchlist = await getWatchlist(perPage: 1);
      return watchlist.length;
    } catch (e) {
      return 0;
    }
  }

  /// Map PocketBase record to WatchlistItem entity
  WatchlistItem _mapRecordToWatchlistItem(RecordModel record) {
    return WatchlistItem(
      id: record.id,
      symbol: record.data['symbol'] ?? '',
      companyName: record.data['companyName'] ?? '',
      type: SignalType.values.firstWhere(
        (e) => e.name == record.data['type'],
        orElse: () => SignalType.stock,
      ),
      currentPrice: (record.data['currentPrice'] ?? 0).toDouble(),
      priceChange: (record.data['priceChange'] ?? 0).toDouble(),
      priceChangePercent: (record.data['priceChangePercent'] ?? 0).toDouble(),
      addedAt: DateTime.parse(record.data['addedAt'] ?? record.created),
      isPriceAlertEnabled: record.data['isPriceAlertEnabled'] ?? false,
      priceAlertTarget: record.data['priceAlertTarget']?.toDouble(),
      notes: record.data['notes'],
    );
  }
}

/// Provider for PocketBase watchlist repository
final pocketBaseWatchlistRepositoryProvider = Provider<PocketBaseWatchlistRepository>((ref) {
  final pocketBase = ref.watch(pocketBaseServiceProvider);
  return PocketBaseWatchlistRepository(pocketBase);
});

/// Provider for watchlist
final watchlistProvider = FutureProvider<List<WatchlistItem>>((ref) async {
  final repository = ref.watch(pocketBaseWatchlistRepositoryProvider);
  return repository.getWatchlist();
});

/// Provider for watchlist stream
final watchlistStreamProvider = StreamProvider<WatchlistItem>((ref) {
  final repository = ref.watch(pocketBaseWatchlistRepositoryProvider);
  return repository.subscribeToWatchlist();
});

/// Provider for checking if symbol is in watchlist
final isInWatchlistProvider = FutureProvider.family<bool, String>((ref, symbol) async {
  final repository = ref.watch(pocketBaseWatchlistRepositoryProvider);
  return repository.isInWatchlist(symbol);
});

/// Provider for watchlist symbols
final watchlistSymbolsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(pocketBaseWatchlistRepositoryProvider);
  return repository.getWatchlistSymbols();
});

/// Provider for watchlist count
final watchlistCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(pocketBaseWatchlistRepositoryProvider);
  return repository.getWatchlistCount();
});