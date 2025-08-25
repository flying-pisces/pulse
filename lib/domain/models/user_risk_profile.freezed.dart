// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_risk_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserRiskProfile {

 String get userId; RiskArchetype get archetype; int get riskRewardAppetite;// 0-100 scale
 double get maxPositionSize;// Percentage of portfolio
 double get maxDailyLoss;// Percentage of portfolio
 int get maxSignalsPerDay; List<String> get preferredSignalTypes; Map<String, double> get riskTolerance;// Signal type -> risk multiplier
 DateTime get createdAt; DateTime get updatedAt; int get totalSignalsAccepted; int get totalSignalsDeclined; double get averageSignalPerformance; List<UserRiskBehavior> get behaviorHistory;
/// Create a copy of UserRiskProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRiskProfileCopyWith<UserRiskProfile> get copyWith => _$UserRiskProfileCopyWithImpl<UserRiskProfile>(this as UserRiskProfile, _$identity);

  /// Serializes this UserRiskProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRiskProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.archetype, archetype) || other.archetype == archetype)&&(identical(other.riskRewardAppetite, riskRewardAppetite) || other.riskRewardAppetite == riskRewardAppetite)&&(identical(other.maxPositionSize, maxPositionSize) || other.maxPositionSize == maxPositionSize)&&(identical(other.maxDailyLoss, maxDailyLoss) || other.maxDailyLoss == maxDailyLoss)&&(identical(other.maxSignalsPerDay, maxSignalsPerDay) || other.maxSignalsPerDay == maxSignalsPerDay)&&const DeepCollectionEquality().equals(other.preferredSignalTypes, preferredSignalTypes)&&const DeepCollectionEquality().equals(other.riskTolerance, riskTolerance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.totalSignalsAccepted, totalSignalsAccepted) || other.totalSignalsAccepted == totalSignalsAccepted)&&(identical(other.totalSignalsDeclined, totalSignalsDeclined) || other.totalSignalsDeclined == totalSignalsDeclined)&&(identical(other.averageSignalPerformance, averageSignalPerformance) || other.averageSignalPerformance == averageSignalPerformance)&&const DeepCollectionEquality().equals(other.behaviorHistory, behaviorHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,archetype,riskRewardAppetite,maxPositionSize,maxDailyLoss,maxSignalsPerDay,const DeepCollectionEquality().hash(preferredSignalTypes),const DeepCollectionEquality().hash(riskTolerance),createdAt,updatedAt,totalSignalsAccepted,totalSignalsDeclined,averageSignalPerformance,const DeepCollectionEquality().hash(behaviorHistory));

@override
String toString() {
  return 'UserRiskProfile(userId: $userId, archetype: $archetype, riskRewardAppetite: $riskRewardAppetite, maxPositionSize: $maxPositionSize, maxDailyLoss: $maxDailyLoss, maxSignalsPerDay: $maxSignalsPerDay, preferredSignalTypes: $preferredSignalTypes, riskTolerance: $riskTolerance, createdAt: $createdAt, updatedAt: $updatedAt, totalSignalsAccepted: $totalSignalsAccepted, totalSignalsDeclined: $totalSignalsDeclined, averageSignalPerformance: $averageSignalPerformance, behaviorHistory: $behaviorHistory)';
}


}

