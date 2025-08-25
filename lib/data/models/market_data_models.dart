import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'market_data_models.g.dart';

// Historical Bars Response
@JsonSerializable()
class HistoricalBarsResponse {
  final List<BarData> bars;
  @JsonKey(name: 'next_page_token')
  final String? nextPageToken;
  final String symbol;

  HistoricalBarsResponse({
    required this.bars,
    this.nextPageToken,
    required this.symbol,
  });

  factory HistoricalBarsResponse.fromJson(Map<String, dynamic> json) =>
      _$HistoricalBarsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HistoricalBarsResponseToJson(this);
}

// Latest Bars Response
@JsonSerializable()
class LatestBarsResponse {
  final Map<String, BarData> bars;

  LatestBarsResponse({required this.bars});

  factory LatestBarsResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestBarsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LatestBarsResponseToJson(this);
}

// Bar Data (OHLCV)
@JsonSerializable()
class BarData {
  @JsonKey(name: 't')
  final String timestamp;
  @JsonKey(name: 'o')
  final double open;
  @JsonKey(name: 'h')
  final double high;
  @JsonKey(name: 'l')
  final double low;
  @JsonKey(name: 'c')
  final double close;
  @JsonKey(name: 'v')
  final int volume;
  @JsonKey(name: 'n')
  final int? tradeCount;
  @JsonKey(name: 'vw')
  final double? vwap;

  BarData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.tradeCount,
    this.vwap,
  });

  DateTime get dateTime => DateTime.parse(timestamp);
  
  double get changeAmount => close - open;
  double get changePercent => ((close - open) / open) * 100;
  bool get isPositive => changeAmount >= 0;

  factory BarData.fromJson(Map<String, dynamic> json) =>
      _$BarDataFromJson(json);
  Map<String, dynamic> toJson() => _$BarDataToJson(this);
}

// Latest Quote Response
@JsonSerializable()
class LatestQuoteResponse {
  final String symbol;
  final QuoteData quote;

  LatestQuoteResponse({
    required this.symbol,
    required this.quote,
  });

  factory LatestQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestQuoteResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LatestQuoteResponseToJson(this);
}

// Quote Data
@JsonSerializable()
class QuoteData {
  @JsonKey(name: 't')
  final String timestamp;
  @JsonKey(name: 'ax')
  final String? askExchange;
  @JsonKey(name: 'ap')
  final double askPrice;
  @JsonKey(name: 'as')
  final int askSize;
  @JsonKey(name: 'bx')
  final String? bidExchange;
  @JsonKey(name: 'bp')
  final double bidPrice;
  @JsonKey(name: 'bs')
  final int bidSize;
  @JsonKey(name: 'c')
  final List<String>? conditions;

  QuoteData({
    required this.timestamp,
    this.askExchange,
    required this.askPrice,
    required this.askSize,
    this.bidExchange,
    required this.bidPrice,
    required this.bidSize,
    this.conditions,
  });

  DateTime get dateTime => DateTime.parse(timestamp);
  double get spread => askPrice - bidPrice;
  double get midPrice => (askPrice + bidPrice) / 2;

  factory QuoteData.fromJson(Map<String, dynamic> json) =>
      _$QuoteDataFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteDataToJson(this);
}

// Latest Trade Response
@JsonSerializable()
class LatestTradeResponse {
  final String symbol;
  final TradeData trade;

  LatestTradeResponse({
    required this.symbol,
    required this.trade,
  });

  factory LatestTradeResponse.fromJson(Map<String, dynamic> json) =>
      _$LatestTradeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LatestTradeResponseToJson(this);
}

// Trade Data
@JsonSerializable()
class TradeData {
  @JsonKey(name: 't')
  final String timestamp;
  @JsonKey(name: 'x')
  final String? exchange;
  @JsonKey(name: 'p')
  final double price;
  @JsonKey(name: 's')
  final int size;
  @JsonKey(name: 'c')
  final List<String>? conditions;
  @JsonKey(name: 'i')
  final int? id;
  @JsonKey(name: 'z')
  final String? tape;

  TradeData({
    required this.timestamp,
    this.exchange,
    required this.price,
    required this.size,
    this.conditions,
    this.id,
    this.tape,
  });

  DateTime get dateTime => DateTime.parse(timestamp);

  factory TradeData.fromJson(Map<String, dynamic> json) =>
      _$TradeDataFromJson(json);
  Map<String, dynamic> toJson() => _$TradeDataToJson(this);
}

// News Response
@JsonSerializable()
class NewsResponse {
  final List<NewsArticle> news;
  @JsonKey(name: 'next_page_token')
  final String? nextPageToken;

  NewsResponse({
    required this.news,
    this.nextPageToken,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NewsResponseToJson(this);
}

// News Article
@JsonSerializable()
class NewsArticle {
  final int id;
  final String headline;
  final String author;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String summary;
  final String? content;
  final List<String> symbols;
  final String url;
  @JsonKey(name: 'source')
  final String source;

  NewsArticle({
    required this.id,
    required this.headline,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.summary,
    this.content,
    required this.symbols,
    required this.url,
    required this.source,
  });

  DateTime get createdDateTime => DateTime.parse(createdAt);
  DateTime get updatedDateTime => DateTime.parse(updatedAt);

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);
  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);
}

// Snapshots Response
@JsonSerializable()
class SnapshotsResponse {
  final Map<String, SnapshotData> snapshots;

  SnapshotsResponse({required this.snapshots});

  factory SnapshotsResponse.fromJson(Map<String, dynamic> json) =>
      _$SnapshotsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotsResponseToJson(this);
}

