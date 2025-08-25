import 'dart:async';
import 'signal_generation_service.dart';
import '../../domain/models/signal_risk_assessment.dart';
import '../../domain/models/user_risk_profile.dart';

/// Enhanced signal service that integrates risk assessment with signal generation
class EnhancedSignalService {
  final SignalGenerationService _signalService;
  
  EnhancedSignalService(this._signalService);
  
  /// Generate signals with risk assessment and user filtering
  Future<List<GeneratedSignal>> generateRiskAssessedSignals({
    List<String>? watchlist,
    int maxSignals = 10,
    UserRiskProfile? userProfile,
    bool filterByRisk = true,
  }) async {
    // Get base signals
    final signals = await _signalService.generateSignals(
      watchlist: watchlist,
      maxSignals: maxSignals * 2, // Generate more to filter by risk
    );
    
    // Enhance signals with risk assessment
    final enhancedSignals = <GeneratedSignal>[];
    
    for (final signal in signals) {
      final riskAssessment = await _generateRiskAssessment(signal);
      final enhancedSignal = signal.withRiskAssessment(riskAssessment);
      
      // Filter by user risk profile if provided
      if (userProfile != null && filterByRisk) {
        if (enhancedSignal.matchesUserRiskProfile(userProfile)) {
          enhancedSignals.add(enhancedSignal);
        }
      } else {
        enhancedSignals.add(enhancedSignal);
      }
    }
    
    // Sort by risk-adjusted score
    enhancedSignals.sort((a, b) => _calculateRiskAdjustedScore(b, userProfile)
        .compareTo(_calculateRiskAdjustedScore(a, userProfile)));
    
    return enhancedSignals.take(maxSignals).toList();
  }
  
  /// Generate comprehensive risk assessment for a signal
  Future<SignalRiskAssessment> _generateRiskAssessment(GeneratedSignal signal) async {
    // Create market data map from signal metadata
    final marketData = <String, dynamic>{
      'volume': signal.metadata['current_volume'] ?? 100000,
      'avgVolume': signal.metadata['avg_volume'] ?? 80000,
      'volatility': signal.metadata['volatility'] ?? 30.0,
      'price_change': signal.change,
    };
    
    return SignalRiskCalculator.assessSignalRisk(
      signalId: signal.id,
      signalType: signal.type.riskKey,
      currentPrice: signal.price,
      targetPrice: signal.targetPrice,
      stopLoss: signal.stopLoss,
      confidence: signal.confidenceScore / 100.0,
      marketData: marketData,
    );
  }
  
  /// Calculate risk-adjusted score for ranking signals
  double _calculateRiskAdjustedScore(GeneratedSignal signal, UserRiskProfile? userProfile) {
    double score = signal.confidenceScore;
    
    if (userProfile != null) {
      // Adjust score based on user's risk tolerance for this signal type
      final riskTolerance = userProfile.riskTolerance[signal.type.riskKey] ?? 1.0;
      final riskAdjustment = (signal.riskScore * riskTolerance) / 100.0;
      
      // Higher risk tolerance = less penalty for risky signals
      score *= (1.0 + (riskTolerance - 1.0) * 0.5);
      
      // Penalize signals that exceed user's risk appetite
      if (signal.riskScore > userProfile.riskRewardAppetite) {
        final penalty = (signal.riskScore - userProfile.riskRewardAppetite) / 100.0;
        score *= (1.0 - penalty * 0.5);
      }
      
      // Bonus for signals with good risk-reward ratio
      if (signal.riskRewardRatio > 2.0) {
        score *= 1.1; // 10% bonus for good risk-reward
      }
    }
    
    return score;
  }
  
  /// Get personalized signals for a specific user
  Future<PersonalizedSignalResponse> getPersonalizedSignals({
    required UserRiskProfile userProfile,
    List<String>? watchlist,
    int maxSignals = 10,
  }) async {
    final signals = await generateRiskAssessedSignals(
      watchlist: watchlist,
      maxSignals: maxSignals,
      userProfile: userProfile,
      filterByRisk: true,
    );
    
    final recommendations = <SignalRecommendation>[];
    
    for (final signal in signals) {
      final positionSize = signal.getRecommendedPositionSize(userProfile);
      final riskWarnings = signal.riskAssessment?.riskWarnings ?? [];
      
      recommendations.add(SignalRecommendation(
        signal: signal,
        recommendedPositionSize: positionSize,
        riskWarnings: riskWarnings,
        matchScore: _calculateRiskAdjustedScore(signal, userProfile),
        reasoning: _generateRecommendationReasoning(signal, userProfile),
      ));
    }
    
    return PersonalizedSignalResponse(
      userArchetype: userProfile.archetype,
      riskAppetite: userProfile.riskRewardAppetite,
      recommendations: recommendations,
      summary: _generateSummary(recommendations, userProfile),
      generatedAt: DateTime.now(),
    );
  }
  
