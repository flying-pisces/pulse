import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/entities/signal.dart';

// Watchlist State
class WatchlistState {
  final List<WatchlistItem> items;
  final bool isLoading;
  final String? error;

  const WatchlistState({
    required this.items,
    required this.isLoading,
    this.error,
  });

  WatchlistState copyWith({
    List<WatchlistItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return WatchlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Watchlist State Notifier
class WatchlistNotifier extends StateNotifier<WatchlistState> {
  WatchlistNotifier() : super(const WatchlistState(items: [], isLoading: false));

  Future<void> loadWatchlist() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final mockItems = _generateMockWatchlistItems();
      
      state = state.copyWith(
        items: mockItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addToWatchlist(String symbol, String companyName, SignalType type) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if already exists
      final exists = state.items.any((item) => item.symbol == symbol);
      if (exists) {
        throw Exception('$symbol is already in your watchlist');
      }
      
      final newItem = WatchlistItem(
        id: 'watchlist_${DateTime.now().millisecondsSinceEpoch}',
        symbol: symbol,
        companyName: companyName,
        type: type,
        currentPrice: 100.0 + (DateTime.now().microsecond % 500),
        priceChange: (DateTime.now().microsecond % 200 - 100) / 10,
        priceChangePercent: (DateTime.now().microsecond % 200 - 100) / 100,
        addedAt: DateTime.now(),
        isPriceAlertEnabled: false,
      );
      
      state = state.copyWith(
        items: [...state.items, newItem],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromWatchlist(String itemId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        items: state.items.where((item) => item.id != itemId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePriceAlert(String itemId, bool enabled, double? targetPrice) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            isPriceAlertEnabled: enabled,
            priceAlertTarget: targetPrice,
          );
        }
        return item;
      }).toList();
      
      state = state.copyWith(items: updatedItems);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<WatchlistItem> _generateMockWatchlistItems() {
    final symbols = ['AAPL', 'GOOGL', 'TSLA', 'BTC', 'NVDA'];
    final companies = [
      'Apple Inc.',
      'Alphabet Inc.',
      'Tesla Inc.',
      'Bitcoin',
      'NVIDIA Corporation'
    ];
    
    return List.generate(5, (index) {
      final random = DateTime.now().millisecondsSinceEpoch + index;
      final currentPrice = 100.0 + (random % 500);
      final priceChange = (random % 200 - 100) / 10;
      
      return WatchlistItem(
        id: 'watchlist_$index',
        symbol: symbols[index],
        companyName: companies[index],
        type: index == 3 ? SignalType.crypto : SignalType.stock,
        currentPrice: currentPrice,
        priceChange: priceChange,
        priceChangePercent: priceChange / currentPrice * 100,
        addedAt: DateTime.now().subtract(Duration(days: index + 1)),
        isPriceAlertEnabled: index % 2 == 0,
        priceAlertTarget: index % 2 == 0 ? currentPrice * 1.1 : null,
        notes: index == 0 ? 'Strong buy signal from AI' : null,
      );
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
  return WatchlistNotifier();
});

// Helper providers
final watchlistItemsWithAlertsProvider = Provider<List<WatchlistItem>>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.items.where((item) => item.isPriceAlertEnabled).toList();
});

final watchlistStatsProvider = Provider<Map<String, int>>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  final items = watchlist.items;
  
  return {
    'total': items.length,
    'up': items.where((item) => item.isPriceUp).length,
    'down': items.where((item) => item.isPriceDown).length,
    'alerts': items.where((item) => item.isPriceAlertEnabled).length,
  };
});