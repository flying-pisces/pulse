import 'dart:async';
import '../models/market_data_models.dart';
import '../repositories/market_data_repository.dart';
import 'signal_generation_service.dart';
import '../../core/constants/env_config.dart';

/// Dynamic Signal Service for premium per-signal features
class DynamicSignalService {
  final MarketDataRepository _marketDataRepository;
  final SignalGenerationService _signalGenerationService;
  
  // Real-time monitoring streams
  final Map<String, StreamController<DynamicSignalUpdate>> _signalStreams = {};
  final Map<String, Timer> _monitoringTimers = {};

  DynamicSignalService(
    this._marketDataRepository,
    this._signalGenerationService,
  );

  /// Upgrade a signal to dynamic premium ($4.99)
  Future<DynamicSignal> upgradeSignal(
    GeneratedSignal baseSignal,
    String userId,
  ) async {
    // In a real app, this would process payment first
    await _processPayment(userId, 4.99);

    // Create dynamic signal with enhanced features
    final dynamicSignal = DynamicSignal(
      id: 'dyn_${baseSignal.id}',
      baseSignal: baseSignal,
      userId: userId,
      upgradeTimestamp: DateTime.now(),
      features: const DynamicSignalFeatures(
        realTimeAlerts: true,
        advancedAnalysis: true,
        riskManagement: true,
        continousMonitoring: true,
        exitStrategy: true,
        supportResistance: true,
        volumeAnalysis: true,
        newsIntegration: true,
      ),
      status: DynamicSignalStatus.active,
    );

    // Start real-time monitoring
    await _startRealTimeMonitoring(dynamicSignal);

    // Generate initial advanced analysis
    await _generateAdvancedAnalysis(dynamicSignal);

    return dynamicSignal;
  }

