// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_risk_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserRiskProfile _$UserRiskProfileFromJson(
  Map<String, dynamic> json,
) => _UserRiskProfile(
  userId: json['userId'] as String,
  archetype: $enumDecode(_$RiskArchetypeEnumMap, json['archetype']),
  riskRewardAppetite: (json['riskRewardAppetite'] as num).toInt(),
  maxPositionSize: (json['maxPositionSize'] as num).toDouble(),
  maxDailyLoss: (json['maxDailyLoss'] as num).toDouble(),
  maxSignalsPerDay: (json['maxSignalsPerDay'] as num).toInt(),
  preferredSignalTypes: (json['preferredSignalTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskTolerance: (json['riskTolerance'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  totalSignalsAccepted: (json['totalSignalsAccepted'] as num?)?.toInt() ?? 0,
  totalSignalsDeclined: (json['totalSignalsDeclined'] as num?)?.toInt() ?? 0,
  averageSignalPerformance:
      (json['averageSignalPerformance'] as num?)?.toDouble() ?? 0.0,
  behaviorHistory:
      (json['behaviorHistory'] as List<dynamic>?)
          ?.map((e) => UserRiskBehavior.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserRiskProfileToJson(_UserRiskProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'archetype': _$RiskArchetypeEnumMap[instance.archetype]!,
      'riskRewardAppetite': instance.riskRewardAppetite,
      'maxPositionSize': instance.maxPositionSize,
      'maxDailyLoss': instance.maxDailyLoss,
      'maxSignalsPerDay': instance.maxSignalsPerDay,
      'preferredSignalTypes': instance.preferredSignalTypes,
      'riskTolerance': instance.riskTolerance,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'totalSignalsAccepted': instance.totalSignalsAccepted,
      'totalSignalsDeclined': instance.totalSignalsDeclined,
      'averageSignalPerformance': instance.averageSignalPerformance,
      'behaviorHistory': instance.behaviorHistory,
    };

const _$RiskArchetypeEnumMap = {
  RiskArchetype.yolo: 'yolo',
  RiskArchetype.reasonable: 'reasonable',
  RiskArchetype.conservative: 'conservative',
};

_UserRiskBehavior _$UserRiskBehaviorFromJson(Map<String, dynamic> json) =>
    _UserRiskBehavior(
      timestamp: DateTime.parse(json['timestamp'] as String),
      signalId: json['signalId'] as String,
      action: json['action'] as String,
      signalRiskScore: (json['signalRiskScore'] as num).toDouble(),
      userRiskScoreAtTime: (json['userRiskScoreAtTime'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserRiskBehaviorToJson(_UserRiskBehavior instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'signalId': instance.signalId,
      'action': instance.action,
      'signalRiskScore': instance.signalRiskScore,
      'userRiskScoreAtTime': instance.userRiskScoreAtTime,
      'metadata': instance.metadata,
    };
