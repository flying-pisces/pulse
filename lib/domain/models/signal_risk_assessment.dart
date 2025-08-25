import 'package:freezed_annotation/freezed_annotation.dart';

part 'signal_risk_assessment.freezed.dart';
part 'signal_risk_assessment.g.dart';

enum RiskLevel {
  @JsonValue('very_low')
  veryLow,
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('very_high')
  veryHigh,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.veryLow:
        return 'Very Low';
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.veryHigh:
        return 'Very High';
    }
  }

  int get numericValue {
    switch (this) {
      case RiskLevel.veryLow:
        return 1;
      case RiskLevel.low:
        return 2;
      case RiskLevel.medium:
        return 3;
      case RiskLevel.high:
        return 4;
      case RiskLevel.veryHigh:
        return 5;
    }
  }

  int get scoreRange {
    switch (this) {
      case RiskLevel.veryLow:
        return 20; // 0-20
      case RiskLevel.low:
        return 40; // 21-40
      case RiskLevel.medium:
        return 60; // 41-60
      case RiskLevel.high:
        return 80; // 61-80
      case RiskLevel.veryHigh:
        return 100; // 81-100
    }
  }
}

@freezed
class SignalRiskAssessment with _$SignalRiskAssessment {
  const factory SignalRiskAssessment({
    required String signalId,
    required int overallRiskScore, // 0-100
    required RiskLevel riskLevel,
    required double riskRewardRatio,
    required StatisticalScenarios scenarios,
    required Map<String, double> riskFactors,
    required List<String> riskWarnings,
    required DateTime assessedAt,
    @Default(false) bool isHighFrequencySignal,
    @Default(false) bool requiresOptionsPermission,
    @Default(false) bool isDayTradingSignal,
  }) = _SignalRiskAssessment;

  factory SignalRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$SignalRiskAssessmentFromJson(json);
}

@freezed
class StatisticalScenarios with _$StatisticalScenarios {
  const factory StatisticalScenarios({
    required ScenarioOutcome bestCase,
    required ScenarioOutcome expectedCase,
    required ScenarioOutcome worstCase,
    required double probabilityOfProfit,
    required double expectedValue,
    required double maximumDrawdown,
    required double sharpeRatio,
  }) = _StatisticalScenarios;

  factory StatisticalScenarios.fromJson(Map<String, dynamic> json) =>
      _$StatisticalScenariosFromJson(json);
}

@freezed
class ScenarioOutcome with _$ScenarioOutcome {
  const factory ScenarioOutcome({
    required double returnPercentage,
    required double probability,
    required int timeToRealizationDays,
    required String description,
  }) = _ScenarioOutcome;

  factory ScenarioOutcome.fromJson(Map<String, dynamic> json) =>
      _$ScenarioOutcomeFromJson(json);
}

class SignalRiskCalculator {
  static SignalRiskAssessment assessSignalRisk({
    required String signalId,
    required String signalType,
    required double currentPrice,
    required double targetPrice,
    required double stopLoss,
    required double confidence,
    required Map<String, dynamic> marketData,
  }) {
    // Calculate individual risk factors
    final riskFactors = _calculateRiskFactors(
      signalType: signalType,
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
      confidence: confidence,
      marketData: marketData,
    );

    // Calculate overall risk score (0-100)
    final overallRiskScore = _calculateOverallRiskScore(riskFactors);
    
    // Determine risk level
    final riskLevel = _determineRiskLevel(overallRiskScore);

    // Calculate risk-reward ratio
    final riskRewardRatio = _calculateRiskRewardRatio(
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
    );

    // Generate statistical scenarios
    final scenarios = _generateStatisticalScenarios(
      signalType: signalType,
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
      confidence: confidence,
      riskScore: overallRiskScore,
    );

    // Generate risk warnings
    final riskWarnings = _generateRiskWarnings(
      signalType: signalType,
      riskScore: overallRiskScore,
      riskFactors: riskFactors,
    );

    return SignalRiskAssessment(
      signalId: signalId,
      overallRiskScore: overallRiskScore,
      riskLevel: riskLevel,
      riskRewardRatio: riskRewardRatio,
      scenarios: scenarios,
      riskFactors: riskFactors,
      riskWarnings: riskWarnings,
      assessedAt: DateTime.now(),
      isHighFrequencySignal: _isHighFrequencySignal(signalType),
      requiresOptionsPermission: _requiresOptionsPermission(signalType),
      isDayTradingSignal: _isDayTradingSignal(signalType),
    );
  }

