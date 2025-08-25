import 'package:dio/dio.dart';
import '../services/alpaca_api_service.dart';
import '../models/market_data_models.dart';

// Abstract Repository Interface
abstract class MarketDataRepository {
  Future<List<BarData>> getHistoricalBars({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
    String? pageToken,
  });

  Future<Map<String, BarData>> getLatestBars(List<String> symbols);
  Future<QuoteData> getLatestQuote(String symbol);
  Future<TradeData> getLatestTrade(String symbol);
  Future<List<NewsArticle>> getNews({
    List<String>? symbols,
    DateTime? start,
    DateTime? end,
    String? sort,
    bool? includeContent,
    int? limit,
  });
  Future<Map<String, SnapshotData>> getSnapshots(List<String> symbols);
  Future<AccountResponse> getAccount();
  Future<List<AssetResponse>> getAssets({
    String? status,
    String? assetClass,
    String? exchange,
  });
  Future<bool> validateConnection();
}

// Implementation using Alpaca API
class AlpacaMarketDataRepository implements MarketDataRepository {
  final AlpacaApiService _apiService;
  
  AlpacaMarketDataRepository(this._apiService);

  @override
  Future<List<BarData>> getHistoricalBars({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
    String? pageToken,
  }) async {
    try {
      final response = await _apiService.getHistoricalBars(
        symbol,
        timeframe,
        start.toIso8601String(),
        end.toIso8601String(),
        limit,
        pageToken,
      );
      return response.bars;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch historical bars for $symbol: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching historical bars: $e');
    }
  }

  @override
  Future<Map<String, BarData>> getLatestBars(List<String> symbols) async {
    try {
      final symbolsString = symbols.join(',');
      final response = await _apiService.getLatestBars(symbolsString);
      return response.bars;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch latest bars: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching latest bars: $e');
    }
  }

  @override
  Future<QuoteData> getLatestQuote(String symbol) async {
    try {
      final response = await _apiService.getLatestQuote(symbol);
      return response.quote;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch latest quote for $symbol: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching latest quote: $e');
    }
  }

  @override
  Future<TradeData> getLatestTrade(String symbol) async {
    try {
      final response = await _apiService.getLatestTrade(symbol);
      return response.trade;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch latest trade for $symbol: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching latest trade: $e');
    }
  }

  @override
  Future<List<NewsArticle>> getNews({
    List<String>? symbols,
    DateTime? start,
    DateTime? end,
    String? sort,
    bool? includeContent,
    int? limit,
  }) async {
    try {
      final symbolsString = symbols?.join(',');
      final response = await _apiService.getNews(
        symbolsString,
        start?.toIso8601String(),
        end?.toIso8601String(),
        sort ?? 'desc',
        includeContent ?? false,
        false, // excludeContentless
        limit ?? 50,
        null, // pageToken
      );
      return response.news;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch news: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching news: $e');
    }
  }

  @override
  Future<Map<String, SnapshotData>> getSnapshots(List<String> symbols) async {
    try {
      final symbolsString = symbols.join(',');
      final response = await _apiService.getSnapshots(symbolsString);
      return response.snapshots;
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch snapshots: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching snapshots: $e');
    }
  }

  @override
  Future<AccountResponse> getAccount() async {
    try {
      return await _apiService.getAccount();
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch account information: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching account: $e');
    }
  }