/// @nodoc
abstract mixin class $UserRiskProfileCopyWith<$Res>  {
  factory $UserRiskProfileCopyWith(UserRiskProfile value, $Res Function(UserRiskProfile) _then) = _$UserRiskProfileCopyWithImpl;
@useResult
$Res call({
 String userId, RiskArchetype archetype, int riskRewardAppetite, double maxPositionSize, double maxDailyLoss, int maxSignalsPerDay, List<String> preferredSignalTypes, Map<String, double> riskTolerance, DateTime createdAt, DateTime updatedAt, int totalSignalsAccepted, int totalSignalsDeclined, double averageSignalPerformance, List<UserRiskBehavior> behaviorHistory
});




}
/// @nodoc
class _$UserRiskProfileCopyWithImpl<$Res>
    implements $UserRiskProfileCopyWith<$Res> {
  _$UserRiskProfileCopyWithImpl(this._self, this._then);

  final UserRiskProfile _self;
  final $Res Function(UserRiskProfile) _then;

/// Create a copy of UserRiskProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? archetype = null,Object? riskRewardAppetite = null,Object? maxPositionSize = null,Object? maxDailyLoss = null,Object? maxSignalsPerDay = null,Object? preferredSignalTypes = null,Object? riskTolerance = null,Object? createdAt = null,Object? updatedAt = null,Object? totalSignalsAccepted = null,Object? totalSignalsDeclined = null,Object? averageSignalPerformance = null,Object? behaviorHistory = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,archetype: null == archetype ? _self.archetype : archetype // ignore: cast_nullable_to_non_nullable
as RiskArchetype,riskRewardAppetite: null == riskRewardAppetite ? _self.riskRewardAppetite : riskRewardAppetite // ignore: cast_nullable_to_non_nullable
as int,maxPositionSize: null == maxPositionSize ? _self.maxPositionSize : maxPositionSize // ignore: cast_nullable_to_non_nullable
as double,maxDailyLoss: null == maxDailyLoss ? _self.maxDailyLoss : maxDailyLoss // ignore: cast_nullable_to_non_nullable
as double,maxSignalsPerDay: null == maxSignalsPerDay ? _self.maxSignalsPerDay : maxSignalsPerDay // ignore: cast_nullable_to_non_nullable
as int,preferredSignalTypes: null == preferredSignalTypes ? _self.preferredSignalTypes : preferredSignalTypes // ignore: cast_nullable_to_non_nullable
as List<String>,riskTolerance: null == riskTolerance ? _self.riskTolerance : riskTolerance // ignore: cast_nullable_to_non_nullable
as Map<String, double>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalSignalsAccepted: null == totalSignalsAccepted ? _self.totalSignalsAccepted : totalSignalsAccepted // ignore: cast_nullable_to_non_nullable
as int,totalSignalsDeclined: null == totalSignalsDeclined ? _self.totalSignalsDeclined : totalSignalsDeclined // ignore: cast_nullable_to_non_nullable
as int,averageSignalPerformance: null == averageSignalPerformance ? _self.averageSignalPerformance : averageSignalPerformance // ignore: cast_nullable_to_non_nullable
as double,behaviorHistory: null == behaviorHistory ? _self.behaviorHistory : behaviorHistory // ignore: cast_nullable_to_non_nullable
as List<UserRiskBehavior>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRiskProfile].
extension UserRiskProfilePatterns on UserRiskProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRiskProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRiskProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRiskProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserRiskProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRiskProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserRiskProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  RiskArchetype archetype,  int riskRewardAppetite,  double maxPositionSize,  double maxDailyLoss,  int maxSignalsPerDay,  List<String> preferredSignalTypes,  Map<String, double> riskTolerance,  DateTime createdAt,  DateTime updatedAt,  int totalSignalsAccepted,  int totalSignalsDeclined,  double averageSignalPerformance,  List<UserRiskBehavior> behaviorHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRiskProfile() when $default != null:
return $default(_that.userId,_that.archetype,_that.riskRewardAppetite,_that.maxPositionSize,_that.maxDailyLoss,_that.maxSignalsPerDay,_that.preferredSignalTypes,_that.riskTolerance,_that.createdAt,_that.updatedAt,_that.totalSignalsAccepted,_that.totalSignalsDeclined,_that.averageSignalPerformance,_that.behaviorHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  RiskArchetype archetype,  int riskRewardAppetite,  double maxPositionSize,  double maxDailyLoss,  int maxSignalsPerDay,  List<String> preferredSignalTypes,  Map<String, double> riskTolerance,  DateTime createdAt,  DateTime updatedAt,  int totalSignalsAccepted,  int totalSignalsDeclined,  double averageSignalPerformance,  List<UserRiskBehavior> behaviorHistory)  $default,) {final _that = this;
switch (_that) {
case _UserRiskProfile():
return $default(_that.userId,_that.archetype,_that.riskRewardAppetite,_that.maxPositionSize,_that.maxDailyLoss,_that.maxSignalsPerDay,_that.preferredSignalTypes,_that.riskTolerance,_that.createdAt,_that.updatedAt,_that.totalSignalsAccepted,_that.totalSignalsDeclined,_that.averageSignalPerformance,_that.behaviorHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  RiskArchetype archetype,  int riskRewardAppetite,  double maxPositionSize,  double maxDailyLoss,  int maxSignalsPerDay,  List<String> preferredSignalTypes,  Map<String, double> riskTolerance,  DateTime createdAt,  DateTime updatedAt,  int totalSignalsAccepted,  int totalSignalsDeclined,  double averageSignalPerformance,  List<UserRiskBehavior> behaviorHistory)?  $default,) {final _that = this;
switch (_that) {
case _UserRiskProfile() when $default != null:
return $default(_that.userId,_that.archetype,_that.riskRewardAppetite,_that.maxPositionSize,_that.maxDailyLoss,_that.maxSignalsPerDay,_that.preferredSignalTypes,_that.riskTolerance,_that.createdAt,_that.updatedAt,_that.totalSignalsAccepted,_that.totalSignalsDeclined,_that.averageSignalPerformance,_that.behaviorHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRiskProfile implements UserRiskProfile {
  const _UserRiskProfile({required this.userId, required this.archetype, required this.riskRewardAppetite, required this.maxPositionSize, required this.maxDailyLoss, required this.maxSignalsPerDay, required final  List<String> preferredSignalTypes, required final  Map<String, double> riskTolerance, required this.createdAt, required this.updatedAt, this.totalSignalsAccepted = 0, this.totalSignalsDeclined = 0, this.averageSignalPerformance = 0.0, final  List<UserRiskBehavior> behaviorHistory = const []}): _preferredSignalTypes = preferredSignalTypes,_riskTolerance = riskTolerance,_behaviorHistory = behaviorHistory;
  factory _UserRiskProfile.fromJson(Map<String, dynamic> json) => _$UserRiskProfileFromJson(json);

@override final  String userId;
@override final  RiskArchetype archetype;
@override final  int riskRewardAppetite;
// 0-100 scale
@override final  double maxPositionSize;
// Percentage of portfolio
@override final  double maxDailyLoss;
// Percentage of portfolio
@override final  int maxSignalsPerDay;
 final  List<String> _preferredSignalTypes;
@override List<String> get preferredSignalTypes {
  if (_preferredSignalTypes is EqualUnmodifiableListView) return _preferredSignalTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredSignalTypes);
}

 final  Map<String, double> _riskTolerance;
@override Map<String, double> get riskTolerance {
  if (_riskTolerance is EqualUnmodifiableMapView) return _riskTolerance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_riskTolerance);
}

// Signal type -> risk multiplier
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  int totalSignalsAccepted;
@override@JsonKey() final  int totalSignalsDeclined;
@override@JsonKey() final  double averageSignalPerformance;
 final  List<UserRiskBehavior> _behaviorHistory;
@override@JsonKey() List<UserRiskBehavior> get behaviorHistory {
  if (_behaviorHistory is EqualUnmodifiableListView) return _behaviorHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_behaviorHistory);
}


/// Create a copy of UserRiskProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRiskProfileCopyWith<_UserRiskProfile> get copyWith => __$UserRiskProfileCopyWithImpl<_UserRiskProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRiskProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRiskProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.archetype, archetype) || other.archetype == archetype)&&(identical(other.riskRewardAppetite, riskRewardAppetite) || other.riskRewardAppetite == riskRewardAppetite)&&(identical(other.maxPositionSize, maxPositionSize) || other.maxPositionSize == maxPositionSize)&&(identical(other.maxDailyLoss, maxDailyLoss) || other.maxDailyLoss == maxDailyLoss)&&(identical(other.maxSignalsPerDay, maxSignalsPerDay) || other.maxSignalsPerDay == maxSignalsPerDay)&&const DeepCollectionEquality().equals(other._preferredSignalTypes, _preferredSignalTypes)&&const DeepCollectionEquality().equals(other._riskTolerance, _riskTolerance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.totalSignalsAccepted, totalSignalsAccepted) || other.totalSignalsAccepted == totalSignalsAccepted)&&(identical(other.totalSignalsDeclined, totalSignalsDeclined) || other.totalSignalsDeclined == totalSignalsDeclined)&&(identical(other.averageSignalPerformance, averageSignalPerformance) || other.averageSignalPerformance == averageSignalPerformance)&&const DeepCollectionEquality().equals(other._behaviorHistory, _behaviorHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,archetype,riskRewardAppetite,maxPositionSize,maxDailyLoss,maxSignalsPerDay,const DeepCollectionEquality().hash(_preferredSignalTypes),const DeepCollectionEquality().hash(_riskTolerance),createdAt,updatedAt,totalSignalsAccepted,totalSignalsDeclined,averageSignalPerformance,const DeepCollectionEquality().hash(_behaviorHistory));

@override
String toString() {
  return 'UserRiskProfile(userId: $userId, archetype: $archetype, riskRewardAppetite: $riskRewardAppetite, maxPositionSize: $maxPositionSize, maxDailyLoss: $maxDailyLoss, maxSignalsPerDay: $maxSignalsPerDay, preferredSignalTypes: $preferredSignalTypes, riskTolerance: $riskTolerance, createdAt: $createdAt, updatedAt: $updatedAt, totalSignalsAccepted: $totalSignalsAccepted, totalSignalsDeclined: $totalSignalsDeclined, averageSignalPerformance: $averageSignalPerformance, behaviorHistory: $behaviorHistory)';
}


}

/// @nodoc
abstract mixin class _$UserRiskProfileCopyWith<$Res> implements $UserRiskProfileCopyWith<$Res> {
  factory _$UserRiskProfileCopyWith(_UserRiskProfile value, $Res Function(_UserRiskProfile) _then) = __$UserRiskProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, RiskArchetype archetype, int riskRewardAppetite, double maxPositionSize, double maxDailyLoss, int maxSignalsPerDay, List<String> preferredSignalTypes, Map<String, double> riskTolerance, DateTime createdAt, DateTime updatedAt, int totalSignalsAccepted, int totalSignalsDeclined, double averageSignalPerformance, List<UserRiskBehavior> behaviorHistory
});




}
/// @nodoc
class __$UserRiskProfileCopyWithImpl<$Res>
    implements _$UserRiskProfileCopyWith<$Res> {
  __$UserRiskProfileCopyWithImpl(this._self, this._then);

  final _UserRiskProfile _self;
  final $Res Function(_UserRiskProfile) _then;

/// Create a copy of UserRiskProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? archetype = null,Object? riskRewardAppetite = null,Object? maxPositionSize = null,Object? maxDailyLoss = null,Object? maxSignalsPerDay = null,Object? preferredSignalTypes = null,Object? riskTolerance = null,Object? createdAt = null,Object? updatedAt = null,Object? totalSignalsAccepted = null,Object? totalSignalsDeclined = null,Object? averageSignalPerformance = null,Object? behaviorHistory = null,}) {
  return _then(_UserRiskProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,archetype: null == archetype ? _self.archetype : archetype // ignore: cast_nullable_to_non_nullable
as RiskArchetype,riskRewardAppetite: null == riskRewardAppetite ? _self.riskRewardAppetite : riskRewardAppetite // ignore: cast_nullable_to_non_nullable
as int,maxPositionSize: null == maxPositionSize ? _self.maxPositionSize : maxPositionSize // ignore: cast_nullable_to_non_nullable
as double,maxDailyLoss: null == maxDailyLoss ? _self.maxDailyLoss : maxDailyLoss // ignore: cast_nullable_to_non_nullable
as double,maxSignalsPerDay: null == maxSignalsPerDay ? _self.maxSignalsPerDay : maxSignalsPerDay // ignore: cast_nullable_to_non_nullable
as int,preferredSignalTypes: null == preferredSignalTypes ? _self._preferredSignalTypes : preferredSignalTypes // ignore: cast_nullable_to_non_nullable
as List<String>,riskTolerance: null == riskTolerance ? _self._riskTolerance : riskTolerance // ignore: cast_nullable_to_non_nullable
as Map<String, double>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalSignalsAccepted: null == totalSignalsAccepted ? _self.totalSignalsAccepted : totalSignalsAccepted // ignore: cast_nullable_to_non_nullable
as int,totalSignalsDeclined: null == totalSignalsDeclined ? _self.totalSignalsDeclined : totalSignalsDeclined // ignore: cast_nullable_to_non_nullable
as int,averageSignalPerformance: null == averageSignalPerformance ? _self.averageSignalPerformance : averageSignalPerformance // ignore: cast_nullable_to_non_nullable
as double,behaviorHistory: null == behaviorHistory ? _self._behaviorHistory : behaviorHistory // ignore: cast_nullable_to_non_nullable
as List<UserRiskBehavior>,
  ));
}


}


