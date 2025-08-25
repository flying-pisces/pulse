import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/market_data_models.dart';

part 'alpaca_api_service.g.dart';

// Alpaca API Service for real market data
@RestApi()
abstract class AlpacaApiService {
  factory AlpacaApiService(Dio dio, {String baseUrl}) = _AlpacaApiService;

  // Market Data Endpoints
  @GET('/v2/stocks/{symbol}/bars')
  Future<HistoricalBarsResponse> getHistoricalBars(
    @Path() String symbol,
    @Query('timeframe') String timeframe,
    @Query('start') String start,
    @Query('end') String end,
    @Query('limit') int? limit,
    @Query('page_token') String? pageToken,
  );

  @GET('/v2/stocks/bars/latest')
  Future<LatestBarsResponse> getLatestBars(
    @Query('symbols') String symbols,
    @Query('feed') String? feed,
  );

  @GET('/v2/stocks/{symbol}/quotes/latest')
  Future<LatestQuoteResponse> getLatestQuote(
    @Path() String symbol,
    @Query('feed') String? feed,
  );

  @GET('/v2/stocks/{symbol}/trades/latest')
  Future<LatestTradeResponse> getLatestTrade(
    @Path() String symbol,
    @Query('feed') String? feed,
  );

  @GET('/v2/news')
  Future<NewsResponse> getNews(
    @Query('symbols') String? symbols,
    @Query('start') String? start,
    @Query('end') String? end,
    @Query('sort') String? sort,
    @Query('include_content') bool? includeContent,
    @Query('exclude_contentless') bool? excludeContentless,
    @Query('limit') int? limit,
    @Query('page_token') String? pageToken,
  );

  @GET('/v2/stocks/snapshots')
  Future<SnapshotsResponse> getSnapshots(
    @Query('symbols') String symbols,
    @Query('feed') String? feed,
  );

  // Account Information (for account validation)
  @GET('/v2/account')
  Future<AccountResponse> getAccount();

  // Assets (list of tradeable assets)
  @GET('/v2/assets')
  Future<List<AssetResponse>> getAssets(
    @Query('status') String? status,
    @Query('asset_class') String? assetClass,
    @Query('exchange') String? exchange,
  );
}

// Alpaca WebSocket Service for real-time data
class AlpacaWebSocketService {
  String? _wsUrl;
  String? _apiKey;
  String? _secretKey;
  
  // WebSocket connection will be implemented here
  // This is a placeholder for WebSocket functionality
  
  void initialize({
    required String wsUrl,
    required String apiKey,
    required String secretKey,
  }) {
    _wsUrl = wsUrl;
    _apiKey = apiKey;
    _secretKey = secretKey;
  }

  Future<void> connect() async {
    // TODO: Implement WebSocket connection
    // This would handle real-time market data streaming
    throw UnimplementedError('WebSocket connection not yet implemented');
  }

  Future<void> subscribe(List<String> symbols) async {
    // TODO: Subscribe to real-time data for symbols
    throw UnimplementedError('WebSocket subscription not yet implemented');
  }

  Future<void> unsubscribe(List<String> symbols) async {
    // TODO: Unsubscribe from real-time data for symbols
    throw UnimplementedError('WebSocket unsubscription not yet implemented');
  }

  Future<void> disconnect() async {
    // TODO: Disconnect WebSocket
    throw UnimplementedError('WebSocket disconnection not yet implemented');
  }

  Stream<MarketDataUpdate>? get marketDataStream {
    // TODO: Return stream of real-time market data updates
    throw UnimplementedError('Market data stream not yet implemented');
  }
}

// Market Data Update model for WebSocket
class MarketDataUpdate {
  final String symbol;
  final double price;
  final double volume;
  final DateTime timestamp;
  final String type; // 'trade', 'quote', 'bar'
  final Map<String, dynamic> data;

  MarketDataUpdate({
    required this.symbol,
    required this.price,
    required this.volume,
    required this.timestamp,
    required this.type,
    required this.data,
  });

  factory MarketDataUpdate.fromJson(Map<String, dynamic> json) {
    return MarketDataUpdate(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'unknown',
      data: json,
    );
  }
}

// Dio client configuration for Alpaca API
class AlpacaDioClient {
  static Dio createDio({
    required String baseUrl,
    required String apiKey,
    required String secretKey,
  }) {
    final dio = Dio();
    
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'APCA-API-KEY-ID': apiKey,
        'APCA-API-SECRET-KEY': secretKey,
        'Content-Type': 'application/json',
      },
    );

    // Add interceptors for logging and error handling
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // Use logger package for better logging
          print('[ALPACA API] $object');
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle common API errors
          if (error.response?.statusCode == 401) {
            throw AlpacaApiException('Invalid API credentials');
          } else if (error.response?.statusCode == 429) {
            throw AlpacaApiException('Rate limit exceeded');
          } else if (error.response?.statusCode == 403) {
            throw AlpacaApiException('Access forbidden - check account permissions');
          }
          
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}

// Custom Exception for Alpaca API
class AlpacaApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  AlpacaApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AlpacaApiException: $message';
}