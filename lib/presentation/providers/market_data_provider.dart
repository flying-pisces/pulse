import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/env_config.dart';
import '../../data/repositories/market_data_repository.dart';
import '../../data/models/market_data_models.dart';

// Market Data Repository Provider
final marketDataRepositoryProvider = Provider<MarketDataRepository>((ref) {
  return MarketDataRepositoryFactory.create(
    useRealData: EnvConfig.shouldUseRealMarketData,
    apiKey: EnvConfig.alpacaApiKey,
    secretKey: EnvConfig.alpacaSecretKey,
    baseUrl: EnvConfig.alpacaBaseUrl,
  );
});

// Market Data State Classes
class MarketDataState {
  final Map<String, SnapshotData> snapshots;
  final List<NewsArticle> news;
  final bool isLoading;
  final String? error;

  const MarketDataState({
    this.snapshots = const {},
    this.news = const [],
    required this.isLoading,
    this.error,
  });

  MarketDataState copyWith({
    Map<String, SnapshotData>? snapshots,
    List<NewsArticle>? news,
    bool? isLoading,
    String? error,
  }) {
    return MarketDataState(
      snapshots: snapshots ?? this.snapshots,
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Market Data Notifier
class MarketDataNotifier extends StateNotifier<MarketDataState> {
  final MarketDataRepository _repository;
  
  MarketDataNotifier(this._repository) : super(const MarketDataState(isLoading: false));

  Future<void> loadSnapshots(List<String> symbols) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final snapshots = await _repository.getSnapshots(symbols);
      state = state.copyWith(
        snapshots: snapshots,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNews({List<String>? symbols, int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final news = await _repository.getNews(
        symbols: symbols,
        limit: limit,
        sort: 'desc',
      );
      state = state.copyWith(
        news: news,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshData(List<String> symbols) async {
    await Future.wait([
      loadSnapshots(symbols),
      loadNews(symbols: symbols),
    ]);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Market Data Provider
final marketDataProvider = StateNotifierProvider<MarketDataNotifier, MarketDataState>((ref) {
  final repository = ref.read(marketDataRepositoryProvider);
  return MarketDataNotifier(repository);
});

// Individual Stock Data Provider
final stockDataProvider = FutureProvider.family<SnapshotData?, String>((ref, symbol) async {
  final repository = ref.read(marketDataRepositoryProvider);
  try {
    final snapshots = await repository.getSnapshots([symbol]);
    return snapshots[symbol];
  } catch (e) {
    return null;
  }
});

// Historical Data Provider
final historicalDataProvider = FutureProvider.family<List<BarData>, HistoricalDataParams>((ref, params) async {
  final repository = ref.read(marketDataRepositoryProvider);
  return repository.getHistoricalBars(
    symbol: params.symbol,
    timeframe: params.timeframe,
    start: params.start,
    end: params.end,
    limit: params.limit,
  );
});

// News Provider
final newsProvider = FutureProvider.family<List<NewsArticle>, NewsParams>((ref, params) async {
  final repository = ref.read(marketDataRepositoryProvider);
  return repository.getNews(
    symbols: params.symbols,
    limit: params.limit,
    sort: params.sort,
  );
});

// Watchlist Snapshots Provider
final watchlistSnapshotsProvider = FutureProvider.family<Map<String, SnapshotData>, List<String>>((ref, symbols) async {
  if (symbols.isEmpty) return {};
  
  final repository = ref.read(marketDataRepositoryProvider);
  return repository.getSnapshots(symbols);
});

// Connection Status Provider
final marketDataConnectionProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(marketDataRepositoryProvider);
  return repository.validateConnection();
});

// Parameter Classes for Providers
class HistoricalDataParams {
  final String symbol;
  final String timeframe;
  final DateTime start;
  final DateTime end;
  final int? limit;

  HistoricalDataParams({
    required this.symbol,
    required this.timeframe,
    required this.start,
    required this.end,
    this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoricalDataParams &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          timeframe == other.timeframe &&
          start == other.start &&
          end == other.end &&
          limit == other.limit;

  @override
  int get hashCode =>
      symbol.hashCode ^
      timeframe.hashCode ^
      start.hashCode ^
      end.hashCode ^
      (limit?.hashCode ?? 0);
}

class NewsParams {
  final List<String>? symbols;
  final int limit;
  final String sort;

  NewsParams({
    this.symbols,
    this.limit = 10,
    this.sort = 'desc',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsParams &&
          runtimeType == other.runtimeType &&
          symbols == other.symbols &&
          limit == other.limit &&
          sort == other.sort;

  @override
  int get hashCode =>
      symbols.hashCode ^
      limit.hashCode ^
      sort.hashCode;
}

// Market Data Utils Provider
final marketDataUtilsProvider = Provider<MarketDataUtils>((ref) {
  return MarketDataUtils();
});

// Account Information Provider (for Alpaca account validation)
final accountInfoProvider = FutureProvider<AccountResponse?>((ref) async {
  final repository = ref.read(marketDataRepositoryProvider);
  try {
    return await repository.getAccount();
  } catch (e) {
    // If account info fails, it's likely using mock data or invalid credentials
    return null;
  }
});

// Assets Provider (tradeable securities)
final assetsProvider = FutureProvider<List<AssetResponse>>((ref) async {
  final repository = ref.read(marketDataRepositoryProvider);
  return repository.getAssets(status: 'active');
});

// Popular Symbols Provider (commonly traded stocks)
final popularSymbolsProvider = Provider<List<String>>((ref) {
  // This could be fetched from a backend or configured based on user preferences
  return [
    'AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN', 
    'NVDA', 'META', 'NFLX', 'AMD', 'ORCL',
    'SPY', 'QQQ', 'IWM',  // ETFs
  ];
});

// Market Status Provider
final marketStatusProvider = Provider<MarketStatus>((ref) {
  final now = DateTime.now();
  final easternTime = now.toUtc().subtract(const Duration(hours: 4)); // Rough EST conversion
  
  // Market hours: 9:30 AM - 4:00 PM EST
  final marketOpen = DateTime(easternTime.year, easternTime.month, easternTime.day, 9, 30);
  final marketClose = DateTime(easternTime.year, easternTime.month, easternTime.day, 16, 0);
  
  // Weekend check
  final isWeekend = easternTime.weekday == DateTime.saturday || easternTime.weekday == DateTime.sunday;
  
  if (isWeekend) {
    return MarketStatus.closed;
  } else if (easternTime.isBefore(marketOpen)) {
    return MarketStatus.preMarket;
  } else if (easternTime.isAfter(marketClose)) {
    return MarketStatus.afterHours;
  } else {
    return MarketStatus.open;
  }
});

enum MarketStatus {
  open,
  closed,
  preMarket,
  afterHours;

  String get displayName {
    switch (this) {
      case MarketStatus.open:
        return 'Market Open';
      case MarketStatus.closed:
        return 'Market Closed';
      case MarketStatus.preMarket:
        return 'Pre-Market';
      case MarketStatus.afterHours:
        return 'After Hours';
    }
  }

  bool get isTrading => this == MarketStatus.open;
}