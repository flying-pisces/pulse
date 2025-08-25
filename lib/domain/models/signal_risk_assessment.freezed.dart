// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signal_risk_assessment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignalRiskAssessment {

 String get signalId; int get overallRiskScore;// 0-100
 RiskLevel get riskLevel; double get riskRewardRatio; StatisticalScenarios get scenarios; Map<String, double> get riskFactors; List<String> get riskWarnings; DateTime get assessedAt; bool get isHighFrequencySignal; bool get requiresOptionsPermission; bool get isDayTradingSignal;
/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignalRiskAssessmentCopyWith<SignalRiskAssessment> get copyWith => _$SignalRiskAssessmentCopyWithImpl<SignalRiskAssessment>(this as SignalRiskAssessment, _$identity);

  /// Serializes this SignalRiskAssessment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignalRiskAssessment&&(identical(other.signalId, signalId) || other.signalId == signalId)&&(identical(other.overallRiskScore, overallRiskScore) || other.overallRiskScore == overallRiskScore)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.riskRewardRatio, riskRewardRatio) || other.riskRewardRatio == riskRewardRatio)&&(identical(other.scenarios, scenarios) || other.scenarios == scenarios)&&const DeepCollectionEquality().equals(other.riskFactors, riskFactors)&&const DeepCollectionEquality().equals(other.riskWarnings, riskWarnings)&&(identical(other.assessedAt, assessedAt) || other.assessedAt == assessedAt)&&(identical(other.isHighFrequencySignal, isHighFrequencySignal) || other.isHighFrequencySignal == isHighFrequencySignal)&&(identical(other.requiresOptionsPermission, requiresOptionsPermission) || other.requiresOptionsPermission == requiresOptionsPermission)&&(identical(other.isDayTradingSignal, isDayTradingSignal) || other.isDayTradingSignal == isDayTradingSignal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,signalId,overallRiskScore,riskLevel,riskRewardRatio,scenarios,const DeepCollectionEquality().hash(riskFactors),const DeepCollectionEquality().hash(riskWarnings),assessedAt,isHighFrequencySignal,requiresOptionsPermission,isDayTradingSignal);

@override
String toString() {
  return 'SignalRiskAssessment(signalId: $signalId, overallRiskScore: $overallRiskScore, riskLevel: $riskLevel, riskRewardRatio: $riskRewardRatio, scenarios: $scenarios, riskFactors: $riskFactors, riskWarnings: $riskWarnings, assessedAt: $assessedAt, isHighFrequencySignal: $isHighFrequencySignal, requiresOptionsPermission: $requiresOptionsPermission, isDayTradingSignal: $isDayTradingSignal)';
}


}

