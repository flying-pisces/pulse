import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_risk_profile.dart';
import '../../presentation/providers/auth_provider.dart';
import '../models/pocketbase_models.dart';
import 'pocketbase_service.dart';

/// Service for managing user risk profiles and behavior tracking
class RiskProfileService {
  final PocketBaseService _pocketBaseService;
  
  RiskProfileService(this._pocketBaseService);
  
  /// Get user's risk profile
  Future<UserRiskProfile?> getUserRiskProfile(String userId) async {
    try {
      final records = await _pocketBaseService.pb.collection('user_risk_profiles')
          .getList(filter: 'user_id = "$userId"');
      
      if (records.items.isEmpty) return null;
      
      final record = records.items.first;
      return UserRiskProfile.fromJson(record.toJson());
    } catch (e) {
      print('Error fetching user risk profile: $e');
      return null;
    }
  }
  
  /// Create or update user's risk profile
  Future<UserRiskProfile> saveUserRiskProfile(UserRiskProfile profile) async {
    try {
      final existingProfile = await getUserRiskProfile(profile.userId);
      
      final profileData = profile.toJson();
      profileData.remove('id'); // Remove ID for creation/update
      
      PBRecord record;
      if (existingProfile != null) {
        // Update existing profile
        record = await _pocketBaseService.pb.collection('user_risk_profiles')
            .update(existingProfile.userId, body: profileData);
      } else {
        // Create new profile
        record = await _pocketBaseService.pb.collection('user_risk_profiles')
            .create(body: profileData);
      }
      
      return UserRiskProfile.fromJson(record.toJson());
    } catch (e) {
      print('Error saving user risk profile: $e');
      rethrow;
    }
  }
  
  /// Record user behavior for risk profile adjustment
  Future<void> recordUserBehavior({
    required String userId,
    required String signalId,
    required String action, // 'accepted', 'declined', 'modified'
    required double signalRiskScore,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get current user profile
      final profile = await getUserRiskProfile(userId);
      if (profile == null) return;
      
      // Create behavior record
      final behavior = UserRiskBehavior(
        timestamp: DateTime.now(),
        signalId: signalId,
        action: action,
        signalRiskScore: signalRiskScore,
        userRiskScoreAtTime: profile.riskRewardAppetite.toDouble(),
        metadata: metadata,
      );
      
      // Save behavior to database
      await _pocketBaseService.pb.collection('user_risk_behaviors').create(
        body: {
          'user_id': userId,
          'signal_id': signalId,
          'action': action,
          'signal_risk_score': signalRiskScore,
          'user_risk_score_at_time': profile.riskRewardAppetite,
          'timestamp': behavior.timestamp.toIso8601String(),
          'metadata': metadata ?? {},
        },
      );
      
      // Update user's behavior history
      final updatedBehaviors = [...profile.behaviorHistory, behavior];
      
      // Keep only last 100 behaviors for performance
      final recentBehaviors = updatedBehaviors.length > 100 
          ? updatedBehaviors.sublist(updatedBehaviors.length - 100)
          : updatedBehaviors;
      
      // Calculate new risk score based on recent behavior
      final newRiskScore = RiskProfileCalculator.updateRiskScore(
        profile: profile,
        recentBehaviors: recentBehaviors.where((b) => 
            DateTime.now().difference(b.timestamp).inDays <= 30
        ).toList(), // Only consider last 30 days
      );
      
      // Update profile statistics
      final updatedProfile = profile.copyWith(
        riskRewardAppetite: newRiskScore,
        archetype: RiskProfileCalculator.determineArchetype(newRiskScore),
        behaviorHistory: recentBehaviors,
        updatedAt: DateTime.now(),
        totalSignalsAccepted: action == 'accepted' 
            ? profile.totalSignalsAccepted + 1 
            : profile.totalSignalsAccepted,
        totalSignalsDeclined: action == 'declined' 
            ? profile.totalSignalsDeclined + 1 
            : profile.totalSignalsDeclined,
      );
      
      // Save updated profile
      await saveUserRiskProfile(updatedProfile);
      
    } catch (e) {
      print('Error recording user behavior: $e');
      rethrow;
    }
  }
  