  /// Start real-time monitoring for a dynamic signal
  Future<void> _startRealTimeMonitoring(DynamicSignal signal) async {
    // Create stream for this signal
    final streamController = StreamController<DynamicSignalUpdate>.broadcast();
    _signalStreams[signal.id] = streamController;

    // Start monitoring timer (every 30 seconds)
    final timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        await _checkSignalStatus(signal);
      } catch (e) {
        // Log error but continue monitoring
        print('Error monitoring signal ${signal.id}: $e');
      }
    });
    
    _monitoringTimers[signal.id] = timer;
  }

  /// Check signal status and send updates
  Future<void> _checkSignalStatus(DynamicSignal signal) async {
    try {
      // Get current market data
      final snapshot = await _marketDataRepository.getSnapshots([signal.baseSignal.symbol]);
      final currentData = snapshot[signal.baseSignal.symbol];
      
      if (currentData == null) return;

      final currentPrice = currentData.latestTrade?.price ?? 
                          currentData.dailyBar?.close ?? 
                          signal.baseSignal.price;

      // Check for significant price movements
      final priceChangeFromSignal = (currentPrice - signal.baseSignal.price) / signal.baseSignal.price;
      
      // Generate updates based on price action
      final updates = <DynamicSignalUpdate>[];

      // Target reached
      if (_isTargetReached(signal, currentPrice)) {
        updates.add(DynamicSignalUpdate(
          signalId: signal.id,
          type: UpdateType.targetReached,
          timestamp: DateTime.now(),
          title: '🎯 Target Reached - ${signal.baseSignal.symbol}',
          message: 'Price has reached your target of \$${signal.baseSignal.targetPrice.toStringAsFixed(2)}. '
                  'Current price: \$${currentPrice.toStringAsFixed(2)}',
          priority: UpdatePriority.high,
          actionable: true,
          data: {
            'current_price': currentPrice,
            'target_price': signal.baseSignal.targetPrice,
            'profit_percentage': ((currentPrice - signal.baseSignal.price) / signal.baseSignal.price * 100),
          },
        ));
      }

      // Stop loss triggered
      if (_isStopLossTriggered(signal, currentPrice)) {
        updates.add(DynamicSignalUpdate(
          signalId: signal.id,
          type: UpdateType.stopLossTriggered,
          timestamp: DateTime.now(),
          title: '🛑 Stop Loss Triggered - ${signal.baseSignal.symbol}',
          message: 'Price has hit your stop loss at \$${signal.baseSignal.stopLoss.toStringAsFixed(2)}. '
                  'Consider exiting position. Current price: \$${currentPrice.toStringAsFixed(2)}',
          priority: UpdatePriority.critical,
          actionable: true,
          data: {
            'current_price': currentPrice,
            'stop_loss': signal.baseSignal.stopLoss,
            'loss_percentage': ((currentPrice - signal.baseSignal.price) / signal.baseSignal.price * 100),
          },
        ));
      }

      // Significant price movement
      if (priceChangeFromSignal.abs() > 0.02) { // 2% movement
        final direction = priceChangeFromSignal > 0 ? 'up' : 'down';
        updates.add(DynamicSignalUpdate(
          signalId: signal.id,
          type: UpdateType.priceMovement,
          timestamp: DateTime.now(),
          title: '📈 Significant Move - ${signal.baseSignal.symbol}',
          message: 'Price moved ${direction} ${(priceChangeFromSignal * 100).toStringAsFixed(1)}% '
                  'since signal generation. Monitor closely for next move.',
          priority: UpdatePriority.medium,
          actionable: false,
          data: {
            'current_price': currentPrice,
            'signal_price': signal.baseSignal.price,
            'movement_percentage': priceChangeFromSignal * 100,
          },
        ));
      }

      // Volume spike
      final currentVolume = currentData.dailyBar?.volume ?? 0;
      if (_hasVolumeSpiked(signal, currentVolume)) {
        updates.add(DynamicSignalUpdate(
          signalId: signal.id,
          type: UpdateType.volumeSpike,
          timestamp: DateTime.now(),
          title: '🔊 Volume Alert - ${signal.baseSignal.symbol}',
          message: 'Unusual volume detected. This could indicate increased interest and potential price movement.',
          priority: UpdatePriority.medium,
          actionable: false,
          data: {
            'current_volume': currentVolume,
            'average_volume': currentVolume * 0.7, // Rough estimate
          },
        ));
      }

      // Send updates to stream
      for (final update in updates) {
        _signalStreams[signal.id]?.add(update);
      }

      // Check if signal should be closed
      if (_shouldCloseSignal(signal, currentPrice)) {
        await _closeSignal(signal);
      }

    } catch (e) {
      print('Error checking signal status: $e');
    }
  }

  /// Generate advanced technical analysis for dynamic signal
  Future<AdvancedAnalysis> _generateAdvancedAnalysis(DynamicSignal signal) async {
    try {
      // Get historical data for analysis
      final historicalBars = await _marketDataRepository.getHistoricalBars(
        symbol: signal.baseSignal.symbol,
        timeframe: '1Day',
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
        limit: 30,
      );

      // Get recent news
      final news = await _marketDataRepository.getNews(
        symbols: [signal.baseSignal.symbol],
        limit: 5,
      );

      // Calculate technical indicators
      final analysis = AdvancedAnalysis(
        signalId: signal.id,
        symbol: signal.baseSignal.symbol,
        generatedAt: DateTime.now(),
        
        // Technical indicators
        rsi: _calculateRSI(historicalBars),
        macd: _calculateMACD(historicalBars),
        bollinger: _calculateBollingerBands(historicalBars),
        supportLevels: _findSupportLevels(historicalBars),
        resistanceLevels: _findResistanceLevels(historicalBars),
        
        // Volume analysis
        volumeAnalysis: VolumeAnalysis(
          averageVolume: MarketDataUtils.calculateAverageVolume(historicalBars),
          volumeTrend: _analyzeVolumeTrend(historicalBars),
          volumeBreakouts: _findVolumeBreakouts(historicalBars),
        ),
        
        // Risk assessment
        riskAssessment: RiskAssessment(
          volatility: MarketDataUtils.calculateVolatility(historicalBars),
          downside: _calculateDownsideRisk(historicalBars, signal.baseSignal.price),
          maxDrawdown: _calculateMaxDrawdown(historicalBars),
          sharpeRatio: _estimateSharpeRatio(historicalBars),
        ),
        
        // News sentiment
        newsSentiment: _analyzeNewsSentiment(news),
        
        // Price targets and exit strategy
        exitStrategy: ExitStrategy(
          targets: [
            ExitTarget(price: signal.baseSignal.targetPrice, probability: 0.65, timeframe: '1-3 days'),
            ExitTarget(price: signal.baseSignal.targetPrice * 1.05, probability: 0.35, timeframe: '3-5 days'),
          ],
          stopLoss: ExitTarget(price: signal.baseSignal.stopLoss, probability: 0.20, timeframe: 'immediate'),
          trailingStop: signal.baseSignal.targetPrice * 0.95,
        ),
      );

      return analysis;

    } catch (e) {
      print('Error generating advanced analysis: $e');
      return AdvancedAnalysis.empty(signal.id, signal.baseSignal.symbol);
    }
  }

  /// Get real-time updates stream for a signal
  Stream<DynamicSignalUpdate>? getSignalUpdates(String signalId) {
    return _signalStreams[signalId]?.stream;
  }

  /// Stop monitoring a dynamic signal
  Future<void> stopMonitoring(String signalId) async {
    _monitoringTimers[signalId]?.cancel();
    _monitoringTimers.remove(signalId);
    
    await _signalStreams[signalId]?.close();
    _signalStreams.remove(signalId);
  }

  /// Close a signal (when target reached or expired)
  Future<void> _closeSignal(DynamicSignal signal) async {
    await stopMonitoring(signal.id);
    
    // Send final update
    _signalStreams[signal.id]?.add(DynamicSignalUpdate(
      signalId: signal.id,
      type: UpdateType.signalClosed,
      timestamp: DateTime.now(),
      title: '✅ Signal Closed - ${signal.baseSignal.symbol}',
      message: 'Signal has been automatically closed. Thank you for using Dynamic Premium!',
      priority: UpdatePriority.low,
      actionable: false,
      data: {'close_reason': 'auto_close'},
    ));
  }

  // Helper methods for signal analysis
  bool _isTargetReached(DynamicSignal signal, double currentPrice) {
    if (signal.baseSignal.isPositive) {
      return currentPrice >= signal.baseSignal.targetPrice;
    } else {
      return currentPrice <= signal.baseSignal.targetPrice;
    }
  }

  bool _isStopLossTriggered(DynamicSignal signal, double currentPrice) {
    if (signal.baseSignal.isPositive) {
      return currentPrice <= signal.baseSignal.stopLoss;
    } else {
      return currentPrice >= signal.baseSignal.stopLoss;
    }
  }

  bool _hasVolumeSpiked(DynamicSignal signal, int currentVolume) {
    // Simple volume spike detection - 2x normal volume
    final normalVolume = currentVolume * 0.6; // Rough estimate
    return currentVolume > normalVolume * 2;
  }

  bool _shouldCloseSignal(DynamicSignal signal, double currentPrice) {
    // Close if signal expired or target/stop reached
    return DateTime.now().isAfter(signal.baseSignal.validUntil) ||
           _isTargetReached(signal, currentPrice) ||
           _isStopLossTriggered(signal, currentPrice);
  }

  // Payment processing (mock)
  Future<void> _processPayment(String userId, double amount) async {
    // Mock payment processing
    await Future.delayed(const Duration(seconds: 1));
    print('Payment processed: \$${amount.toStringAsFixed(2)} for user $userId');
  }

  // Technical analysis calculations (simplified implementations)
  double _calculateRSI(List<BarData> bars) {
    if (bars.length < 14) return 50.0;
    
    double gains = 0, losses = 0;
    for (int i = 1; i < 14; i++) {
      final change = bars[i].close - bars[i - 1].close;
      if (change > 0) gains += change;
      else losses -= change;
    }
    
    final rs = (gains / 13) / (losses / 13);
    return 100 - (100 / (1 + rs));
  }

  Map<String, double> _calculateMACD(List<BarData> bars) {
    // Simplified MACD calculation
    return {
      'macd': 0.5,
      'signal': 0.3,
      'histogram': 0.2,
    };
  }

  Map<String, double> _calculateBollingerBands(List<BarData> bars) {
    if (bars.isEmpty) return {'upper': 0, 'middle': 0, 'lower': 0};
    
    final closes = bars.map((b) => b.close).toList();
    final sma = closes.reduce((a, b) => a + b) / closes.length;
    final variance = closes.map((c) => (c - sma) * (c - sma)).reduce((a, b) => a + b) / closes.length;
    final stdDev = variance > 0 ? variance.abs().sqrt() : 0.0;
    
    return {
      'upper': sma + (stdDev * 2),
      'middle': sma,
      'lower': sma - (stdDev * 2),
    };
  }

  List<double> _findSupportLevels(List<BarData> bars) {
    if (bars.length < 10) return [];
    
    final lows = bars.map((b) => b.low).toList()..sort();
    return lows.take(3).toList();
  }

  List<double> _findResistanceLevels(List<BarData> bars) {
    if (bars.length < 10) return [];
    
    final highs = bars.map((b) => b.high).toList()..sort((a, b) => b.compareTo(a));
    return highs.take(3).toList();
  }

  String _analyzeVolumeTrend(List<BarData> bars) {
    if (bars.length < 5) return 'insufficient_data';
    
    final recentVolume = bars.skip(bars.length - 5).map((b) => b.volume).reduce((a, b) => a + b) / 5;
    final olderVolume = bars.take(bars.length - 5).map((b) => b.volume).reduce((a, b) => a + b) / (bars.length - 5);
    
    if (recentVolume > olderVolume * 1.2) return 'increasing';
    if (recentVolume < olderVolume * 0.8) return 'decreasing';
    return 'stable';
  }

  List<DateTime> _findVolumeBreakouts(List<BarData> bars) {
    final breakouts = <DateTime>[];
    if (bars.length < 10) return breakouts;
    
    final avgVolume = MarketDataUtils.calculateAverageVolume(bars);
    for (final bar in bars) {
      if (bar.volume > avgVolume * 2) {
        breakouts.add(bar.dateTime);
      }
    }
    
    return breakouts;
  }

  double _calculateDownsideRisk(List<BarData> bars, double currentPrice) {
    if (bars.isEmpty) return 0.1; // 10% default
    
    final minPrice = bars.map((b) => b.low).reduce((a, b) => a < b ? a : b);
    return (currentPrice - minPrice) / currentPrice;
  }

  double _calculateMaxDrawdown(List<BarData> bars) {
    if (bars.length < 2) return 0.0;
    
    double maxDrawdown = 0.0;
    double peak = bars[0].high;
    
    for (final bar in bars.skip(1)) {
      if (bar.high > peak) peak = bar.high;
      final drawdown = (peak - bar.low) / peak;
      if (drawdown > maxDrawdown) maxDrawdown = drawdown;
    }
    
    return maxDrawdown;
  }

  double _estimateSharpeRatio(List<BarData> bars) {
    // Simplified Sharpe ratio calculation
    if (bars.length < 2) return 0.0;
    
    final returns = <double>[];
    for (int i = 1; i < bars.length; i++) {
      returns.add((bars[i].close - bars[i - 1].close) / bars[i - 1].close);
    }
    
    if (returns.isEmpty) return 0.0;
    
    final avgReturn = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => (r - avgReturn) * (r - avgReturn)).reduce((a, b) => a + b) / returns.length;
    final stdDev = variance > 0 ? variance.abs().sqrt() : 0.01;
    
    return avgReturn / stdDev;
  }

  double _analyzeNewsSentiment(List<NewsArticle> news) {
    // Simple sentiment analysis based on keywords
    if (news.isEmpty) return 0.0;
    
    double sentiment = 0.0;
    final positiveWords = ['beat', 'exceeds', 'growth', 'strong', 'positive', 'upgrade'];
    final negativeWords = ['miss', 'weak', 'decline', 'downgrade', 'loss', 'negative'];
    
    for (final article in news) {
      final text = '${article.headline} ${article.summary}'.toLowerCase();
      
      for (final word in positiveWords) {
        if (text.contains(word)) sentiment += 0.1;
      }
      
      for (final word in negativeWords) {
        if (text.contains(word)) sentiment -= 0.1;
      }
    }
    
    return sentiment.clamp(-1.0, 1.0);
  }

  // Cleanup when service is disposed
  void dispose() {
    for (final timer in _monitoringTimers.values) {
      timer.cancel();
    }
    for (final stream in _signalStreams.values) {
      stream.close();
    }
    _monitoringTimers.clear();
    _signalStreams.clear();
  }
}

