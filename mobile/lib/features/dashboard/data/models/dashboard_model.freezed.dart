// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardModel {

 DashboardStatsModel get stats; String get briefSummary; List<TaskModel> get recentHighPriorityTasks;
/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardModelCopyWith<DashboardModel> get copyWith => _$DashboardModelCopyWithImpl<DashboardModel>(this as DashboardModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardModel&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.briefSummary, briefSummary) || other.briefSummary == briefSummary)&&const DeepCollectionEquality().equals(other.recentHighPriorityTasks, recentHighPriorityTasks));
}


@override
int get hashCode => Object.hash(runtimeType,stats,briefSummary,const DeepCollectionEquality().hash(recentHighPriorityTasks));

@override
String toString() {
  return 'DashboardModel(stats: $stats, briefSummary: $briefSummary, recentHighPriorityTasks: $recentHighPriorityTasks)';
}


}

/// @nodoc
abstract mixin class $DashboardModelCopyWith<$Res>  {
  factory $DashboardModelCopyWith(DashboardModel value, $Res Function(DashboardModel) _then) = _$DashboardModelCopyWithImpl;
@useResult
$Res call({
 DashboardStatsModel stats, String briefSummary, List<TaskModel> recentHighPriorityTasks
});


$DashboardStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class _$DashboardModelCopyWithImpl<$Res>
    implements $DashboardModelCopyWith<$Res> {
  _$DashboardModelCopyWithImpl(this._self, this._then);

  final DashboardModel _self;
  final $Res Function(DashboardModel) _then;

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stats = null,Object? briefSummary = null,Object? recentHighPriorityTasks = null,}) {
  return _then(_self.copyWith(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStatsModel,briefSummary: null == briefSummary ? _self.briefSummary : briefSummary // ignore: cast_nullable_to_non_nullable
as String,recentHighPriorityTasks: null == recentHighPriorityTasks ? _self.recentHighPriorityTasks : recentHighPriorityTasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,
  ));
}
/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<$Res> get stats {
  
  return $DashboardStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardModel].
extension DashboardModelPatterns on DashboardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardStatsModel stats,  String briefSummary,  List<TaskModel> recentHighPriorityTasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardStatsModel stats,  String briefSummary,  List<TaskModel> recentHighPriorityTasks)  $default,) {final _that = this;
switch (_that) {
case _DashboardModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardStatsModel stats,  String briefSummary,  List<TaskModel> recentHighPriorityTasks)?  $default,) {final _that = this;
switch (_that) {
case _DashboardModel() when $default != null:
return $default(_that.stats,_that.briefSummary,_that.recentHighPriorityTasks);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardModel extends DashboardModel {
  const _DashboardModel({required this.stats, required this.briefSummary, final  List<TaskModel> recentHighPriorityTasks = const []}): _recentHighPriorityTasks = recentHighPriorityTasks,super._();
  

@override final  DashboardStatsModel stats;
@override final  String briefSummary;
 final  List<TaskModel> _recentHighPriorityTasks;
@override@JsonKey() List<TaskModel> get recentHighPriorityTasks {
  if (_recentHighPriorityTasks is EqualUnmodifiableListView) return _recentHighPriorityTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentHighPriorityTasks);
}


/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardModelCopyWith<_DashboardModel> get copyWith => __$DashboardModelCopyWithImpl<_DashboardModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardModel&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.briefSummary, briefSummary) || other.briefSummary == briefSummary)&&const DeepCollectionEquality().equals(other._recentHighPriorityTasks, _recentHighPriorityTasks));
}


@override
int get hashCode => Object.hash(runtimeType,stats,briefSummary,const DeepCollectionEquality().hash(_recentHighPriorityTasks));

@override
String toString() {
  return 'DashboardModel(stats: $stats, briefSummary: $briefSummary, recentHighPriorityTasks: $recentHighPriorityTasks)';
}


}

/// @nodoc
abstract mixin class _$DashboardModelCopyWith<$Res> implements $DashboardModelCopyWith<$Res> {
  factory _$DashboardModelCopyWith(_DashboardModel value, $Res Function(_DashboardModel) _then) = __$DashboardModelCopyWithImpl;
@override @useResult
$Res call({
 DashboardStatsModel stats, String briefSummary, List<TaskModel> recentHighPriorityTasks
});


@override $DashboardStatsModelCopyWith<$Res> get stats;

}
/// @nodoc
class __$DashboardModelCopyWithImpl<$Res>
    implements _$DashboardModelCopyWith<$Res> {
  __$DashboardModelCopyWithImpl(this._self, this._then);

  final _DashboardModel _self;
  final $Res Function(_DashboardModel) _then;

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stats = null,Object? briefSummary = null,Object? recentHighPriorityTasks = null,}) {
  return _then(_DashboardModel(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as DashboardStatsModel,briefSummary: null == briefSummary ? _self.briefSummary : briefSummary // ignore: cast_nullable_to_non_nullable
as String,recentHighPriorityTasks: null == recentHighPriorityTasks ? _self._recentHighPriorityTasks : recentHighPriorityTasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,
  ));
}