  /// Get user's recent behavior patterns
  Future<List<UserRiskBehavior>> getUserBehaviorHistory({
    required String userId,
    int days = 30,
    int limit = 50,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final records = await _pocketBaseService.pb.collection('user_risk_behaviors')
          .getList(
            filter: 'user_id = "$userId" && timestamp >= "${cutoffDate.toIso8601String()}"',
            sort: '-timestamp',
            perPage: limit,
          );
      
      return records.items.map((record) {
        final data = record.toJson();
        return UserRiskBehavior(
          timestamp: DateTime.parse(data['timestamp']),
          signalId: data['signal_id'],
          action: data['action'],
          signalRiskScore: data['signal_risk_score']?.toDouble() ?? 0.0,
          userRiskScoreAtTime: data['user_risk_score_at_time']?.toDouble() ?? 50.0,
          metadata: data['metadata'] ?? {},
        );
      }).toList();
    } catch (e) {
      print('Error fetching user behavior history: $e');
      return [];
    }
  }
  
  /// Analyze user's risk behavior patterns
  Future<RiskBehaviorAnalysis> analyzeUserRiskBehavior(String userId) async {
    try {
      final behaviors = await getUserBehaviorHistory(userId: userId, days: 90);
      
      if (behaviors.isEmpty) {
        return RiskBehaviorAnalysis.empty(userId);
      }
      
      // Calculate behavior metrics
      final totalBehaviors = behaviors.length;
      final acceptedCount = behaviors.where((b) => b.action == 'accepted').length;
      final declinedCount = behaviors.where((b) => b.action == 'declined').length;
      final acceptanceRate = totalBehaviors > 0 ? acceptedCount / totalBehaviors : 0.0;
      
      // Calculate average risk scores
      final acceptedSignals = behaviors.where((b) => b.action == 'accepted');
      final averageAcceptedRisk = acceptedSignals.isEmpty ? 0.0 :
          acceptedSignals.map((b) => b.signalRiskScore).reduce((a, b) => a + b) / acceptedSignals.length;
      
      final declinedSignals = behaviors.where((b) => b.action == 'declined');
      final averageDeclinedRisk = declinedSignals.isEmpty ? 0.0 :
          declinedSignals.map((b) => b.signalRiskScore).reduce((a, b) => a + b) / declinedSignals.length;
      
      // Identify trends
      final recentBehaviors = behaviors.take(20).toList();
      final olderBehaviors = behaviors.skip(20).take(20).toList();
      
      final recentAcceptanceRate = recentBehaviors.isEmpty ? 0.0 :
          recentBehaviors.where((b) => b.action == 'accepted').length / recentBehaviors.length;
      final olderAcceptanceRate = olderBehaviors.isEmpty ? 0.0 :
          olderBehaviors.where((b) => b.action == 'accepted').length / olderBehaviors.length;
      
      final riskTolerance = _determineRiskTolerance(averageAcceptedRisk, averageDeclinedRisk);
      final behaviorTrend = _determineBehaviorTrend(recentAcceptanceRate, olderAcceptanceRate);
      
      return RiskBehaviorAnalysis(
        userId: userId,
        totalSignalsAnalyzed: totalBehaviors,
        acceptanceRate: acceptanceRate,
        averageAcceptedRiskScore: averageAcceptedRisk,
        averageDeclinedRiskScore: averageDeclinedRisk,
        riskTolerance: riskTolerance,
        behaviorTrend: behaviorTrend,
        recommendations: _generateRecommendations(acceptanceRate, averageAcceptedRisk, behaviorTrend),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error analyzing user risk behavior: $e');
      return RiskBehaviorAnalysis.empty(userId);
    }
  }
  
  /// Initialize default risk profile for new user
  Future<UserRiskProfile> createDefaultRiskProfile({
    required String userId,
    RiskArchetype? preferredArchetype,
    int? initialRiskScore,
  }) async {
    try {
      final profile = RiskProfileCalculator.createDefaultProfile(
        userId: userId,
        archetype: preferredArchetype,
        riskRewardAppetite: initialRiskScore,
      );
      
      return await saveUserRiskProfile(profile);
    } catch (e) {
      print('Error creating default risk profile: $e');
      rethrow;
    }
  }
  
  /// Update user's signal performance feedback
  Future<void> updateSignalPerformance({
    required String userId,
    required String signalId,
    required double performanceScore, // -1.0 to 1.0
  }) async {
    try {
      final profile = await getUserRiskProfile(userId);
      if (profile == null) return;
      
      // Update running average of signal performance
      final totalSignals = profile.totalSignalsAccepted + profile.totalSignalsDeclined;
      final currentAverage = profile.averageSignalPerformance;
      
      final newAverage = totalSignals == 0 ? performanceScore :
          ((currentAverage * totalSignals) + performanceScore) / (totalSignals + 1);
      
      final updatedProfile = profile.copyWith(
        averageSignalPerformance: newAverage,
        updatedAt: DateTime.now(),
      );
      
      await saveUserRiskProfile(updatedProfile);
      
      // Record performance feedback
      await recordUserBehavior(
        userId: userId,
        signalId: signalId,
        action: 'performance_feedback',
        signalRiskScore: 0.0, // Not applicable for performance updates
        metadata: {
          'performance_score': performanceScore,
          'new_average': newAverage,
        },
      );
    } catch (e) {
      print('Error updating signal performance: $e');
      rethrow;
    }
  }
  
  RiskToleranceLevel _determineRiskTolerance(double averageAccepted, double averageDeclined) {
    if (averageAccepted > 70) return RiskToleranceLevel.high;
    if (averageAccepted > 40) return RiskToleranceLevel.medium;
    return RiskToleranceLevel.low;
  }
  
  BehaviorTrend _determineBehaviorTrend(double recentRate, double olderRate) {
    final diff = recentRate - olderRate;
    if (diff > 0.1) return BehaviorTrend.increasingRisk;
    if (diff < -0.1) return BehaviorTrend.decreasingRisk;
    return BehaviorTrend.stable;
  }
  
  List<String> _generateRecommendations(double acceptanceRate, double avgRisk, BehaviorTrend trend) {
    final recommendations = <String>[];
    
    if (acceptanceRate < 0.2) {
      recommendations.add('Consider reviewing signal criteria - you may be too restrictive');
    }
    
    if (acceptanceRate > 0.8) {
      recommendations.add('You accept most signals - consider being more selective');
    }
    
    if (avgRisk > 80) {
      recommendations.add('Your accepted signals are very high risk - ensure proper position sizing');
    }
    
    if (trend == BehaviorTrend.increasingRisk) {
      recommendations.add('Your risk appetite is increasing - monitor portfolio exposure');
    } else if (trend == BehaviorTrend.decreasingRisk) {
      recommendations.add('You\'re becoming more conservative - this may limit potential returns');
    }
    
    return recommendations;
  }
}

/// Analysis of user's risk behavior patterns
class RiskBehaviorAnalysis {
  final String userId;
  final int totalSignalsAnalyzed;
  final double acceptanceRate;
  final double averageAcceptedRiskScore;
  final double averageDeclinedRiskScore;
  final RiskToleranceLevel riskTolerance;
  final BehaviorTrend behaviorTrend;
  final List<String> recommendations;
  final DateTime analyzedAt;
  