// Dynamic Signal Models
class DynamicSignal {
  final String id;
  final GeneratedSignal baseSignal;
  final String userId;
  final DateTime upgradeTimestamp;
  final DynamicSignalFeatures features;
  final DynamicSignalStatus status;

  DynamicSignal({
    required this.id,
    required this.baseSignal,
    required this.userId,
    required this.upgradeTimestamp,
    required this.features,
    required this.status,
  });
}

class DynamicSignalFeatures {
  final bool realTimeAlerts;
  final bool advancedAnalysis;
  final bool riskManagement;
  final bool continousMonitoring;
  final bool exitStrategy;
  final bool supportResistance;
  final bool volumeAnalysis;
  final bool newsIntegration;

  const DynamicSignalFeatures({
    required this.realTimeAlerts,
    required this.advancedAnalysis,
    required this.riskManagement,
    required this.continousMonitoring,
    required this.exitStrategy,
    required this.supportResistance,
    required this.volumeAnalysis,
    required this.newsIntegration,
  });
}

enum DynamicSignalStatus { active, paused, closed }

class DynamicSignalUpdate {
  final String signalId;
  final UpdateType type;
  final DateTime timestamp;
  final String title;
  final String message;
  final UpdatePriority priority;
  final bool actionable;
  final Map<String, dynamic> data;