/// @nodoc
mixin _$UserRiskBehavior {

 DateTime get timestamp; String get signalId; String get action;// 'accepted', 'declined', 'modified'
 double get signalRiskScore; double get userRiskScoreAtTime; Map<String, dynamic>? get metadata;
/// Create a copy of UserRiskBehavior
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRiskBehaviorCopyWith<UserRiskBehavior> get copyWith => _$UserRiskBehaviorCopyWithImpl<UserRiskBehavior>(this as UserRiskBehavior, _$identity);

  /// Serializes this UserRiskBehavior to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRiskBehavior&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.signalId, signalId) || other.signalId == signalId)&&(identical(other.action, action) || other.action == action)&&(identical(other.signalRiskScore, signalRiskScore) || other.signalRiskScore == signalRiskScore)&&(identical(other.userRiskScoreAtTime, userRiskScoreAtTime) || other.userRiskScoreAtTime == userRiskScoreAtTime)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,signalId,action,signalRiskScore,userRiskScoreAtTime,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'UserRiskBehavior(timestamp: $timestamp, signalId: $signalId, action: $action, signalRiskScore: $signalRiskScore, userRiskScoreAtTime: $userRiskScoreAtTime, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $UserRiskBehaviorCopyWith<$Res>  {
  factory $UserRiskBehaviorCopyWith(UserRiskBehavior value, $Res Function(UserRiskBehavior) _then) = _$UserRiskBehaviorCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp, String signalId, String action, double signalRiskScore, double userRiskScoreAtTime, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$UserRiskBehaviorCopyWithImpl<$Res>
    implements $UserRiskBehaviorCopyWith<$Res> {
  _$UserRiskBehaviorCopyWithImpl(this._self, this._then);

  final UserRiskBehavior _self;
  final $Res Function(UserRiskBehavior) _then;

/// Create a copy of UserRiskBehavior
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? signalId = null,Object? action = null,Object? signalRiskScore = null,Object? userRiskScoreAtTime = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,signalId: null == signalId ? _self.signalId : signalId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,signalRiskScore: null == signalRiskScore ? _self.signalRiskScore : signalRiskScore // ignore: cast_nullable_to_non_nullable
as double,userRiskScoreAtTime: null == userRiskScoreAtTime ? _self.userRiskScoreAtTime : userRiskScoreAtTime // ignore: cast_nullable_to_non_nullable
as double,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRiskBehavior].
extension UserRiskBehaviorPatterns on UserRiskBehavior {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRiskBehavior value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRiskBehavior() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRiskBehavior value)  $default,){
final _that = this;
switch (_that) {
case _UserRiskBehavior():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRiskBehavior value)?  $default,){
final _that = this;
switch (_that) {
case _UserRiskBehavior() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timestamp,  String signalId,  String action,  double signalRiskScore,  double userRiskScoreAtTime,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRiskBehavior() when $default != null:
return $default(_that.timestamp,_that.signalId,_that.action,_that.signalRiskScore,_that.userRiskScoreAtTime,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timestamp,  String signalId,  String action,  double signalRiskScore,  double userRiskScoreAtTime,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _UserRiskBehavior():
return $default(_that.timestamp,_that.signalId,_that.action,_that.signalRiskScore,_that.userRiskScoreAtTime,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timestamp,  String signalId,  String action,  double signalRiskScore,  double userRiskScoreAtTime,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _UserRiskBehavior() when $default != null:
return $default(_that.timestamp,_that.signalId,_that.action,_that.signalRiskScore,_that.userRiskScoreAtTime,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRiskBehavior implements UserRiskBehavior {
  const _UserRiskBehavior({required this.timestamp, required this.signalId, required this.action, required this.signalRiskScore, required this.userRiskScoreAtTime, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _UserRiskBehavior.fromJson(Map<String, dynamic> json) => _$UserRiskBehaviorFromJson(json);

@override final  DateTime timestamp;
@override final  String signalId;
@override final  String action;
// 'accepted', 'declined', 'modified'
@override final  double signalRiskScore;
@override final  double userRiskScoreAtTime;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UserRiskBehavior
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRiskBehaviorCopyWith<_UserRiskBehavior> get copyWith => __$UserRiskBehaviorCopyWithImpl<_UserRiskBehavior>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRiskBehaviorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRiskBehavior&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.signalId, signalId) || other.signalId == signalId)&&(identical(other.action, action) || other.action == action)&&(identical(other.signalRiskScore, signalRiskScore) || other.signalRiskScore == signalRiskScore)&&(identical(other.userRiskScoreAtTime, userRiskScoreAtTime) || other.userRiskScoreAtTime == userRiskScoreAtTime)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,signalId,action,signalRiskScore,userRiskScoreAtTime,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'UserRiskBehavior(timestamp: $timestamp, signalId: $signalId, action: $action, signalRiskScore: $signalRiskScore, userRiskScoreAtTime: $userRiskScoreAtTime, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$UserRiskBehaviorCopyWith<$Res> implements $UserRiskBehaviorCopyWith<$Res> {
  factory _$UserRiskBehaviorCopyWith(_UserRiskBehavior value, $Res Function(_UserRiskBehavior) _then) = __$UserRiskBehaviorCopyWithImpl;
@override @useResult
$Res call({
 DateTime timestamp, String signalId, String action, double signalRiskScore, double userRiskScoreAtTime, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$UserRiskBehaviorCopyWithImpl<$Res>
    implements _$UserRiskBehaviorCopyWith<$Res> {
  __$UserRiskBehaviorCopyWithImpl(this._self, this._then);

  final _UserRiskBehavior _self;
  final $Res Function(_UserRiskBehavior) _then;

/// Create a copy of UserRiskBehavior
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? signalId = null,Object? action = null,Object? signalRiskScore = null,Object? userRiskScoreAtTime = null,Object? metadata = freezed,}) {
  return _then(_UserRiskBehavior(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,signalId: null == signalId ? _self.signalId : signalId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,signalRiskScore: null == signalRiskScore ? _self.signalRiskScore : signalRiskScore // ignore: cast_nullable_to_non_nullable
as double,userRiskScoreAtTime: null == userRiskScoreAtTime ? _self.userRiskScoreAtTime : userRiskScoreAtTime // ignore: cast_nullable_to_non_nullable
as double,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