  RiskBehaviorAnalysis({
    required this.userId,
    required this.totalSignalsAnalyzed,
    required this.acceptanceRate,
    required this.averageAcceptedRiskScore,
    required this.averageDeclinedRiskScore,
    required this.riskTolerance,
    required this.behaviorTrend,
    required this.recommendations,
    required this.analyzedAt,
  });
  
  factory RiskBehaviorAnalysis.empty(String userId) {
    return RiskBehaviorAnalysis(
      userId: userId,
      totalSignalsAnalyzed: 0,
      acceptanceRate: 0.0,
      averageAcceptedRiskScore: 0.0,
      averageDeclinedRiskScore: 0.0,
      riskTolerance: RiskToleranceLevel.medium,
      behaviorTrend: BehaviorTrend.stable,
      recommendations: ['No behavior data available yet - start by accepting or declining signals'],
      analyzedAt: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_signals_analyzed': totalSignalsAnalyzed,
      'acceptance_rate': acceptanceRate,
      'acceptance_rate_percentage': '${(acceptanceRate * 100).round()}%',
      'average_accepted_risk_score': averageAcceptedRiskScore,
      'average_declined_risk_score': averageDeclinedRiskScore,
      'risk_tolerance': riskTolerance.name,
      'behavior_trend': behaviorTrend.name,
      'recommendations': recommendations,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}

enum RiskToleranceLevel {
  low,
  medium,
  high,
}

enum BehaviorTrend {
  increasingRisk,
  stable,
  decreasingRisk,
}

/// Provider for risk profile service
final riskProfileServiceProvider = Provider<RiskProfileService>((ref) {
  final pocketBaseService = ref.read(pocketBaseServiceProvider);
  return RiskProfileService(pocketBaseService);
});

/// Provider for current user's risk profile
final userRiskProfileProvider = FutureProvider.autoDispose<UserRiskProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  final riskService = ref.read(riskProfileServiceProvider);
  
  final user = authState.user;
  return user != null ? await riskService.getUserRiskProfile(user.id) : null;
});

/// Provider for user behavior analysis
final userBehaviorAnalysisProvider = FutureProvider.autoDispose<RiskBehaviorAnalysis?>((ref) async {
  final authState = ref.watch(authProvider);
  final riskService = ref.read(riskProfileServiceProvider);
  
  final user = authState.user;
  return user != null ? await riskService.analyzeUserRiskBehavior(user.id) : null;
});