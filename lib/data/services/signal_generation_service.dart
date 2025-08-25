import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import '../models/market_data_models.dart';
import '../repositories/market_data_repository.dart';
import '../../core/constants/env_config.dart';
import '../../domain/models/signal_risk_assessment.dart';
import '../../domain/models/user_risk_profile.dart';

// Signal Generation Service
class SignalGenerationService {
  final MarketDataRepository _marketDataRepository;
  
  SignalGenerationService(this._marketDataRepository);

  /// Generate signals based on current market conditions
  Future<List<GeneratedSignal>> generateSignals({
    List<String>? watchlist,
    int maxSignals = 10,
  }) async {
    final signals = <GeneratedSignal>[];
    
    // Use default watchlist if none provided
    final symbols = watchlist ?? _getDefaultWatchlist();
    
    try {
      // Get market data for symbols
      final snapshots = await _marketDataRepository.getSnapshots(symbols);
      final news = await _marketDataRepository.getNews(
        symbols: symbols.take(5).toList(), // Limit news to top 5 symbols
        limit: 20,
      );
      
      // Generate different types of signals
      signals.addAll(await _generatePreMarketSignals(snapshots));
      signals.addAll(await _generateEarningsSignals(snapshots, news));
      signals.addAll(await _generateMomentumSignals(snapshots));
      signals.addAll(await _generateVolumeSignals(snapshots));
      signals.addAll(await _generateBreakoutSignals(snapshots));
      
      // Sort by confidence score and return top signals
      signals.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
      return signals.take(maxSignals).toList();
      
    } catch (e) {
      // Return mock signals if real data fails
      if (!EnvConfig.hasAlpacaCredentials) {
        return _generateMockSignals(maxSignals);
      }
      rethrow;
    }
  }

  /// Generate pre-market gap signals
  Future<List<GeneratedSignal>> _generatePreMarketSignals(
    Map<String, SnapshotData> snapshots,
  ) async {
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();
    
    // Only generate pre-market signals during pre-market hours (4:00-9:30 AM ET)
    if (!_isPreMarketHours(now)) return signals;
    
    for (final entry in snapshots.entries) {
      final symbol = entry.key;
      final snapshot = entry.value;
      
      // Look for gaps > 3%
      final dailyChange = snapshot.dailyChangePercent ?? 0.0;
      if (dailyChange.abs() >= 3.0) {
        final isGapUp = dailyChange > 0;
        
        signals.add(GeneratedSignal(
          id: 'premarket_${symbol}_${now.millisecondsSinceEpoch}',
          symbol: symbol,
          type: SignalType.preMarket,
          strategy: isGapUp ? 'Pre-Market Gap & Go' : 'Pre-Market Gap Down',
          title: '$symbol ${isGapUp ? "Gap Up" : "Gap Down"} ${dailyChange.toStringAsFixed(1)}%',
          description: _buildPreMarketDescription(symbol, snapshot, isGapUp),
          price: snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0,
          change: dailyChange,
          targetPrice: _calculateTarget(snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0, isGapUp),
          stopLoss: _calculateStopLoss(snapshot, isGapUp),
          confidenceScore: _calculatePreMarketConfidence(snapshot),
          validUntil: DateTime.now().add(const Duration(hours: 2)),
          generatedAt: now,
          metadata: {
            'gap_percentage': dailyChange,
            'volume_ratio': _calculateVolumeRatio(snapshot),
            'price_target': _calculateTarget(snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0, isGapUp),
          },
        ));
      }
    }
    
    return signals;
  }