  static Map<String, double> _calculateRiskFactors({
    required String signalType,
    required double currentPrice,
    required double targetPrice,
    required double stopLoss,
    required double confidence,
    required Map<String, dynamic> marketData,
  }) {
    final factors = <String, double>{};

    // Price volatility risk (0-100)
    factors['volatility'] = _calculateVolatilityRisk(marketData);

    // Position size risk based on price movement potential
    final priceMovementRisk = ((targetPrice - currentPrice).abs() / currentPrice * 100)
        .clamp(0.0, 100.0);
    factors['price_movement'] = priceMovementRisk;

    // Stop loss distance risk
    final stopLossRisk = ((currentPrice - stopLoss).abs() / currentPrice * 100)
        .clamp(0.0, 100.0);
    factors['stop_loss_distance'] = stopLossRisk;

    // Signal type inherent risk
    factors['signal_type'] = _getSignalTypeRisk(signalType);

    // Confidence inverse risk (lower confidence = higher risk)
    factors['confidence'] = (100 - (confidence * 100)).clamp(0.0, 100.0);

    // Market conditions risk
    factors['market_conditions'] = _calculateMarketConditionsRisk(marketData);

    // Liquidity risk
    factors['liquidity'] = _calculateLiquidityRisk(marketData);

    return factors;
  }

  static int _calculateOverallRiskScore(Map<String, double> riskFactors) {
    // Weighted average of risk factors
    final weights = {
      'volatility': 0.20,
      'price_movement': 0.15,
      'stop_loss_distance': 0.15,
      'signal_type': 0.25,
      'confidence': 0.15,
      'market_conditions': 0.05,
      'liquidity': 0.05,
    };

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final entry in riskFactors.entries) {
      final weight = weights[entry.key] ?? 0.0;
      weightedSum += entry.value * weight;
      totalWeight += weight;
    }