  @override
  Future<List<AssetResponse>> getAssets({
    String? status,
    String? assetClass,
    String? exchange,
  }) async {
    try {
      return await _apiService.getAssets(
        status ?? 'active',
        assetClass,
        exchange,
      );
    } on DioException catch (e) {
      throw MarketDataException(
        'Failed to fetch assets: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw MarketDataException('Unexpected error fetching assets: $e');
    }
  }

  @override
  Future<bool> validateConnection() async {
    try {
      await _apiService.getAccount();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Mock Repository for Development/Testing
class MockMarketDataRepository implements MarketDataRepository {
  @override
  Future<List<BarData>> getHistoricalBars({
    required String symbol,
    required String timeframe,
    required DateTime start,
    required DateTime end,
    int? limit,
    String? pageToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate mock historical data
    final bars = <BarData>[];
    final now = DateTime.now();
    double price = 100.0;
    
    for (int i = 0; i < (limit ?? 30); i++) {
      final date = now.subtract(Duration(days: limit! - i));
      final changePercent = (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 100;
      final open = price;
      final close = price * (1 + changePercent * 0.05);
      final high = [open, close].reduce((a, b) => a > b ? a : b) * 1.02;
      final low = [open, close].reduce((a, b) => a < b ? a : b) * 0.98;
      
      bars.add(BarData(
        timestamp: date.toIso8601String(),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 1000000 + (date.millisecondsSinceEpoch % 500000),
        tradeCount: 1000 + (date.millisecondsSinceEpoch % 500),
        vwap: (open + close) / 2,
      ));
      
      price = close;
    }
    
    return bars;
  }

  @override
  Future<Map<String, BarData>> getLatestBars(List<String> symbols) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final bars = <String, BarData>{};
    for (final symbol in symbols) {
      final price = 50.0 + (symbol.hashCode % 500);
      bars[symbol] = BarData(
        timestamp: DateTime.now().toIso8601String(),
        open: price,
        high: price * 1.02,
        low: price * 0.98,
        close: price * (1 + (symbol.hashCode % 10 - 5) / 100),
        volume: 1000000 + (symbol.hashCode % 500000),
        tradeCount: 1000,
        vwap: price,
      );
    }
    
    return bars;
  }

  @override
  Future<QuoteData> getLatestQuote(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final price = 50.0 + (symbol.hashCode % 500);
    return QuoteData(
      timestamp: DateTime.now().toIso8601String(),
      askPrice: price + 0.01,
      askSize: 100,
      bidPrice: price - 0.01,
      bidSize: 100,
    );
  }

  @override
  Future<TradeData> getLatestTrade(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final price = 50.0 + (symbol.hashCode % 500);
    return TradeData(
      timestamp: DateTime.now().toIso8601String(),
      price: price,
      size: 100,
      exchange: 'NYSE',
    );
  }

  @override
  Future<List<NewsArticle>> getNews({
    List<String>? symbols,
    DateTime? start,
    DateTime? end,
    String? sort,
    bool? includeContent,
    int? limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final news = <NewsArticle>[];
    for (int i = 0; i < (limit ?? 10); i++) {
      news.add(NewsArticle(
        id: i,
        headline: 'Mock News Headline ${i + 1}',
        author: 'Mock Author',
        createdAt: DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        updatedAt: DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        summary: 'This is a mock news summary for testing purposes.',
        content: includeContent == true ? 'Mock news content...' : null,
        symbols: symbols ?? ['AAPL', 'GOOGL', 'MSFT'],
        url: 'https://mock-news.com/article-${i + 1}',
        source: 'Mock News Source',
      ));
    }
    
    return news;
  }

  @override
  Future<Map<String, SnapshotData>> getSnapshots(List<String> symbols) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final snapshots = <String, SnapshotData>{};
    for (final symbol in symbols) {
      final price = 50.0 + (symbol.hashCode % 500);
      final prevPrice = price * 0.99;
      
      snapshots[symbol] = SnapshotData(
        latestTrade: TradeData(
          timestamp: DateTime.now().toIso8601String(),
          price: price,
          size: 100,
          exchange: 'NYSE',
        ),
        latestQuote: QuoteData(
          timestamp: DateTime.now().toIso8601String(),
          askPrice: price + 0.01,
          askSize: 100,
          bidPrice: price - 0.01,
          bidSize: 100,
        ),
        dailyBar: BarData(
          timestamp: DateTime.now().toIso8601String(),
          open: prevPrice,
          high: price * 1.02,
          low: prevPrice * 0.98,
          close: price,
          volume: 1000000,
          tradeCount: 1000,
          vwap: price,
        ),
        prevDailyBar: BarData(
          timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          open: prevPrice * 0.99,
          high: prevPrice * 1.01,
          low: prevPrice * 0.97,
          close: prevPrice,
          volume: 950000,
          tradeCount: 900,
          vwap: prevPrice,
        ),
      );
    }
    
    return snapshots;
  }

  @override
  Future<AccountResponse> getAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return AccountResponse(
      id: 'mock-account-id',
      accountNumber: '123456789',
      status: 'ACTIVE',
      currency: 'USD',
      cash: '10000.00',
      portfolioValue: '15000.00',
      patternDayTrader: false,
      tradeSuspendedByUser: false,
      tradingBlocked: false,
      transfersBlocked: false,
      accountBlocked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    );
  }

  @override
  Future<List<AssetResponse>> getAssets({
    String? status,
    String? assetClass,
    String? exchange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final mockAssets = [
      'AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN', 'NVDA', 'META', 'NFLX', 'AMD', 'ORCL'
    ];
    
    return mockAssets.map((symbol) => AssetResponse(
      id: symbol.toLowerCase(),
      assetClass: 'us_equity',
      exchange: 'NASDAQ',
      symbol: symbol,
      name: '$symbol Corporation',
      status: 'active',
      tradable: true,
      marginable: true,
      shortable: true,
      easyToBorrow: true,
      fractionable: true,
    )).toList();
  }

  @override
  Future<bool> validateConnection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Mock always returns true
  }
}

// Repository Factory for dependency injection
class MarketDataRepositoryFactory {
  static MarketDataRepository create({
    required bool useRealData,
    String? apiKey,
    String? secretKey,
    String? baseUrl,
  }) {
    if (useRealData && apiKey != null && secretKey != null && baseUrl != null) {
      final dio = AlpacaDioClient.createDio(
        baseUrl: baseUrl,
        apiKey: apiKey,
        secretKey: secretKey,
      );
      final apiService = AlpacaApiService(dio);
      return AlpacaMarketDataRepository(apiService);
    } else {
      return MockMarketDataRepository();
    }
  }
}

// Custom Exception for Market Data operations
class MarketDataException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  MarketDataException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'MarketDataException: $message';

  bool get isAuthError => statusCode == 401 || statusCode == 403;
  bool get isRateLimitError => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}