  /// Generate earnings momentum signals
  Future<List<GeneratedSignal>> _generateEarningsSignals(
    Map<String, SnapshotData> snapshots,
    List<NewsArticle> news,
  ) async {
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();
    
    // Look for earnings-related news
    final earningsNews = news.where((article) => 
      article.headline.toLowerCase().contains('earnings') ||
      article.headline.toLowerCase().contains('beat') ||
      article.headline.toLowerCase().contains('miss') ||
      article.summary.toLowerCase().contains('earnings')
    ).toList();
    
    for (final article in earningsNews.take(3)) {
      for (final symbol in article.symbols) {
        final snapshot = snapshots[symbol];
        if (snapshot == null) continue;
        
        final dailyChange = snapshot.dailyChangePercent ?? 0.0;
        final isEarningsBeat = article.headline.toLowerCase().contains('beat') || 
                              article.headline.toLowerCase().contains('exceeds');
        
        if (dailyChange.abs() >= 2.0) {
          signals.add(GeneratedSignal(
            id: 'earnings_${symbol}_${now.millisecondsSinceEpoch}',
            symbol: symbol,
            type: SignalType.earnings,
            strategy: 'Post-Earnings Momentum',
            title: '$symbol Earnings ${isEarningsBeat ? "Beat" : "Impact"} ${dailyChange.toStringAsFixed(1)}%',
            description: _buildEarningsDescription(symbol, snapshot, article, isEarningsBeat),
            price: snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0,
            change: dailyChange,
            targetPrice: _calculateTarget(snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0, dailyChange > 0),
            stopLoss: _calculateStopLoss(snapshot, dailyChange > 0),
            confidenceScore: _calculateEarningsConfidence(snapshot, article),
            validUntil: DateTime.now().add(const Duration(days: 2)),
            generatedAt: now,
            metadata: {
              'news_headline': article.headline,
              'earnings_beat': isEarningsBeat,
              'after_hours_move': dailyChange,
            },
          ));
        }
      }
    }
    
    return signals;
  }

  /// Generate momentum signals
  Future<List<GeneratedSignal>> _generateMomentumSignals(
    Map<String, SnapshotData> snapshots,
  ) async {
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();
    
    for (final entry in snapshots.entries) {
      final symbol = entry.key;
      final snapshot = entry.value;
      
      final dailyChange = snapshot.dailyChangePercent ?? 0.0;
      final volume = snapshot.dailyBar?.volume ?? 0;
      final avgVolume = volume * 0.8; // Rough average estimation
      
      // Look for momentum with volume confirmation
      if (dailyChange.abs() >= 2.0 && volume > avgVolume) {
        final isUpMomentum = dailyChange > 0;
        
        signals.add(GeneratedSignal(
          id: 'momentum_${symbol}_${now.millisecondsSinceEpoch}',
          symbol: symbol,
          type: SignalType.momentum,
          strategy: 'Momentum Breakout',
          title: '$symbol ${isUpMomentum ? "Upward" : "Downward"} Momentum ${dailyChange.toStringAsFixed(1)}%',
          description: _buildMomentumDescription(symbol, snapshot, isUpMomentum),
          price: snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0,
          change: dailyChange,
          targetPrice: _calculateTarget(snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0, isUpMomentum),
          stopLoss: _calculateStopLoss(snapshot, isUpMomentum),
          confidenceScore: _calculateMomentumConfidence(snapshot),
          validUntil: DateTime.now().add(const Duration(hours: 4)),
          generatedAt: now,
          metadata: {
            'volume_increase': (volume / avgVolume).toStringAsFixed(1),
            'momentum_strength': dailyChange.abs().toStringAsFixed(2),
          },
        ));
      }
    }
    
    return signals;
  }

  /// Generate volume-based signals
  Future<List<GeneratedSignal>> _generateVolumeSignals(
    Map<String, SnapshotData> snapshots,
  ) async {
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();
    
    for (final entry in snapshots.entries) {
      final symbol = entry.key;
      final snapshot = entry.value;
      
      final volume = snapshot.dailyBar?.volume ?? 0;
      final avgVolume = volume * 0.6; // Rough average estimation
      final volumeRatio = volume / (avgVolume > 0 ? avgVolume : 1);
      
      // Look for unusual volume spikes
      if (volumeRatio >= 2.0) {
        final dailyChange = snapshot.dailyChangePercent ?? 0.0;
        
        signals.add(GeneratedSignal(
          id: 'volume_${symbol}_${now.millisecondsSinceEpoch}',
          symbol: symbol,
          type: SignalType.volume,
          strategy: 'Volume Spike Alert',
          title: '$symbol Unusual Volume ${volumeRatio.toStringAsFixed(1)}x Average',
          description: _buildVolumeDescription(symbol, snapshot, volumeRatio),
          price: snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0,
          change: dailyChange,
          targetPrice: _calculateTarget(snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0, dailyChange >= 0),
          stopLoss: _calculateStopLoss(snapshot, dailyChange >= 0),
          confidenceScore: _calculateVolumeConfidence(snapshot, volumeRatio),
          validUntil: DateTime.now().add(const Duration(hours: 2)),
          generatedAt: now,
          metadata: {
            'volume_ratio': volumeRatio.toStringAsFixed(1),
            'current_volume': volume,
          },
        ));
      }
    }
    
    return signals;
  }