/// @nodoc
abstract mixin class $SignalRiskAssessmentCopyWith<$Res>  {
  factory $SignalRiskAssessmentCopyWith(SignalRiskAssessment value, $Res Function(SignalRiskAssessment) _then) = _$SignalRiskAssessmentCopyWithImpl;
@useResult
$Res call({
 String signalId, int overallRiskScore, RiskLevel riskLevel, double riskRewardRatio, StatisticalScenarios scenarios, Map<String, double> riskFactors, List<String> riskWarnings, DateTime assessedAt, bool isHighFrequencySignal, bool requiresOptionsPermission, bool isDayTradingSignal
});


$StatisticalScenariosCopyWith<$Res> get scenarios;

}
/// @nodoc
class _$SignalRiskAssessmentCopyWithImpl<$Res>
    implements $SignalRiskAssessmentCopyWith<$Res> {
  _$SignalRiskAssessmentCopyWithImpl(this._self, this._then);

  final SignalRiskAssessment _self;
  final $Res Function(SignalRiskAssessment) _then;

/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? signalId = null,Object? overallRiskScore = null,Object? riskLevel = null,Object? riskRewardRatio = null,Object? scenarios = null,Object? riskFactors = null,Object? riskWarnings = null,Object? assessedAt = null,Object? isHighFrequencySignal = null,Object? requiresOptionsPermission = null,Object? isDayTradingSignal = null,}) {
  return _then(_self.copyWith(
signalId: null == signalId ? _self.signalId : signalId // ignore: cast_nullable_to_non_nullable
as String,overallRiskScore: null == overallRiskScore ? _self.overallRiskScore : overallRiskScore // ignore: cast_nullable_to_non_nullable
as int,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as RiskLevel,riskRewardRatio: null == riskRewardRatio ? _self.riskRewardRatio : riskRewardRatio // ignore: cast_nullable_to_non_nullable
as double,scenarios: null == scenarios ? _self.scenarios : scenarios // ignore: cast_nullable_to_non_nullable
as StatisticalScenarios,riskFactors: null == riskFactors ? _self.riskFactors : riskFactors // ignore: cast_nullable_to_non_nullable
as Map<String, double>,riskWarnings: null == riskWarnings ? _self.riskWarnings : riskWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,assessedAt: null == assessedAt ? _self.assessedAt : assessedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isHighFrequencySignal: null == isHighFrequencySignal ? _self.isHighFrequencySignal : isHighFrequencySignal // ignore: cast_nullable_to_non_nullable
as bool,requiresOptionsPermission: null == requiresOptionsPermission ? _self.requiresOptionsPermission : requiresOptionsPermission // ignore: cast_nullable_to_non_nullable
as bool,isDayTradingSignal: null == isDayTradingSignal ? _self.isDayTradingSignal : isDayTradingSignal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatisticalScenariosCopyWith<$Res> get scenarios {
  
  return $StatisticalScenariosCopyWith<$Res>(_self.scenarios, (value) {
    return _then(_self.copyWith(scenarios: value));
  });
}
}


/// Adds pattern-matching-related methods to [SignalRiskAssessment].
extension SignalRiskAssessmentPatterns on SignalRiskAssessment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignalRiskAssessment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignalRiskAssessment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignalRiskAssessment value)  $default,){
final _that = this;
switch (_that) {
case _SignalRiskAssessment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignalRiskAssessment value)?  $default,){
final _that = this;
switch (_that) {
case _SignalRiskAssessment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String signalId,  int overallRiskScore,  RiskLevel riskLevel,  double riskRewardRatio,  StatisticalScenarios scenarios,  Map<String, double> riskFactors,  List<String> riskWarnings,  DateTime assessedAt,  bool isHighFrequencySignal,  bool requiresOptionsPermission,  bool isDayTradingSignal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignalRiskAssessment() when $default != null:
return $default(_that.signalId,_that.overallRiskScore,_that.riskLevel,_that.riskRewardRatio,_that.scenarios,_that.riskFactors,_that.riskWarnings,_that.assessedAt,_that.isHighFrequencySignal,_that.requiresOptionsPermission,_that.isDayTradingSignal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String signalId,  int overallRiskScore,  RiskLevel riskLevel,  double riskRewardRatio,  StatisticalScenarios scenarios,  Map<String, double> riskFactors,  List<String> riskWarnings,  DateTime assessedAt,  bool isHighFrequencySignal,  bool requiresOptionsPermission,  bool isDayTradingSignal)  $default,) {final _that = this;
switch (_that) {
case _SignalRiskAssessment():
return $default(_that.signalId,_that.overallRiskScore,_that.riskLevel,_that.riskRewardRatio,_that.scenarios,_that.riskFactors,_that.riskWarnings,_that.assessedAt,_that.isHighFrequencySignal,_that.requiresOptionsPermission,_that.isDayTradingSignal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String signalId,  int overallRiskScore,  RiskLevel riskLevel,  double riskRewardRatio,  StatisticalScenarios scenarios,  Map<String, double> riskFactors,  List<String> riskWarnings,  DateTime assessedAt,  bool isHighFrequencySignal,  bool requiresOptionsPermission,  bool isDayTradingSignal)?  $default,) {final _that = this;
switch (_that) {
case _SignalRiskAssessment() when $default != null:
return $default(_that.signalId,_that.overallRiskScore,_that.riskLevel,_that.riskRewardRatio,_that.scenarios,_that.riskFactors,_that.riskWarnings,_that.assessedAt,_that.isHighFrequencySignal,_that.requiresOptionsPermission,_that.isDayTradingSignal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignalRiskAssessment implements SignalRiskAssessment {
  const _SignalRiskAssessment({required this.signalId, required this.overallRiskScore, required this.riskLevel, required this.riskRewardRatio, required this.scenarios, required final  Map<String, double> riskFactors, required final  List<String> riskWarnings, required this.assessedAt, this.isHighFrequencySignal = false, this.requiresOptionsPermission = false, this.isDayTradingSignal = false}): _riskFactors = riskFactors,_riskWarnings = riskWarnings;
  factory _SignalRiskAssessment.fromJson(Map<String, dynamic> json) => _$SignalRiskAssessmentFromJson(json);

@override final  String signalId;
@override final  int overallRiskScore;
// 0-100
@override final  RiskLevel riskLevel;
@override final  double riskRewardRatio;
@override final  StatisticalScenarios scenarios;
 final  Map<String, double> _riskFactors;
@override Map<String, double> get riskFactors {
  if (_riskFactors is EqualUnmodifiableMapView) return _riskFactors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_riskFactors);
}

 final  List<String> _riskWarnings;
@override List<String> get riskWarnings {
  if (_riskWarnings is EqualUnmodifiableListView) return _riskWarnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_riskWarnings);
}

@override final  DateTime assessedAt;
@override@JsonKey() final  bool isHighFrequencySignal;
@override@JsonKey() final  bool requiresOptionsPermission;
@override@JsonKey() final  bool isDayTradingSignal;

/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignalRiskAssessmentCopyWith<_SignalRiskAssessment> get copyWith => __$SignalRiskAssessmentCopyWithImpl<_SignalRiskAssessment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignalRiskAssessmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignalRiskAssessment&&(identical(other.signalId, signalId) || other.signalId == signalId)&&(identical(other.overallRiskScore, overallRiskScore) || other.overallRiskScore == overallRiskScore)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.riskRewardRatio, riskRewardRatio) || other.riskRewardRatio == riskRewardRatio)&&(identical(other.scenarios, scenarios) || other.scenarios == scenarios)&&const DeepCollectionEquality().equals(other._riskFactors, _riskFactors)&&const DeepCollectionEquality().equals(other._riskWarnings, _riskWarnings)&&(identical(other.assessedAt, assessedAt) || other.assessedAt == assessedAt)&&(identical(other.isHighFrequencySignal, isHighFrequencySignal) || other.isHighFrequencySignal == isHighFrequencySignal)&&(identical(other.requiresOptionsPermission, requiresOptionsPermission) || other.requiresOptionsPermission == requiresOptionsPermission)&&(identical(other.isDayTradingSignal, isDayTradingSignal) || other.isDayTradingSignal == isDayTradingSignal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,signalId,overallRiskScore,riskLevel,riskRewardRatio,scenarios,const DeepCollectionEquality().hash(_riskFactors),const DeepCollectionEquality().hash(_riskWarnings),assessedAt,isHighFrequencySignal,requiresOptionsPermission,isDayTradingSignal);

@override
String toString() {
  return 'SignalRiskAssessment(signalId: $signalId, overallRiskScore: $overallRiskScore, riskLevel: $riskLevel, riskRewardRatio: $riskRewardRatio, scenarios: $scenarios, riskFactors: $riskFactors, riskWarnings: $riskWarnings, assessedAt: $assessedAt, isHighFrequencySignal: $isHighFrequencySignal, requiresOptionsPermission: $requiresOptionsPermission, isDayTradingSignal: $isDayTradingSignal)';
}


}

/// @nodoc
abstract mixin class _$SignalRiskAssessmentCopyWith<$Res> implements $SignalRiskAssessmentCopyWith<$Res> {
  factory _$SignalRiskAssessmentCopyWith(_SignalRiskAssessment value, $Res Function(_SignalRiskAssessment) _then) = __$SignalRiskAssessmentCopyWithImpl;
@override @useResult
$Res call({
 String signalId, int overallRiskScore, RiskLevel riskLevel, double riskRewardRatio, StatisticalScenarios scenarios, Map<String, double> riskFactors, List<String> riskWarnings, DateTime assessedAt, bool isHighFrequencySignal, bool requiresOptionsPermission, bool isDayTradingSignal
});


@override $StatisticalScenariosCopyWith<$Res> get scenarios;

}
/// @nodoc
class __$SignalRiskAssessmentCopyWithImpl<$Res>
    implements _$SignalRiskAssessmentCopyWith<$Res> {
  __$SignalRiskAssessmentCopyWithImpl(this._self, this._then);

  final _SignalRiskAssessment _self;
  final $Res Function(_SignalRiskAssessment) _then;

/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? signalId = null,Object? overallRiskScore = null,Object? riskLevel = null,Object? riskRewardRatio = null,Object? scenarios = null,Object? riskFactors = null,Object? riskWarnings = null,Object? assessedAt = null,Object? isHighFrequencySignal = null,Object? requiresOptionsPermission = null,Object? isDayTradingSignal = null,}) {
  return _then(_SignalRiskAssessment(
signalId: null == signalId ? _self.signalId : signalId // ignore: cast_nullable_to_non_nullable
as String,overallRiskScore: null == overallRiskScore ? _self.overallRiskScore : overallRiskScore // ignore: cast_nullable_to_non_nullable
as int,riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as RiskLevel,riskRewardRatio: null == riskRewardRatio ? _self.riskRewardRatio : riskRewardRatio // ignore: cast_nullable_to_non_nullable
as double,scenarios: null == scenarios ? _self.scenarios : scenarios // ignore: cast_nullable_to_non_nullable
as StatisticalScenarios,riskFactors: null == riskFactors ? _self._riskFactors : riskFactors // ignore: cast_nullable_to_non_nullable
as Map<String, double>,riskWarnings: null == riskWarnings ? _self._riskWarnings : riskWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,assessedAt: null == assessedAt ? _self.assessedAt : assessedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isHighFrequencySignal: null == isHighFrequencySignal ? _self.isHighFrequencySignal : isHighFrequencySignal // ignore: cast_nullable_to_non_nullable
as bool,requiresOptionsPermission: null == requiresOptionsPermission ? _self.requiresOptionsPermission : requiresOptionsPermission // ignore: cast_nullable_to_non_nullable
as bool,isDayTradingSignal: null == isDayTradingSignal ? _self.isDayTradingSignal : isDayTradingSignal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SignalRiskAssessment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatisticalScenariosCopyWith<$Res> get scenarios {
  
  return $StatisticalScenariosCopyWith<$Res>(_self.scenarios, (value) {
    return _then(_self.copyWith(scenarios: value));
  });
}
}


/// @nodoc
mixin _$StatisticalScenarios {

 ScenarioOutcome get bestCase; ScenarioOutcome get expectedCase; ScenarioOutcome get worstCase; double get probabilityOfProfit; double get expectedValue; double get maximumDrawdown; double get sharpeRatio;
/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatisticalScenariosCopyWith<StatisticalScenarios> get copyWith => _$StatisticalScenariosCopyWithImpl<StatisticalScenarios>(this as StatisticalScenarios, _$identity);

  /// Serializes this StatisticalScenarios to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatisticalScenarios&&(identical(other.bestCase, bestCase) || other.bestCase == bestCase)&&(identical(other.expectedCase, expectedCase) || other.expectedCase == expectedCase)&&(identical(other.worstCase, worstCase) || other.worstCase == worstCase)&&(identical(other.probabilityOfProfit, probabilityOfProfit) || other.probabilityOfProfit == probabilityOfProfit)&&(identical(other.expectedValue, expectedValue) || other.expectedValue == expectedValue)&&(identical(other.maximumDrawdown, maximumDrawdown) || other.maximumDrawdown == maximumDrawdown)&&(identical(other.sharpeRatio, sharpeRatio) || other.sharpeRatio == sharpeRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bestCase,expectedCase,worstCase,probabilityOfProfit,expectedValue,maximumDrawdown,sharpeRatio);

@override
String toString() {
  return 'StatisticalScenarios(bestCase: $bestCase, expectedCase: $expectedCase, worstCase: $worstCase, probabilityOfProfit: $probabilityOfProfit, expectedValue: $expectedValue, maximumDrawdown: $maximumDrawdown, sharpeRatio: $sharpeRatio)';
}


}

/// @nodoc
abstract mixin class $StatisticalScenariosCopyWith<$Res>  {
  factory $StatisticalScenariosCopyWith(StatisticalScenarios value, $Res Function(StatisticalScenarios) _then) = _$StatisticalScenariosCopyWithImpl;
@useResult
$Res call({
 ScenarioOutcome bestCase, ScenarioOutcome expectedCase, ScenarioOutcome worstCase, double probabilityOfProfit, double expectedValue, double maximumDrawdown, double sharpeRatio
});


$ScenarioOutcomeCopyWith<$Res> get bestCase;$ScenarioOutcomeCopyWith<$Res> get expectedCase;$ScenarioOutcomeCopyWith<$Res> get worstCase;

}
/// @nodoc
class _$StatisticalScenariosCopyWithImpl<$Res>
    implements $StatisticalScenariosCopyWith<$Res> {
  _$StatisticalScenariosCopyWithImpl(this._self, this._then);

  final StatisticalScenarios _self;
  final $Res Function(StatisticalScenarios) _then;

/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bestCase = null,Object? expectedCase = null,Object? worstCase = null,Object? probabilityOfProfit = null,Object? expectedValue = null,Object? maximumDrawdown = null,Object? sharpeRatio = null,}) {
  return _then(_self.copyWith(
bestCase: null == bestCase ? _self.bestCase : bestCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,expectedCase: null == expectedCase ? _self.expectedCase : expectedCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,worstCase: null == worstCase ? _self.worstCase : worstCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,probabilityOfProfit: null == probabilityOfProfit ? _self.probabilityOfProfit : probabilityOfProfit // ignore: cast_nullable_to_non_nullable
as double,expectedValue: null == expectedValue ? _self.expectedValue : expectedValue // ignore: cast_nullable_to_non_nullable
as double,maximumDrawdown: null == maximumDrawdown ? _self.maximumDrawdown : maximumDrawdown // ignore: cast_nullable_to_non_nullable
as double,sharpeRatio: null == sharpeRatio ? _self.sharpeRatio : sharpeRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get bestCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.bestCase, (value) {
    return _then(_self.copyWith(bestCase: value));
  });
}/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get expectedCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.expectedCase, (value) {
    return _then(_self.copyWith(expectedCase: value));
  });
}/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get worstCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.worstCase, (value) {
    return _then(_self.copyWith(worstCase: value));
  });
}
}