    return (weightedSum / totalWeight).round().clamp(0, 100);
  }

  static RiskLevel _determineRiskLevel(int riskScore) {
    if (riskScore <= 20) return RiskLevel.veryLow;
    if (riskScore <= 40) return RiskLevel.low;
    if (riskScore <= 60) return RiskLevel.medium;
    if (riskScore <= 80) return RiskLevel.high;
    return RiskLevel.veryHigh;
  }

  static double _calculateRiskRewardRatio({
    required double currentPrice,
    required double targetPrice,
    required double stopLoss,
  }) {
    final potentialGain = (targetPrice - currentPrice).abs();
    final potentialLoss = (currentPrice - stopLoss).abs();
    
    if (potentialLoss == 0) return double.infinity;
    return potentialGain / potentialLoss;
  }

  static StatisticalScenarios _generateStatisticalScenarios({
    required String signalType,
    required double currentPrice,
    required double targetPrice,
    required double stopLoss,
    required double confidence,
    required int riskScore,
  }) {
    // Calculate return percentages
    final targetReturn = (targetPrice - currentPrice) / currentPrice;
    final stopLossReturn = (stopLoss - currentPrice) / currentPrice;

    // Adjust probabilities based on confidence and risk score
    final baseSuccessProbability = confidence * (100 - riskScore) / 100;
    
    return StatisticalScenarios(
      bestCase: ScenarioOutcome(
        returnPercentage: targetReturn * 1.5, // 50% better than target
        probability: 0.15,
        timeToRealizationDays: _getTimeToRealization(signalType) ~/ 2,
        description: 'Signal significantly outperforms target price',
      ),
      expectedCase: ScenarioOutcome(
        returnPercentage: targetReturn,
        probability: baseSuccessProbability,
        timeToRealizationDays: _getTimeToRealization(signalType),
        description: 'Signal reaches target price as expected',
      ),
      worstCase: ScenarioOutcome(
        returnPercentage: stopLossReturn,
        probability: 1.0 - baseSuccessProbability - 0.15,
        timeToRealizationDays: _getTimeToRealization(signalType) ~/ 3,
        description: 'Signal hits stop loss',
      ),
      probabilityOfProfit: baseSuccessProbability + 0.15,
      expectedValue: _calculateExpectedValue(targetReturn, stopLossReturn, baseSuccessProbability),
      maximumDrawdown: stopLossReturn.abs(),
      sharpeRatio: _calculateSharpeRatio(targetReturn, stopLossReturn, riskScore),
    );
  }

  static double _calculateVolatilityRisk(Map<String, dynamic> marketData) {
    // Simplified volatility calculation - in real implementation would use historical data
    final volume = marketData['volume'] as double? ?? 0.0;
    final avgVolume = marketData['avgVolume'] as double? ?? volume;
    
    if (avgVolume == 0) return 50.0; // Medium risk if no data
    
    final volumeRatio = volume / avgVolume;
    return (volumeRatio * 25).clamp(0.0, 100.0);
  }

  static double _getSignalTypeRisk(String signalType) {
    const signalTypeRisks = {
      '0dte_options': 95.0,
      'earnings': 75.0,
      'momentum': 60.0,
      'breakout': 65.0,
      'swing_trade': 45.0,
      'volume_spike': 55.0,
      'support_bounce': 35.0,
      'dividend_play': 15.0,
      'long_term_trend': 25.0,
    };
    
    return signalTypeRisks[signalType] ?? 50.0;
  }

  static double _calculateMarketConditionsRisk(Map<String, dynamic> marketData) {
    // Simplified market conditions risk - could include VIX, market sentiment, etc.
    return 30.0; // Placeholder
  }

  static double _calculateLiquidityRisk(Map<String, dynamic> marketData) {
    // Simplified liquidity risk based on volume
    final volume = marketData['volume'] as double? ?? 0.0;
    if (volume < 100000) return 70.0; // High risk for low volume
    if (volume < 500000) return 40.0; // Medium risk
    return 20.0; // Low risk for high volume
  }

  static List<String> _generateRiskWarnings({
    required String signalType,
    required int riskScore,
    required Map<String, double> riskFactors,
  }) {
    final warnings = <String>[];

    if (riskScore >= 80) {
      warnings.add('⚠️ Very High Risk: This signal has extreme risk potential');
    }

    if (signalType == '0dte_options') {
      warnings.add('🕐 0DTE Options: Expires same day - extreme time decay risk');
    }

    if (riskFactors['volatility']! >= 70) {
      warnings.add('📈 High Volatility: Significant price swings expected');
    }

    if (riskFactors['stop_loss_distance']! >= 60) {
      warnings.add('🛑 Wide Stop Loss: Large potential loss if signal fails');
    }

    if (riskFactors['liquidity']! >= 60) {
      warnings.add('💧 Low Liquidity: Difficulty entering/exiting position');
    }

    if (riskFactors['confidence']! >= 70) {
      warnings.add('❓ Low Confidence: Signal has lower probability of success');
    }

    return warnings;
  }

  static bool _isHighFrequencySignal(String signalType) {
    return ['0dte_options', 'momentum', 'volume_spike'].contains(signalType);
  }

  static bool _requiresOptionsPermission(String signalType) {
    return signalType.contains('options');
  }

  static bool _isDayTradingSignal(String signalType) {
    return ['0dte_options', 'momentum', 'volume_spike'].contains(signalType);
  }

  static int _getTimeToRealization(String signalType) {
    const timeframes = {
      '0dte_options': 1,
      'momentum': 2,
      'volume_spike': 1,
      'breakout': 5,
      'earnings': 3,
      'swing_trade': 10,
      'support_bounce': 7,
      'dividend_play': 30,
      'long_term_trend': 60,
    };
    
    return timeframes[signalType] ?? 5;
  }

  static double _calculateExpectedValue(
    double targetReturn,
    double stopLossReturn,
    double successProbability,
  ) {
    return (targetReturn * successProbability) + 
           (stopLossReturn * (1.0 - successProbability));
  }

  static double _calculateSharpeRatio(
    double targetReturn,
    double stopLossReturn,
    int riskScore,
  ) {
    final expectedReturn = (targetReturn + stopLossReturn) / 2;
    final riskAdjustment = riskScore / 100.0;
    return expectedReturn / (riskAdjustment + 0.1); // Add small epsilon to avoid division by zero
  }
}