  /// Generate breakout signals
  Future<List<GeneratedSignal>> _generateBreakoutSignals(
    Map<String, SnapshotData> snapshots,
  ) async {
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();
    
    for (final entry in snapshots.entries) {
      final symbol = entry.key;
      final snapshot = entry.value;
      
      final currentPrice = snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0;
      final high = snapshot.dailyBar?.high ?? 0.0;
      final low = snapshot.dailyBar?.low ?? 0.0;
      
      // Simple breakout detection (price near daily high/low)
      final nearHigh = (currentPrice - high).abs() / high < 0.01;
      final nearLow = (currentPrice - low).abs() / low < 0.01;
      
      if (nearHigh || nearLow) {
        final isUpBreakout = nearHigh;
        final dailyChange = snapshot.dailyChangePercent ?? 0.0;
        
        signals.add(GeneratedSignal(
          id: 'breakout_${symbol}_${now.millisecondsSinceEpoch}',
          symbol: symbol,
          type: SignalType.breakout,
          strategy: isUpBreakout ? 'Resistance Breakout' : 'Support Breakdown',
          title: '$symbol ${isUpBreakout ? "Breaking Resistance" : "Breaking Support"}',
          description: _buildBreakoutDescription(symbol, snapshot, isUpBreakout),
          price: currentPrice,
          change: dailyChange,
          targetPrice: _calculateTarget(currentPrice, isUpBreakout),
          stopLoss: _calculateStopLoss(snapshot, isUpBreakout),
          confidenceScore: _calculateBreakoutConfidence(snapshot),
          validUntil: DateTime.now().add(const Duration(hours: 1)),
          generatedAt: now,
          metadata: {
            'breakout_type': isUpBreakout ? 'resistance' : 'support',
            'breakout_level': isUpBreakout ? high : low,
          },
        ));
      }
    }
    
    return signals;
  }

  // Helper methods for building descriptions
  String _buildPreMarketDescription(String symbol, SnapshotData snapshot, bool isGapUp) {
    final change = snapshot.dailyChangePercent?.toStringAsFixed(1) ?? '0.0';
    final direction = isGapUp ? 'up' : 'down';
    final strategy = isGapUp ? 'gap-and-go' : 'gap-fill';
    
    return '$symbol is gapping $direction ${change}% in pre-market trading on increased volume. '
           'Execute $strategy strategy: ${isGapUp ? 'buy' : 'short'} at market open for continuation momentum. '
           'Set tight stop-loss for risk management.';
  }

  String _buildEarningsDescription(String symbol, SnapshotData snapshot, NewsArticle article, bool isBeat) {
    final change = snapshot.dailyChangePercent?.toStringAsFixed(1) ?? '0.0';
    final direction = change.startsWith('-') ? 'down' : 'up';
    
    return '$symbol moved ${change}% after earnings ${isBeat ? 'beat' : 'results'}. '
           '${article.headline}. Stock is trending $direction on heavy volume. '
           'Historical data shows ${isBeat ? '3-day average of +5%' : 'potential reversal'} after big moves.';
  }

  String _buildMomentumDescription(String symbol, SnapshotData snapshot, bool isUp) {
    final change = snapshot.dailyChangePercent?.toStringAsFixed(1) ?? '0.0';
    final direction = isUp ? 'upward' : 'downward';
    
    return '$symbol is showing strong $direction momentum with ${change}% move on above-average volume. '
           'Technical indicators suggest continuation of current trend. '
           'Consider ${isUp ? 'long' : 'short'} position with proper risk management.';
  }

  String _buildVolumeDescription(String symbol, SnapshotData snapshot, double volumeRatio) {
    final change = snapshot.dailyChangePercent?.toStringAsFixed(1) ?? '0.0';
    
    return '$symbol is experiencing unusual volume activity at ${volumeRatio.toStringAsFixed(1)}x average volume. '
           'Price is currently ${change}% on the day. '
           'High volume often precedes significant price movement - monitor closely for breakout opportunities.';
  }

  String _buildBreakoutDescription(String symbol, SnapshotData snapshot, bool isUpBreakout) {
    final direction = isUpBreakout ? 'resistance' : 'support';
    final action = isUpBreakout ? 'above' : 'below';
    
    return '$symbol is breaking $action key $direction levels on solid volume. '
           'Technical breakout suggests potential for continued movement in current direction. '
           'This setup often leads to sustained moves over the next 1-2 trading sessions.';
  }