/// Adds pattern-matching-related methods to [StatisticalScenarios].
extension StatisticalScenariosPatterns on StatisticalScenarios {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatisticalScenarios value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatisticalScenarios() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatisticalScenarios value)  $default,){
final _that = this;
switch (_that) {
case _StatisticalScenarios():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatisticalScenarios value)?  $default,){
final _that = this;
switch (_that) {
case _StatisticalScenarios() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScenarioOutcome bestCase,  ScenarioOutcome expectedCase,  ScenarioOutcome worstCase,  double probabilityOfProfit,  double expectedValue,  double maximumDrawdown,  double sharpeRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatisticalScenarios() when $default != null:
return $default(_that.bestCase,_that.expectedCase,_that.worstCase,_that.probabilityOfProfit,_that.expectedValue,_that.maximumDrawdown,_that.sharpeRatio);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScenarioOutcome bestCase,  ScenarioOutcome expectedCase,  ScenarioOutcome worstCase,  double probabilityOfProfit,  double expectedValue,  double maximumDrawdown,  double sharpeRatio)  $default,) {final _that = this;
switch (_that) {
case _StatisticalScenarios():
return $default(_that.bestCase,_that.expectedCase,_that.worstCase,_that.probabilityOfProfit,_that.expectedValue,_that.maximumDrawdown,_that.sharpeRatio);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScenarioOutcome bestCase,  ScenarioOutcome expectedCase,  ScenarioOutcome worstCase,  double probabilityOfProfit,  double expectedValue,  double maximumDrawdown,  double sharpeRatio)?  $default,) {final _that = this;
switch (_that) {
case _StatisticalScenarios() when $default != null:
return $default(_that.bestCase,_that.expectedCase,_that.worstCase,_that.probabilityOfProfit,_that.expectedValue,_that.maximumDrawdown,_that.sharpeRatio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatisticalScenarios implements StatisticalScenarios {
  const _StatisticalScenarios({required this.bestCase, required this.expectedCase, required this.worstCase, required this.probabilityOfProfit, required this.expectedValue, required this.maximumDrawdown, required this.sharpeRatio});
  factory _StatisticalScenarios.fromJson(Map<String, dynamic> json) => _$StatisticalScenariosFromJson(json);

@override final  ScenarioOutcome bestCase;
@override final  ScenarioOutcome expectedCase;
@override final  ScenarioOutcome worstCase;
@override final  double probabilityOfProfit;
@override final  double expectedValue;
@override final  double maximumDrawdown;
@override final  double sharpeRatio;

/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatisticalScenariosCopyWith<_StatisticalScenarios> get copyWith => __$StatisticalScenariosCopyWithImpl<_StatisticalScenarios>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatisticalScenariosToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatisticalScenarios&&(identical(other.bestCase, bestCase) || other.bestCase == bestCase)&&(identical(other.expectedCase, expectedCase) || other.expectedCase == expectedCase)&&(identical(other.worstCase, worstCase) || other.worstCase == worstCase)&&(identical(other.probabilityOfProfit, probabilityOfProfit) || other.probabilityOfProfit == probabilityOfProfit)&&(identical(other.expectedValue, expectedValue) || other.expectedValue == expectedValue)&&(identical(other.maximumDrawdown, maximumDrawdown) || other.maximumDrawdown == maximumDrawdown)&&(identical(other.sharpeRatio, sharpeRatio) || other.sharpeRatio == sharpeRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bestCase,expectedCase,worstCase,probabilityOfProfit,expectedValue,maximumDrawdown,sharpeRatio);

@override
String toString() {
  return 'StatisticalScenarios(bestCase: $bestCase, expectedCase: $expectedCase, worstCase: $worstCase, probabilityOfProfit: $probabilityOfProfit, expectedValue: $expectedValue, maximumDrawdown: $maximumDrawdown, sharpeRatio: $sharpeRatio)';
}


}

/// @nodoc
abstract mixin class _$StatisticalScenariosCopyWith<$Res> implements $StatisticalScenariosCopyWith<$Res> {
  factory _$StatisticalScenariosCopyWith(_StatisticalScenarios value, $Res Function(_StatisticalScenarios) _then) = __$StatisticalScenariosCopyWithImpl;
@override @useResult
$Res call({
 ScenarioOutcome bestCase, ScenarioOutcome expectedCase, ScenarioOutcome worstCase, double probabilityOfProfit, double expectedValue, double maximumDrawdown, double sharpeRatio
});


@override $ScenarioOutcomeCopyWith<$Res> get bestCase;@override $ScenarioOutcomeCopyWith<$Res> get expectedCase;@override $ScenarioOutcomeCopyWith<$Res> get worstCase;

}
/// @nodoc
class __$StatisticalScenariosCopyWithImpl<$Res>
    implements _$StatisticalScenariosCopyWith<$Res> {
  __$StatisticalScenariosCopyWithImpl(this._self, this._then);

  final _StatisticalScenarios _self;
  final $Res Function(_StatisticalScenarios) _then;

/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bestCase = null,Object? expectedCase = null,Object? worstCase = null,Object? probabilityOfProfit = null,Object? expectedValue = null,Object? maximumDrawdown = null,Object? sharpeRatio = null,}) {
  return _then(_StatisticalScenarios(
bestCase: null == bestCase ? _self.bestCase : bestCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,expectedCase: null == expectedCase ? _self.expectedCase : expectedCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,worstCase: null == worstCase ? _self.worstCase : worstCase // ignore: cast_nullable_to_non_nullable
as ScenarioOutcome,probabilityOfProfit: null == probabilityOfProfit ? _self.probabilityOfProfit : probabilityOfProfit // ignore: cast_nullable_to_non_nullable
as double,expectedValue: null == expectedValue ? _self.expectedValue : expectedValue // ignore: cast_nullable_to_non_nullable
as double,maximumDrawdown: null == maximumDrawdown ? _self.maximumDrawdown : maximumDrawdown // ignore: cast_nullable_to_non_nullable
as double,sharpeRatio: null == sharpeRatio ? _self.sharpeRatio : sharpeRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get bestCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.bestCase, (value) {
    return _then(_self.copyWith(bestCase: value));
  });
}/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get expectedCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.expectedCase, (value) {
    return _then(_self.copyWith(expectedCase: value));
  });
}/// Create a copy of StatisticalScenarios
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<$Res> get worstCase {
  
  return $ScenarioOutcomeCopyWith<$Res>(_self.worstCase, (value) {
    return _then(_self.copyWith(worstCase: value));
  });
}
}