// Snapshot Data (complete market data for a symbol)
@JsonSerializable()
class SnapshotData {
  @JsonKey(name: 'latestTrade')
  final TradeData? latestTrade;
  @JsonKey(name: 'latestQuote')
  final QuoteData? latestQuote;
  @JsonKey(name: 'minuteBar')
  final BarData? minuteBar;
  @JsonKey(name: 'dailyBar')
  final BarData? dailyBar;
  @JsonKey(name: 'prevDailyBar')
  final BarData? prevDailyBar;

  SnapshotData({
    this.latestTrade,
    this.latestQuote,
    this.minuteBar,
    this.dailyBar,
    this.prevDailyBar,
  });

  // Calculate daily change
  double? get dailyChange {
    if (dailyBar != null && prevDailyBar != null) {
      return dailyBar!.close - prevDailyBar!.close;
    }
    return null;
  }

  double? get dailyChangePercent {
    if (dailyBar != null && prevDailyBar != null && prevDailyBar!.close != 0) {
      return ((dailyBar!.close - prevDailyBar!.close) / prevDailyBar!.close) * 100;
    }
    return null;
  }

  bool get isDailyPositive => (dailyChange ?? 0) >= 0;

  factory SnapshotData.fromJson(Map<String, dynamic> json) =>
      _$SnapshotDataFromJson(json);
  Map<String, dynamic> toJson() => _$SnapshotDataToJson(this);
}

// Account Response
@JsonSerializable()
class AccountResponse {
  final String id;
  @JsonKey(name: 'account_number')
  final String accountNumber;
  final String status;
  @JsonKey(name: 'currency')
  final String currency;
  @JsonKey(name: 'cash')
  final String cash;
  @JsonKey(name: 'portfolio_value')
  final String portfolioValue;
  @JsonKey(name: 'pattern_day_trader')
  final bool patternDayTrader;
  @JsonKey(name: 'trade_suspended_by_user')
  final bool tradeSuspendedByUser;
  @JsonKey(name: 'trading_blocked')
  final bool tradingBlocked;
  @JsonKey(name: 'transfers_blocked')
  final bool transfersBlocked;
  @JsonKey(name: 'account_blocked')
  final bool accountBlocked;
  @JsonKey(name: 'created_at')
  final String createdAt;

  AccountResponse({
    required this.id,
    required this.accountNumber,
    required this.status,
    required this.currency,
    required this.cash,
    required this.portfolioValue,
    required this.patternDayTrader,
    required this.tradeSuspendedByUser,
    required this.tradingBlocked,
    required this.transfersBlocked,
    required this.accountBlocked,
    required this.createdAt,
  });

  double get cashAmount => double.tryParse(cash) ?? 0.0;
  double get portfolioAmount => double.tryParse(portfolioValue) ?? 0.0;
  DateTime get createdDateTime => DateTime.parse(createdAt);
  bool get canTrade => !tradingBlocked && !accountBlocked && !tradeSuspendedByUser;

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);
}

// Asset Response
@JsonSerializable()
class AssetResponse {
  final String id;
  @JsonKey(name: 'class')
  final String assetClass;
  final String exchange;
  final String symbol;
  final String name;
  final String status;
  final bool tradable;
  final bool marginable;
  final bool shortable;
  @JsonKey(name: 'easy_to_borrow')
  final bool easyToBorrow;
  final bool fractionable;

  AssetResponse({
    required this.id,
    required this.assetClass,
    required this.exchange,
    required this.symbol,
    required this.name,
    required this.status,
    required this.tradable,
    required this.marginable,
    required this.shortable,
    required this.easyToBorrow,
    required this.fractionable,
  });

  bool get isActive => status == 'active';
  bool get canTrade => tradable && isActive;

  factory AssetResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AssetResponseToJson(this);
}

// Utility class for market data conversions
class MarketDataUtils {
  static List<double> extractClosePrices(List<BarData> bars) {
    return bars.map((bar) => bar.close).toList();
  }

  static List<int> extractVolumes(List<BarData> bars) {
    return bars.map((bar) => bar.volume).toList();
  }

  static double calculateAverageVolume(List<BarData> bars) {
    if (bars.isEmpty) return 0.0;
    final totalVolume = bars.fold(0, (sum, bar) => sum + bar.volume);
    return totalVolume / bars.length;
  }

  static double calculateVolatility(List<BarData> bars) {
    if (bars.length < 2) return 0.0;
    
    final returns = <double>[];
    for (int i = 1; i < bars.length; i++) {
      if (bars[i - 1].close != 0) {
        returns.add((bars[i].close - bars[i - 1].close) / bars[i - 1].close);
      }
    }
    
    if (returns.isEmpty) return 0.0;
    
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / returns.length;
    
    return variance.isFinite ? sqrt(variance.abs()) : 0.0;
  }

  static Map<String, double> calculateTechnicalIndicators(List<BarData> bars) {
    if (bars.isEmpty) return {};

    final closes = extractClosePrices(bars);
    final volumes = extractVolumes(bars);

    return {
      'current_price': closes.last,
      'volume': volumes.last.toDouble(),
      'avg_volume_10': volumes.length >= 10 
          ? volumes.sublist(volumes.length - 10).reduce((a, b) => a + b) / 10.0 
          : volumes.last.toDouble(),
      'volatility': calculateVolatility(bars),
      'daily_change': bars.length >= 2 
          ? bars.last.close - bars[bars.length - 2].close 
          : 0.0,
      'daily_change_percent': bars.length >= 2 && bars[bars.length - 2].close != 0
          ? ((bars.last.close - bars[bars.length - 2].close) / bars[bars.length - 2].close) * 100
          : 0.0,
    };
  }
}