  DynamicSignalUpdate({
    required this.signalId,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.message,
    required this.priority,
    required this.actionable,
    required this.data,
  });
}

enum UpdateType {
  targetReached,
  stopLossTriggered,
  priceMovement,
  volumeSpike,
  newsAlert,
  riskWarning,
  signalClosed,
}

enum UpdatePriority { low, medium, high, critical }

// Advanced Analysis Models
class AdvancedAnalysis {
  final String signalId;
  final String symbol;
  final DateTime generatedAt;
  final double rsi;
  final Map<String, double> macd;
  final Map<String, double> bollinger;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final VolumeAnalysis volumeAnalysis;
  final RiskAssessment riskAssessment;
  final double newsSentiment;
  final ExitStrategy exitStrategy;

  AdvancedAnalysis({
    required this.signalId,
    required this.symbol,
    required this.generatedAt,
    required this.rsi,
    required this.macd,
    required this.bollinger,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.volumeAnalysis,
    required this.riskAssessment,
    required this.newsSentiment,
    required this.exitStrategy,
  });

  factory AdvancedAnalysis.empty(String signalId, String symbol) {
    return AdvancedAnalysis(
      signalId: signalId,
      symbol: symbol,
      generatedAt: DateTime.now(),
      rsi: 50.0,
      macd: {'macd': 0, 'signal': 0, 'histogram': 0},
      bollinger: {'upper': 0, 'middle': 0, 'lower': 0},
      supportLevels: [],
      resistanceLevels: [],
      volumeAnalysis: VolumeAnalysis.empty(),
      riskAssessment: RiskAssessment.empty(),
      newsSentiment: 0.0,
      exitStrategy: ExitStrategy.empty(),
    );
  }
}