/// Create a copy of DashboardModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<$Res> get stats {
  
  return $DashboardStatsModelCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

/// @nodoc
mixin _$DashboardStatsModel {

 int get criticalCount; int get openCount; int get overdueCount; int get completedThisWeek;
/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith => _$DashboardStatsModelCopyWithImpl<DashboardStatsModel>(this as DashboardStatsModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStatsModel&&(identical(other.criticalCount, criticalCount) || other.criticalCount == criticalCount)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek));
}


@override
int get hashCode => Object.hash(runtimeType,criticalCount,openCount,overdueCount,completedThisWeek);

@override
String toString() {
  return 'DashboardStatsModel(criticalCount: $criticalCount, openCount: $openCount, overdueCount: $overdueCount, completedThisWeek: $completedThisWeek)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsModelCopyWith<$Res>  {
  factory $DashboardStatsModelCopyWith(DashboardStatsModel value, $Res Function(DashboardStatsModel) _then) = _$DashboardStatsModelCopyWithImpl;
@useResult
$Res call({
 int criticalCount, int openCount, int overdueCount, int completedThisWeek
});




}
/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final DashboardStatsModel _self;
  final $Res Function(DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
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


/// Adds pattern-matching-related methods to [DashboardStatsModel].
extension DashboardStatsModelPatterns on DashboardStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStatsModel() when $default != null:
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
case _DashboardStatsModel() when $default != null:
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
case _DashboardStatsModel():
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
case _DashboardStatsModel() when $default != null:
return $default(_that.criticalCount,_that.openCount,_that.overdueCount,_that.completedThisWeek);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardStatsModel extends DashboardStatsModel {
  const _DashboardStatsModel({this.criticalCount = 0, this.openCount = 0, this.overdueCount = 0, this.completedThisWeek = 0}): super._();
  

@override@JsonKey() final  int criticalCount;
@override@JsonKey() final  int openCount;
@override@JsonKey() final  int overdueCount;
@override@JsonKey() final  int completedThisWeek;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsModelCopyWith<_DashboardStatsModel> get copyWith => __$DashboardStatsModelCopyWithImpl<_DashboardStatsModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStatsModel&&(identical(other.criticalCount, criticalCount) || other.criticalCount == criticalCount)&&(identical(other.openCount, openCount) || other.openCount == openCount)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.completedThisWeek, completedThisWeek) || other.completedThisWeek == completedThisWeek));
}


@override
int get hashCode => Object.hash(runtimeType,criticalCount,openCount,overdueCount,completedThisWeek);

@override
String toString() {
  return 'DashboardStatsModel(criticalCount: $criticalCount, openCount: $openCount, overdueCount: $overdueCount, completedThisWeek: $completedThisWeek)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsModelCopyWith<$Res> implements $DashboardStatsModelCopyWith<$Res> {
  factory _$DashboardStatsModelCopyWith(_DashboardStatsModel value, $Res Function(_DashboardStatsModel) _then) = __$DashboardStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int criticalCount, int openCount, int overdueCount, int completedThisWeek
});




}
/// @nodoc
class __$DashboardStatsModelCopyWithImpl<$Res>
    implements _$DashboardStatsModelCopyWith<$Res> {
  __$DashboardStatsModelCopyWithImpl(this._self, this._then);

  final _DashboardStatsModel _self;
  final $Res Function(_DashboardStatsModel) _then;

/// Create a copy of DashboardStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? criticalCount = null,Object? openCount = null,Object? overdueCount = null,Object? completedThisWeek = null,}) {
  return _then(_DashboardStatsModel(
criticalCount: null == criticalCount ? _self.criticalCount : criticalCount // ignore: cast_nullable_to_non_nullable
as int,openCount: null == openCount ? _self.openCount : openCount // ignore: cast_nullable_to_non_nullable
as int,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,completedThisWeek: null == completedThisWeek ? _self.completedThisWeek : completedThisWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
