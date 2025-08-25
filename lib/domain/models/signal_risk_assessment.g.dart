// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_risk_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignalRiskAssessment _$SignalRiskAssessmentFromJson(
  Map<String, dynamic> json,
) => _SignalRiskAssessment(
  signalId: json['signalId'] as String,
  overallRiskScore: (json['overallRiskScore'] as num).toInt(),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  riskRewardRatio: (json['riskRewardRatio'] as num).toDouble(),
  scenarios: StatisticalScenarios.fromJson(
    json['scenarios'] as Map<String, dynamic>,
  ),
  riskFactors: (json['riskFactors'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  riskWarnings: (json['riskWarnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessedAt: DateTime.parse(json['assessedAt'] as String),
  isHighFrequencySignal: json['isHighFrequencySignal'] as bool? ?? false,
  requiresOptionsPermission:
      json['requiresOptionsPermission'] as bool? ?? false,
  isDayTradingSignal: json['isDayTradingSignal'] as bool? ?? false,
);

Map<String, dynamic> _$SignalRiskAssessmentToJson(
  _SignalRiskAssessment instance,
) => <String, dynamic>{
  'signalId': instance.signalId,
  'overallRiskScore': instance.overallRiskScore,
  'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
  'riskRewardRatio': instance.riskRewardRatio,
  'scenarios': instance.scenarios,
  'riskFactors': instance.riskFactors,
  'riskWarnings': instance.riskWarnings,
  'assessedAt': instance.assessedAt.toIso8601String(),
  'isHighFrequencySignal': instance.isHighFrequencySignal,
  'requiresOptionsPermission': instance.requiresOptionsPermission,
  'isDayTradingSignal': instance.isDayTradingSignal,
};

const _$RiskLevelEnumMap = {
  RiskLevel.veryLow: 'very_low',
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};

_StatisticalScenarios _$StatisticalScenariosFromJson(
  Map<String, dynamic> json,
) => _StatisticalScenarios(
  bestCase: ScenarioOutcome.fromJson(json['bestCase'] as Map<String, dynamic>),
  expectedCase: ScenarioOutcome.fromJson(
    json['expectedCase'] as Map<String, dynamic>,
  ),
  worstCase: ScenarioOutcome.fromJson(
    json['worstCase'] as Map<String, dynamic>,
  ),
  probabilityOfProfit: (json['probabilityOfProfit'] as num).toDouble(),
  expectedValue: (json['expectedValue'] as num).toDouble(),
  maximumDrawdown: (json['maximumDrawdown'] as num).toDouble(),
  sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
);

Map<String, dynamic> _$StatisticalScenariosToJson(
  _StatisticalScenarios instance,
) => <String, dynamic>{
  'bestCase': instance.bestCase,
  'expectedCase': instance.expectedCase,
  'worstCase': instance.worstCase,
  'probabilityOfProfit': instance.probabilityOfProfit,
  'expectedValue': instance.expectedValue,
  'maximumDrawdown': instance.maximumDrawdown,
  'sharpeRatio': instance.sharpeRatio,
};

_ScenarioOutcome _$ScenarioOutcomeFromJson(Map<String, dynamic> json) =>
    _ScenarioOutcome(
      returnPercentage: (json['returnPercentage'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      timeToRealizationDays: (json['timeToRealizationDays'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ScenarioOutcomeToJson(_ScenarioOutcome instance) =>
    <String, dynamic>{
      'returnPercentage': instance.returnPercentage,
      'probability': instance.probability,
      'timeToRealizationDays': instance.timeToRealizationDays,
      'description': instance.description,
    };
