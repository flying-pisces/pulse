// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoricalBarsResponse _$HistoricalBarsResponseFromJson(
  Map<String, dynamic> json,
) => HistoricalBarsResponse(
  bars: (json['bars'] as List<dynamic>)
      .map((e) => BarData.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextPageToken: json['next_page_token'] as String?,
  symbol: json['symbol'] as String,
);

Map<String, dynamic> _$HistoricalBarsResponseToJson(
  HistoricalBarsResponse instance,
) => <String, dynamic>{
  'bars': instance.bars,
  'next_page_token': instance.nextPageToken,
  'symbol': instance.symbol,
};

LatestBarsResponse _$LatestBarsResponseFromJson(Map<String, dynamic> json) =>
    LatestBarsResponse(
      bars: (json['bars'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, BarData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$LatestBarsResponseToJson(LatestBarsResponse instance) =>
    <String, dynamic>{'bars': instance.bars};

BarData _$BarDataFromJson(Map<String, dynamic> json) => BarData(
  timestamp: json['t'] as String,
  open: (json['o'] as num).toDouble(),
  high: (json['h'] as num).toDouble(),
  low: (json['l'] as num).toDouble(),
  close: (json['c'] as num).toDouble(),
  volume: (json['v'] as num).toInt(),
  tradeCount: (json['n'] as num?)?.toInt(),
  vwap: (json['vw'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BarDataToJson(BarData instance) => <String, dynamic>{
  't': instance.timestamp,
  'o': instance.open,
  'h': instance.high,
  'l': instance.low,
  'c': instance.close,
  'v': instance.volume,
  'n': instance.tradeCount,
  'vw': instance.vwap,
};

LatestQuoteResponse _$LatestQuoteResponseFromJson(Map<String, dynamic> json) =>
    LatestQuoteResponse(
      symbol: json['symbol'] as String,
      quote: QuoteData.fromJson(json['quote'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LatestQuoteResponseToJson(
  LatestQuoteResponse instance,
) => <String, dynamic>{'symbol': instance.symbol, 'quote': instance.quote};

QuoteData _$QuoteDataFromJson(Map<String, dynamic> json) => QuoteData(
  timestamp: json['t'] as String,
  askExchange: json['ax'] as String?,
  askPrice: (json['ap'] as num).toDouble(),
  askSize: (json['as'] as num).toInt(),
  bidExchange: json['bx'] as String?,
  bidPrice: (json['bp'] as num).toDouble(),
  bidSize: (json['bs'] as num).toInt(),
  conditions: (json['c'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$QuoteDataToJson(QuoteData instance) => <String, dynamic>{
  't': instance.timestamp,
  'ax': instance.askExchange,
  'ap': instance.askPrice,
  'as': instance.askSize,
  'bx': instance.bidExchange,
  'bp': instance.bidPrice,
  'bs': instance.bidSize,
  'c': instance.conditions,
};

LatestTradeResponse _$LatestTradeResponseFromJson(Map<String, dynamic> json) =>
    LatestTradeResponse(
      symbol: json['symbol'] as String,
      trade: TradeData.fromJson(json['trade'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LatestTradeResponseToJson(
  LatestTradeResponse instance,
) => <String, dynamic>{'symbol': instance.symbol, 'trade': instance.trade};

TradeData _$TradeDataFromJson(Map<String, dynamic> json) => TradeData(
  timestamp: json['t'] as String,
  exchange: json['x'] as String?,
  price: (json['p'] as num).toDouble(),
  size: (json['s'] as num).toInt(),
  conditions: (json['c'] as List<dynamic>?)?.map((e) => e as String).toList(),
  id: (json['i'] as num?)?.toInt(),
  tape: json['z'] as String?,
);

Map<String, dynamic> _$TradeDataToJson(TradeData instance) => <String, dynamic>{
  't': instance.timestamp,
  'x': instance.exchange,
  'p': instance.price,
  's': instance.size,
  'c': instance.conditions,
  'i': instance.id,
  'z': instance.tape,
};

NewsResponse _$NewsResponseFromJson(Map<String, dynamic> json) => NewsResponse(
  news: (json['news'] as List<dynamic>)
      .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextPageToken: json['next_page_token'] as String?,
);

Map<String, dynamic> _$NewsResponseToJson(NewsResponse instance) =>
    <String, dynamic>{
      'news': instance.news,
      'next_page_token': instance.nextPageToken,
    };

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
  id: (json['id'] as num).toInt(),
  headline: json['headline'] as String,
  author: json['author'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  summary: json['summary'] as String,
  content: json['content'] as String?,
  symbols: (json['symbols'] as List<dynamic>).map((e) => e as String).toList(),
  url: json['url'] as String,
  source: json['source'] as String,
);

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'headline': instance.headline,
      'author': instance.author,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'summary': instance.summary,
      'content': instance.content,
      'symbols': instance.symbols,
      'url': instance.url,
      'source': instance.source,
    };

SnapshotsResponse _$SnapshotsResponseFromJson(Map<String, dynamic> json) =>
    SnapshotsResponse(
      snapshots: (json['snapshots'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SnapshotData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SnapshotsResponseToJson(SnapshotsResponse instance) =>
    <String, dynamic>{'snapshots': instance.snapshots};

SnapshotData _$SnapshotDataFromJson(Map<String, dynamic> json) => SnapshotData(
  latestTrade: json['latestTrade'] == null
      ? null
      : TradeData.fromJson(json['latestTrade'] as Map<String, dynamic>),
  latestQuote: json['latestQuote'] == null
      ? null
      : QuoteData.fromJson(json['latestQuote'] as Map<String, dynamic>),
  minuteBar: json['minuteBar'] == null
      ? null
      : BarData.fromJson(json['minuteBar'] as Map<String, dynamic>),
  dailyBar: json['dailyBar'] == null
      ? null
      : BarData.fromJson(json['dailyBar'] as Map<String, dynamic>),
  prevDailyBar: json['prevDailyBar'] == null
      ? null
      : BarData.fromJson(json['prevDailyBar'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnapshotDataToJson(SnapshotData instance) =>
    <String, dynamic>{
      'latestTrade': instance.latestTrade,
      'latestQuote': instance.latestQuote,
      'minuteBar': instance.minuteBar,
      'dailyBar': instance.dailyBar,
      'prevDailyBar': instance.prevDailyBar,
    };

AccountResponse _$AccountResponseFromJson(Map<String, dynamic> json) =>
    AccountResponse(
      id: json['id'] as String,
      accountNumber: json['account_number'] as String,
      status: json['status'] as String,
      currency: json['currency'] as String,
      cash: json['cash'] as String,
      portfolioValue: json['portfolio_value'] as String,
      patternDayTrader: json['pattern_day_trader'] as bool,
      tradeSuspendedByUser: json['trade_suspended_by_user'] as bool,
      tradingBlocked: json['trading_blocked'] as bool,
      transfersBlocked: json['transfers_blocked'] as bool,
      accountBlocked: json['account_blocked'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$AccountResponseToJson(AccountResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_number': instance.accountNumber,
      'status': instance.status,
      'currency': instance.currency,
      'cash': instance.cash,
      'portfolio_value': instance.portfolioValue,
      'pattern_day_trader': instance.patternDayTrader,
      'trade_suspended_by_user': instance.tradeSuspendedByUser,
      'trading_blocked': instance.tradingBlocked,
      'transfers_blocked': instance.transfersBlocked,
      'account_blocked': instance.accountBlocked,
      'created_at': instance.createdAt,
    };

AssetResponse _$AssetResponseFromJson(Map<String, dynamic> json) =>
    AssetResponse(
      id: json['id'] as String,
      assetClass: json['class'] as String,
      exchange: json['exchange'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      tradable: json['tradable'] as bool,
      marginable: json['marginable'] as bool,
      shortable: json['shortable'] as bool,
      easyToBorrow: json['easy_to_borrow'] as bool,
      fractionable: json['fractionable'] as bool,
    );

Map<String, dynamic> _$AssetResponseToJson(AssetResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class': instance.assetClass,
      'exchange': instance.exchange,
      'symbol': instance.symbol,
      'name': instance.name,
      'status': instance.status,
      'tradable': instance.tradable,
      'marginable': instance.marginable,
      'shortable': instance.shortable,
      'easy_to_borrow': instance.easyToBorrow,
      'fractionable': instance.fractionable,
    };
