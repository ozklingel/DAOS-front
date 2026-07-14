// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardStats {

 int get criticalCount; int get openCount; int get overdueCount; int get completedThisWeek;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&(identical(other.criticalCount, criticalCount) || other.criticalCount == criticalCount)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek));
}


@override
int get hashCode => Object.hash(runtimeType,criticalCount,openCount,overdueCount,completedThisWeek);

@override
String toString() {
  return 'DashboardStats(criticalCount: $criticalCount, openCount: $openCount, overdueCount: $overdueCount, completedThisWeek: $completedThisWeek)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
 int criticalCount, int openCount, int overdueCount, int completedThisWeek
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? criticalCount = null,Object? openCount = null,Object? overdueCount = null,Object? completedThisWeek = null,}) {
  return _then(_self.copyWith(
criticalCount: null == criticalCount ? _self.criticalCount : criticalCount // ignore: cast_nullable_to_non_nullable
as int,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int criticalCount,  int openCount,  int overdueCount,  int completedThisWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.criticalCount,_that.openCount,_that.overdueCount,_that.completedThisWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int criticalCount,  int openCount,  int overdueCount,  int completedThisWeek)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.criticalCount,_that.openCount,_that.overdueCount,_that.completedThisWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int criticalCount,  int openCount,  int overdueCount,  int completedThisWeek)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.criticalCount,_that.openCount,_that.overdueCount,_that.completedThisWeek);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardStats implements DashboardStats {
  const _DashboardStats({this.criticalCount = 0, this.openCount = 0, this.overdueCount = 0, this.completedThisWeek = 0});
  

@override@JsonKey() final  int criticalCount;
@override@JsonKey() final  int openCount;
@override@JsonKey() final  int overdueCount;
@override@JsonKey() final  int completedThisWeek;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&(identical(other.criticalCount, criticalCount) || other.criticalCount == criticalCount)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek));
}


@override
int get hashCode => Object.hash(runtimeType,criticalCount,openCount,overdueCount,completedThisWeek);

@override
String toString() {
  return 'DashboardStats(criticalCount: $criticalCount, openCount: $openCount, overdueCount: $overdueCount, completedThisWeek: $completedThisWeek)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int criticalCount, int openCount, int overdueCount, int completedThisWeek
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? criticalCount = null,Object? openCount = null,Object? overdueCount = null,Object? completedThisWeek = null,}) {
  return _then(_DashboardStats(
criticalCount: null == criticalCount ? _self.criticalCount : criticalCount // ignore: cast_nullable_to_non_nullable
as int,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DashboardData {

 DashboardStats get stats; String get briefSummary; List<Task> get recentHighPriorityTasks;
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardDataCopyWith<DashboardData> get copyWith => _$DashboardDataCopyWithImpl<DashboardData>(this as DashboardData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardData&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.briefSummary, briefSummary) || other.briefSummary == briefSummary)&&const DeepCollectionEquality().equals(other.recentHighPriorityTasks, recentHighPriorityTasks));
}


@override
int get hashCode => Object.hash(runtimeType,stats,briefSummary,const DeepCollectionEquality().hash(recentHighPriorityTasks));

@override
String toString() {
  return 'DashboardData(stats: $stats, briefSummary: $briefSummary, recentHighPriorityTasks: $recentHighPriorityTasks)';
}


}

/// @nodoc
abstract mixin class $DashboardDataCopyWith<$Res>  {
  factory $DashboardDataCopyWith(DashboardData value, $Res Function(DashboardData) _then) = _$DashboardDataCopyWithImpl;
@useResult
$Res call({
 DashboardStats stats, String briefSummary, List<Task> recentHighPriorityTasks
});


$DashboardStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$DashboardDataCopyWithImpl<$Res>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._self, this._then);

  final DashboardData _self;
  final $Res Function(DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stats = null,Object? briefSummary = null,Object? recentHighPriorityTasks = null,}) {
  return _then(_self.copyWith(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStats,briefSummary: null == briefSummary ? _self.briefSummary : briefSummary // ignore: cast_nullable_to_non_nullable
as String,recentHighPriorityTasks: null == recentHighPriorityTasks ? _self.recentHighPriorityTasks : recentHighPriorityTasks // ignore: cast_nullable_to_non_nullable
as List<Task>,
  ));
}
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<$Res> get stats {
  
  return $DashboardStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardData].
extension DashboardDataPatterns on DashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardData value)  $default,){
final _that = this;
switch (_that) {
case _DashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardStats stats,  String briefSummary,  List<Task> recentHighPriorityTasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.stats,_that.briefSummary,_that.recentHighPriorityTasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardStats stats,  String briefSummary,  List<Task> recentHighPriorityTasks)  $default,) {final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that.stats,_that.briefSummary,_that.recentHighPriorityTasks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardStats stats,  String briefSummary,  List<Task> recentHighPriorityTasks)?  $default,) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.stats,_that.briefSummary,_that.recentHighPriorityTasks);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardData implements DashboardData {
  const _DashboardData({required this.stats, required this.briefSummary, final  List<Task> recentHighPriorityTasks = const []}): _recentHighPriorityTasks = recentHighPriorityTasks;
  

@override final  DashboardStats stats;
@override final  String briefSummary;
 final  List<Task> _recentHighPriorityTasks;
@override@JsonKey() List<Task> get recentHighPriorityTasks {
  if (_recentHighPriorityTasks is EqualUnmodifiableListView) return _recentHighPriorityTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentHighPriorityTasks);
}


/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardDataCopyWith<_DashboardData> get copyWith => __$DashboardDataCopyWithImpl<_DashboardData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardData&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.briefSummary, briefSummary) || other.briefSummary == briefSummary)&&const DeepCollectionEquality().equals(other._recentHighPriorityTasks, _recentHighPriorityTasks));
}


@override
int get hashCode => Object.hash(runtimeType,stats,briefSummary,const DeepCollectionEquality().hash(_recentHighPriorityTasks));

@override
String toString() {
  return 'DashboardData(stats: $stats, briefSummary: $briefSummary, recentHighPriorityTasks: $recentHighPriorityTasks)';
}


}

/// @nodoc
abstract mixin class _$DashboardDataCopyWith<$Res> implements $DashboardDataCopyWith<$Res> {
  factory _$DashboardDataCopyWith(_DashboardData value, $Res Function(_DashboardData) _then) = __$DashboardDataCopyWithImpl;
@override @useResult
$Res call({
 DashboardStats stats, String briefSummary, List<Task> recentHighPriorityTasks
});


@override $DashboardStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$DashboardDataCopyWithImpl<$Res>
    implements _$DashboardDataCopyWith<$Res> {
  __$DashboardDataCopyWithImpl(this._self, this._then);

  final _DashboardData _self;
  final $Res Function(_DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stats = null,Object? briefSummary = null,Object? recentHighPriorityTasks = null,}) {
  return _then(_DashboardData(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStats,briefSummary: null == briefSummary ? _self.briefSummary : briefSummary // ignore: cast_nullable_to_non_nullable
as String,recentHighPriorityTasks: null == recentHighPriorityTasks ? _self._recentHighPriorityTasks : recentHighPriorityTasks // ignore: cast_nullable_to_non_nullable
as List<Task>,
  ));
}

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<$Res> get stats {
  
  return $DashboardStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