  String _generateRecommendationReasoning(GeneratedSignal signal, UserRiskProfile userProfile) {
    final riskLevel = signal.riskLevel.displayName;
    final riskScore = signal.riskScore;
    final userArchetype = userProfile.archetype.displayName;
    final positionSize = (signal.getRecommendedPositionSize(userProfile) * 100).toStringAsFixed(1);
    
    var reasoning = 'This $riskLevel risk signal (${riskScore}/100) aligns with your $userArchetype risk profile. ';
    
    if (signal.riskRewardRatio > 2.0) {
      reasoning += 'Excellent risk-reward ratio of ${signal.riskRewardRatio.toStringAsFixed(1)}:1. ';
    } else if (signal.riskRewardRatio < 1.0) {
      reasoning += 'Lower risk-reward ratio of ${signal.riskRewardRatio.toStringAsFixed(1)}:1 - consider carefully. ';
    }
    
    reasoning += 'Recommended position size: ${positionSize}% of portfolio.';
    
    if (signal.riskAssessment?.scenarios.probabilityOfProfit != null) {
      final probability = (signal.riskAssessment!.scenarios.probabilityOfProfit * 100).round();
      reasoning += ' Estimated success probability: $probability%.';
    }
    
    return reasoning;
  }
  
  PersonalizedSignalSummary _generateSummary(List<SignalRecommendation> recommendations, UserRiskProfile userProfile) {
    final totalSignals = recommendations.length;
    final highRiskCount = recommendations.where((r) => r.signal.riskLevel == RiskLevel.high || r.signal.riskLevel == RiskLevel.veryHigh).length;
    final averageConfidence = recommendations.isEmpty ? 0.0 : 
        recommendations.map((r) => r.signal.confidenceScore).reduce((a, b) => a + b) / totalSignals;
    
    final totalPositionSize = recommendations.isEmpty ? 0.0 :
        recommendations.map((r) => r.recommendedPositionSize).reduce((a, b) => a + b);
    
    return PersonalizedSignalSummary(
      totalSignals: totalSignals,
      highRiskSignals: highRiskCount,
      averageConfidence: averageConfidence,
      totalRecommendedExposure: totalPositionSize,
      riskDistribution: _calculateRiskDistribution(recommendations),
      keyWarnings: _extractKeyWarnings(recommendations),
    );
  }
  
  Map<RiskLevel, int> _calculateRiskDistribution(List<SignalRecommendation> recommendations) {
    final distribution = <RiskLevel, int>{};
    
    for (final recommendation in recommendations) {
      final level = recommendation.signal.riskLevel;
      distribution[level] = (distribution[level] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  List<String> _extractKeyWarnings(List<SignalRecommendation> recommendations) {
    final allWarnings = <String>{};
    
    for (final recommendation in recommendations) {
      allWarnings.addAll(recommendation.riskWarnings);
    }
    
    return allWarnings.take(5).toList(); // Top 5 unique warnings
  }
}

/// Personalized signal recommendation with risk assessment
class SignalRecommendation {
  final GeneratedSignal signal;
  final double recommendedPositionSize; // 0.0 to 1.0 (percentage of portfolio)
  final List<String> riskWarnings;
  final double matchScore; // How well this signal matches user profile
  final String reasoning;
  
  SignalRecommendation({
    required this.signal,
    required this.recommendedPositionSize,
    required this.riskWarnings,
    required this.matchScore,
    required this.reasoning,
  });
  
  String get positionSizePercentage => '${(recommendedPositionSize * 100).toStringAsFixed(1)}%';
  
  bool get hasWarnings => riskWarnings.isNotEmpty;
  
  Map<String, dynamic> toJson() {
    return {
      'signal': signal.toPocketBaseSignal(),
      'recommended_position_size': recommendedPositionSize,
      'position_size_percentage': positionSizePercentage,
      'risk_warnings': riskWarnings,
      'match_score': matchScore,
      'reasoning': reasoning,
      'has_warnings': hasWarnings,
    };
  }
}

/// Personalized response containing multiple signal recommendations
class PersonalizedSignalResponse {
  final RiskArchetype userArchetype;
  final int riskAppetite;
  final List<SignalRecommendation> recommendations;
  final PersonalizedSignalSummary summary;
  final DateTime generatedAt;
  
  PersonalizedSignalResponse({
    required this.userArchetype,
    required this.riskAppetite,
    required this.recommendations,
    required this.summary,
    required this.generatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_archetype': userArchetype.name,
      'risk_appetite': riskAppetite,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'summary': summary.toJson(),
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

/// Summary of personalized signal recommendations
class PersonalizedSignalSummary {
  final int totalSignals;
  final int highRiskSignals;
  final double averageConfidence;
  final double totalRecommendedExposure; // Total portfolio exposure
  final Map<RiskLevel, int> riskDistribution;
  final List<String> keyWarnings;
  
  PersonalizedSignalSummary({
    required this.totalSignals,
    required this.highRiskSignals,
    required this.averageConfidence,
    required this.totalRecommendedExposure,
    required this.riskDistribution,
    required this.keyWarnings,
  });
  
  String get exposurePercentage => '${(totalRecommendedExposure * 100).toStringAsFixed(1)}%';
  
  bool get isOverExposed => totalRecommendedExposure > 1.0; // More than 100% portfolio
  
  Map<String, dynamic> toJson() {
    return {
      'total_signals': totalSignals,
      'high_risk_signals': highRiskSignals,
      'average_confidence': averageConfidence,
      'total_recommended_exposure': totalRecommendedExposure,
      'exposure_percentage': exposurePercentage,
      'is_over_exposed': isOverExposed,
      'risk_distribution': riskDistribution.map((k, v) => MapEntry(k.name, v)),
      'key_warnings': keyWarnings,
    };
  }
}