/// @nodoc
mixin _$ScenarioOutcome {

 double get returnPercentage; double get probability; int get timeToRealizationDays; String get description;
/// Create a copy of ScenarioOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScenarioOutcomeCopyWith<ScenarioOutcome> get copyWith => _$ScenarioOutcomeCopyWithImpl<ScenarioOutcome>(this as ScenarioOutcome, _$identity);

  /// Serializes this ScenarioOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScenarioOutcome&&(identical(other.returnPercentage, returnPercentage) || other.returnPercentage == returnPercentage)&&(identical(other.probability, probability) || other.probability == probability)&&(identical(other.timeToRealizationDays, timeToRealizationDays) || other.timeToRealizationDays == timeToRealizationDays)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnPercentage,probability,timeToRealizationDays,description);

@override
String toString() {
  return 'ScenarioOutcome(returnPercentage: $returnPercentage, probability: $probability, timeToRealizationDays: $timeToRealizationDays, description: $description)';
}


}

/// @nodoc
abstract mixin class $ScenarioOutcomeCopyWith<$Res>  {
  factory $ScenarioOutcomeCopyWith(ScenarioOutcome value, $Res Function(ScenarioOutcome) _then) = _$ScenarioOutcomeCopyWithImpl;
@useResult
$Res call({
 double returnPercentage, double probability, int timeToRealizationDays, String description
});




}
/// @nodoc
class _$ScenarioOutcomeCopyWithImpl<$Res>
    implements $ScenarioOutcomeCopyWith<$Res> {
  _$ScenarioOutcomeCopyWithImpl(this._self, this._then);

  final ScenarioOutcome _self;
  final $Res Function(ScenarioOutcome) _then;

/// Create a copy of ScenarioOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? returnPercentage = null,Object? probability = null,Object? timeToRealizationDays = null,Object? description = null,}) {
  return _then(_self.copyWith(
returnPercentage: null == returnPercentage ? _self.returnPercentage : returnPercentage // ignore: cast_nullable_to_non_nullable
as double,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,timeToRealizationDays: null == timeToRealizationDays ? _self.timeToRealizationDays : timeToRealizationDays // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScenarioOutcome].
extension ScenarioOutcomePatterns on ScenarioOutcome {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScenarioOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScenarioOutcome() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScenarioOutcome value)  $default,){
final _that = this;
switch (_that) {
case _ScenarioOutcome():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScenarioOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _ScenarioOutcome() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double returnPercentage,  double probability,  int timeToRealizationDays,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScenarioOutcome() when $default != null:
return $default(_that.returnPercentage,_that.probability,_that.timeToRealizationDays,_that.description);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double returnPercentage,  double probability,  int timeToRealizationDays,  String description)  $default,) {final _that = this;
switch (_that) {
case _ScenarioOutcome():
return $default(_that.returnPercentage,_that.probability,_that.timeToRealizationDays,_that.description);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double returnPercentage,  double probability,  int timeToRealizationDays,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ScenarioOutcome() when $default != null:
return $default(_that.returnPercentage,_that.probability,_that.timeToRealizationDays,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScenarioOutcome implements ScenarioOutcome {
  const _ScenarioOutcome({required this.returnPercentage, required this.probability, required this.timeToRealizationDays, required this.description});
  factory _ScenarioOutcome.fromJson(Map<String, dynamic> json) => _$ScenarioOutcomeFromJson(json);

@override final  double returnPercentage;
@override final  double probability;
@override final  int timeToRealizationDays;
@override final  String description;

/// Create a copy of ScenarioOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScenarioOutcomeCopyWith<_ScenarioOutcome> get copyWith => __$ScenarioOutcomeCopyWithImpl<_ScenarioOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScenarioOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScenarioOutcome&&(identical(other.returnPercentage, returnPercentage) || other.returnPercentage == returnPercentage)&&(identical(other.probability, probability) || other.probability == probability)&&(identical(other.timeToRealizationDays, timeToRealizationDays) || other.timeToRealizationDays == timeToRealizationDays)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnPercentage,probability,timeToRealizationDays,description);

@override
String toString() {
  return 'ScenarioOutcome(returnPercentage: $returnPercentage, probability: $probability, timeToRealizationDays: $timeToRealizationDays, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ScenarioOutcomeCopyWith<$Res> implements $ScenarioOutcomeCopyWith<$Res> {
  factory _$ScenarioOutcomeCopyWith(_ScenarioOutcome value, $Res Function(_ScenarioOutcome) _then) = __$ScenarioOutcomeCopyWithImpl;
@override @useResult
$Res call({
 double returnPercentage, double probability, int timeToRealizationDays, String description
});




}
/// @nodoc
class __$ScenarioOutcomeCopyWithImpl<$Res>
    implements _$ScenarioOutcomeCopyWith<$Res> {
  __$ScenarioOutcomeCopyWithImpl(this._self, this._then);

  final _ScenarioOutcome _self;
  final $Res Function(_ScenarioOutcome) _then;

/// Create a copy of ScenarioOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? returnPercentage = null,Object? probability = null,Object? timeToRealizationDays = null,Object? description = null,}) {
  return _then(_ScenarioOutcome(
returnPercentage: null == returnPercentage ? _self.returnPercentage : returnPercentage // ignore: cast_nullable_to_non_nullable
as double,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,timeToRealizationDays: null == timeToRealizationDays ? _self.timeToRealizationDays : timeToRealizationDays // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
