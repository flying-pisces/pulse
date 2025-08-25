import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_risk_profile.freezed.dart';
part 'user_risk_profile.g.dart';

enum RiskArchetype {
  @JsonValue('yolo')
  yolo,
  @JsonValue('reasonable')
  reasonable,
  @JsonValue('conservative')
  conservative,
}

extension RiskArchetypeExtension on RiskArchetype {
  String get displayName {
    switch (this) {
      case RiskArchetype.yolo:
        return 'YOLO';
      case RiskArchetype.reasonable:
        return 'Reasonable';
      case RiskArchetype.conservative:
        return 'Conservative';
    }
  }

  String get description {
    switch (this) {
      case RiskArchetype.yolo:
        return 'Extremely risky favorite, willing to lose all principle to chase for high return';
      case RiskArchetype.reasonable:
        return 'Willing to take some risk but rely on risk reward ratio to make decisions to favor reward';
      case RiskArchetype.conservative:
        return 'Extremely risk aversion, prioritizes capital preservation over high returns';
    }
  }

  int get minRiskScore {
    switch (this) {
      case RiskArchetype.yolo:
        return 70;
      case RiskArchetype.reasonable:
        return 30;
      case RiskArchetype.conservative:
        return 0;
    }
  }

  int get maxRiskScore {
    switch (this) {
      case RiskArchetype.yolo:
        return 100;
      case RiskArchetype.reasonable:
        return 69;
      case RiskArchetype.conservative:
        return 29;
    }
  }
}

@freezed
class UserRiskProfile with _$UserRiskProfile {
  const factory UserRiskProfile({
    required String userId,
    required RiskArchetype archetype,
    required int riskRewardAppetite, // 0-100 scale
    required double maxPositionSize, // Percentage of portfolio
    required double maxDailyLoss, // Percentage of portfolio
    required int maxSignalsPerDay,
    required List<String> preferredSignalTypes,
    required Map<String, double> riskTolerance, // Signal type -> risk multiplier
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int totalSignalsAccepted,
    @Default(0) int totalSignalsDeclined,
    @Default(0.0) double averageSignalPerformance,
    @Default([]) List<UserRiskBehavior> behaviorHistory,
  }) = _UserRiskProfile;

  factory UserRiskProfile.fromJson(Map<String, dynamic> json) =>
      _$UserRiskProfileFromJson(json);
}

@freezed
class UserRiskBehavior with _$UserRiskBehavior {
  const factory UserRiskBehavior({
    required DateTime timestamp,
    required String signalId,
    required String action, // 'accepted', 'declined', 'modified'
    required double signalRiskScore,
    required double userRiskScoreAtTime,
    Map<String, dynamic>? metadata,
  }) = _UserRiskBehavior;

  factory UserRiskBehavior.fromJson(Map<String, dynamic> json) =>
      _$UserRiskBehaviorFromJson(json);
}

class RiskProfileCalculator {
  static RiskArchetype determineArchetype(int riskRewardAppetite) {
    if (riskRewardAppetite >= 70) return RiskArchetype.yolo;
    if (riskRewardAppetite >= 30) return RiskArchetype.reasonable;
    return RiskArchetype.conservative;
  }

  static UserRiskProfile createDefaultProfile({
    required String userId,
    RiskArchetype? archetype,
    int? riskRewardAppetite,
  }) {
    final appetite = riskRewardAppetite ?? 50;
    final defaultArchetype = archetype ?? determineArchetype(appetite);

    return UserRiskProfile(
      userId: userId,
      archetype: defaultArchetype,
      riskRewardAppetite: appetite,
      maxPositionSize: _getDefaultMaxPositionSize(defaultArchetype),
      maxDailyLoss: _getDefaultMaxDailyLoss(defaultArchetype),
      maxSignalsPerDay: _getDefaultMaxSignalsPerDay(defaultArchetype),
      preferredSignalTypes: _getDefaultPreferredSignalTypes(defaultArchetype),
      riskTolerance: _getDefaultRiskTolerance(defaultArchetype),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static double _getDefaultMaxPositionSize(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 0.50; // 50% of portfolio
      case RiskArchetype.reasonable:
        return 0.20; // 20% of portfolio
      case RiskArchetype.conservative:
        return 0.05; // 5% of portfolio
    }
  }

  static double _getDefaultMaxDailyLoss(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 0.20; // 20% daily loss tolerance
      case RiskArchetype.reasonable:
        return 0.05; // 5% daily loss tolerance
      case RiskArchetype.conservative:
        return 0.02; // 2% daily loss tolerance
    }
  }

  static int _getDefaultMaxSignalsPerDay(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 20;
      case RiskArchetype.reasonable:
        return 10;
      case RiskArchetype.conservative:
        return 3;
    }
  }

  static List<String> _getDefaultPreferredSignalTypes(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return ['0dte_options', 'momentum', 'breakout', 'earnings'];
      case RiskArchetype.reasonable:
        return ['swing_trade', 'momentum', 'volume_spike', 'earnings'];
      case RiskArchetype.conservative:
        return ['dividend_play', 'support_bounce', 'long_term_trend'];
    }
  }

  static Map<String, double> _getDefaultRiskTolerance(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return {
          '0dte_options': 1.5,
          'momentum': 1.2,
          'breakout': 1.3,
          'earnings': 1.4,
          'swing_trade': 0.8,
          'support_bounce': 0.6,
          'dividend_play': 0.3,
        };
      case RiskArchetype.reasonable:
        return {
          '0dte_options': 0.5,
          'momentum': 1.0,
          'breakout': 0.9,
          'earnings': 0.8,
          'swing_trade': 1.1,
          'support_bounce': 1.0,
          'dividend_play': 0.7,
        };
      case RiskArchetype.conservative:
        return {
          '0dte_options': 0.1,
          'momentum': 0.6,
          'breakout': 0.5,
          'earnings': 0.4,
          'swing_trade': 0.8,
          'support_bounce': 1.2,
          'dividend_play': 1.5,
        };
    }
  }

  static int updateRiskScore({
    required UserRiskProfile profile,
    required List<UserRiskBehavior> recentBehaviors,
  }) {
    if (recentBehaviors.isEmpty) return profile.riskRewardAppetite;

    // Calculate behavior-based risk score adjustment
    final acceptedHighRisk = recentBehaviors
        .where((b) => b.action == 'accepted' && b.signalRiskScore > 70)
        .length;
    
    final declinedLowRisk = recentBehaviors
        .where((b) => b.action == 'declined' && b.signalRiskScore < 30)
        .length;

    final totalBehaviors = recentBehaviors.length;
    
    // Increase score if accepting high-risk signals frequently
    final riskIncreaseScore = (acceptedHighRisk / totalBehaviors * 10).round();
    
    // Decrease score if declining low-risk signals frequently
    final riskDecreaseScore = (declinedLowRisk / totalBehaviors * 5).round();

    final newScore = (profile.riskRewardAppetite + riskIncreaseScore - riskDecreaseScore)
        .clamp(0, 100);

    return newScore;
  }
}