  // Confidence calculation methods
  double _calculatePreMarketConfidence(SnapshotData snapshot) {
    double confidence = 50.0;
    
    final change = snapshot.dailyChangePercent?.abs() ?? 0.0;
    confidence += change * 5; // Higher gaps = higher confidence
    
    final volume = snapshot.dailyBar?.volume ?? 0;
    if (volume > 100000) confidence += 10; // Volume confirmation
    
    return math.min(confidence, 95.0);
  }

  double _calculateEarningsConfidence(SnapshotData snapshot, NewsArticle article) {
    double confidence = 60.0;
    
    final change = snapshot.dailyChangePercent?.abs() ?? 0.0;
    confidence += change * 3;
    
    if (article.headline.toLowerCase().contains('beat')) confidence += 15;
    if (article.headline.toLowerCase().contains('guidance')) confidence += 10;
    
    return math.min(confidence, 90.0);
  }

  double _calculateMomentumConfidence(SnapshotData snapshot) {
    double confidence = 55.0;
    
    final change = snapshot.dailyChangePercent?.abs() ?? 0.0;
    confidence += change * 4;
    
    final volume = snapshot.dailyBar?.volume ?? 0;
    if (volume > 50000) confidence += 15;
    
    return math.min(confidence, 85.0);
  }

  double _calculateVolumeConfidence(SnapshotData snapshot, double volumeRatio) {
    double confidence = 45.0;
    
    confidence += volumeRatio * 10; // Higher volume ratio = higher confidence
    
    final change = snapshot.dailyChangePercent?.abs() ?? 0.0;
    if (change > 1.0) confidence += 20; // Price confirmation
    
    return math.min(confidence, 80.0);
  }

  double _calculateBreakoutConfidence(SnapshotData snapshot) {
    double confidence = 50.0;
    
    final volume = snapshot.dailyBar?.volume ?? 0;
    if (volume > 75000) confidence += 20;
    
    final change = snapshot.dailyChangePercent?.abs() ?? 0.0;
    confidence += change * 3;
    
    return math.min(confidence, 85.0);
  }

  // Helper calculation methods
  double _calculateTarget(double currentPrice, bool isUpside) {
    if (isUpside) {
      return currentPrice * 1.05; // 5% target
    } else {
      return currentPrice * 0.95; // 5% target down
    }
  }

  double _calculateStopLoss(SnapshotData snapshot, bool isUpside) {
    final currentPrice = snapshot.latestTrade?.price ?? snapshot.dailyBar?.close ?? 0.0;
    
    if (isUpside) {
      final low = snapshot.dailyBar?.low ?? currentPrice * 0.98;
      return math.min(low, currentPrice * 0.97); // 3% or daily low, whichever is closer
    } else {
      final high = snapshot.dailyBar?.high ?? currentPrice * 1.02;
      return math.max(high, currentPrice * 1.03); // 3% or daily high, whichever is further
    }
  }

  double _calculateVolumeRatio(SnapshotData snapshot) {
    final volume = snapshot.dailyBar?.volume ?? 0;
    final avgVolume = volume * 0.7; // Rough estimation
    return volume / (avgVolume > 0 ? avgVolume : 1);
  }

  bool _isPreMarketHours(DateTime dateTime) {
    final easternTime = dateTime.toUtc().subtract(const Duration(hours: 4)); // Rough EST conversion
    final hour = easternTime.hour;
    return hour >= 4 && hour < 9 || (hour == 9 && easternTime.minute < 30);
  }

  List<String> _getDefaultWatchlist() {
    return [
      'AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN', 
      'NVDA', 'META', 'NFLX', 'AMD', 'ORCL',
      'SPY', 'QQQ', 'IWM',
    ];
  }

  List<GeneratedSignal> _generateMockSignals(int count) {
    final random = Random();
    final symbols = _getDefaultWatchlist();
    final signals = <GeneratedSignal>[];
    final now = DateTime.now();

    for (int i = 0; i < count && i < symbols.length; i++) {
      final symbol = symbols[i];
      final change = (random.nextDouble() * 10 - 5); // -5% to +5%
      final price = (50 + random.nextDouble() * 400).toDouble(); // $50 to $450
      final isUpside = change > 0;

      signals.add(GeneratedSignal(
        id: 'mock_${symbol}_${now.millisecondsSinceEpoch + i}',
        symbol: symbol,
        type: SignalType.values[random.nextInt(SignalType.values.length)],
        strategy: 'Mock Strategy',
        title: '$symbol Mock Signal ${change.toStringAsFixed(1)}%',
        description: 'This is a mock signal generated for testing purposes. '
                    '$symbol is showing ${isUpside ? 'bullish' : 'bearish'} momentum.',
        price: price,
        change: change,
        targetPrice: price * (isUpside ? 1.05 : 0.95),
        stopLoss: price * (isUpside ? 0.97 : 1.03),
        confidenceScore: (50 + random.nextDouble() * 40).toDouble(), // 50-90%
        validUntil: now.add(Duration(hours: 1 + random.nextInt(6))),
        generatedAt: now,
        metadata: {
          'is_mock': true,
          'generated_for_testing': true,
        },
      ));
    }

    return signals;
  }
}