class VolumeAnalysis {
  final double averageVolume;
  final String volumeTrend;
  final List<DateTime> volumeBreakouts;

  VolumeAnalysis({
    required this.averageVolume,
    required this.volumeTrend,
    required this.volumeBreakouts,
  });

  factory VolumeAnalysis.empty() {
    return VolumeAnalysis(
      averageVolume: 0,
      volumeTrend: 'unknown',
      volumeBreakouts: [],
    );
  }
}

class RiskAssessment {
  final double volatility;
  final double downside;
  final double maxDrawdown;
  final double sharpeRatio;

  RiskAssessment({
    required this.volatility,
    required this.downside,
    required this.maxDrawdown,
    required this.sharpeRatio,
  });

  factory RiskAssessment.empty() {
    return RiskAssessment(
      volatility: 0,
      downside: 0,
      maxDrawdown: 0,
      sharpeRatio: 0,
    );
  }
}

class ExitStrategy {
  final List<ExitTarget> targets;
  final ExitTarget stopLoss;
  final double trailingStop;

  ExitStrategy({
    required this.targets,
    required this.stopLoss,
    required this.trailingStop,
  });

  factory ExitStrategy.empty() {
    return ExitStrategy(
      targets: [],
      stopLoss: ExitTarget.empty(),
      trailingStop: 0,
    );
  }
}

class ExitTarget {
  final double price;
  final double probability;
  final String timeframe;

  ExitTarget({
    required this.price,
    required this.probability,
    required this.timeframe,
  });

  factory ExitTarget.empty() {
    return ExitTarget(price: 0, probability: 0, timeframe: '');
  }
}