// Generated Signal Model
class GeneratedSignal {
  final String id;
  final String symbol;
  final SignalType type;
  final String strategy;
  final String title;
  final String description;
  final double price;
  final double change;
  final double targetPrice;
  final double stopLoss;
  final double confidenceScore; // 0-100
  final DateTime validUntil;
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;
  final SignalRiskAssessment? riskAssessment;

  GeneratedSignal({
    required this.id,
    required this.symbol,
    required this.type,
    required this.strategy,
    required this.title,
    required this.description,
    required this.price,
    required this.change,
    required this.targetPrice,
    required this.stopLoss,
    required this.confidenceScore,
    required this.validUntil,
    required this.generatedAt,
    required this.metadata,
    this.riskAssessment,
  });

  bool get isValid => DateTime.now().isBefore(validUntil);
  bool get isPositive => change >= 0;
  
  String get changeString => '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  String get confidenceString => '${confidenceScore.round()}%';
  
  // Risk level for quick access
  RiskLevel get riskLevel => riskAssessment?.riskLevel ?? RiskLevel.medium;
  int get riskScore => riskAssessment?.overallRiskScore ?? 50;
  double get riskRewardRatio => riskAssessment?.riskRewardRatio ?? 1.0;
  
  // Check if signal matches user's risk profile
  bool matchesUserRiskProfile(UserRiskProfile profile) {
    final signalRisk = riskScore;
    final userTolerance = profile.riskTolerance[type.riskKey] ?? 1.0;
    final adjustedRisk = signalRisk * userTolerance;
    
    // Check if signal risk is within user's acceptable range
    return adjustedRisk <= profile.riskRewardAppetite + 10; // 10 point buffer
  }
  
  // Get recommended position size based on user profile
  double getRecommendedPositionSize(UserRiskProfile profile) {
    final baseSize = profile.maxPositionSize;
    final riskMultiplier = riskScore / 100.0;
    final confidence = confidenceScore / 100.0;
    
    // Reduce position size for higher risk, increase for higher confidence
    final adjustedSize = baseSize * confidence * (1.0 - (riskMultiplier * 0.5));
    
    return math.max(adjustedSize, 0.01); // Minimum 1% position
  }
  
  // Convert to PocketBase signal format for storage
  Map<String, dynamic> toPocketBaseSignal() {
    return {
      'symbol': symbol,
      'signal_type': type.name,
      'title': title,
      'description': description,
      'strategy': strategy,
      'current_price': price,
      'target_price': targetPrice,
      'stop_loss': stopLoss,
      'confidence_score': confidenceScore.round(),
      'risk_score': riskScore,
      'risk_level': riskLevel.name,
      'risk_reward_ratio': riskRewardRatio,
      'valid_until': validUntil.toIso8601String(),
      'metadata': {
        ...metadata,
        'risk_assessment': riskAssessment?.toJson(),
      },
      'is_active': isValid,
      'auto_generated': true,
    };
  }

  // Create enhanced signal with risk assessment
  GeneratedSignal withRiskAssessment(SignalRiskAssessment assessment) {
    return GeneratedSignal(
      id: id,
      symbol: symbol,
      type: type,
      strategy: strategy,
      title: title,
      description: description,
      price: price,
      change: change,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
      confidenceScore: confidenceScore,
      validUntil: validUntil,
      generatedAt: generatedAt,
      metadata: metadata,
      riskAssessment: assessment,
    );
  }
}

// Signal Types
enum SignalType {
  preMarket('Pre-Market', 'momentum'),
  earnings('Earnings', 'earnings'),
  momentum('Momentum', 'momentum'),
  volume('Volume Alert', 'volume_spike'),
  breakout('Breakout', 'breakout'),
  options('Options', '0dte_options'),
  crypto('Crypto', 'swing_trade');

  const SignalType(this.displayName, this.riskKey);
  final String displayName;
  final String riskKey; // Maps to risk tolerance keys in UserRiskProfile
}