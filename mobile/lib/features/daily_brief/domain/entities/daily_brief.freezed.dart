// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyBrief {

 String get id; String get summary; String get content; DateTime get generatedAt; List<Task> get highlightedTasks; List<String> get insights;
/// Create a copy of DailyBrief
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyBriefCopyWith<DailyBrief> get copyWith => _$DailyBriefCopyWithImpl<DailyBrief>(this as DailyBrief, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyBrief&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.content, content) || other.content == content)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.highlightedTasks, highlightedTasks)&&const DeepCollectionEquality().equals(other.insights, insights));
}


@override
int get hashCode => Object.hash(runtimeType,id,summary,content,generatedAt,const DeepCollectionEquality().hash(highlightedTasks),const DeepCollectionEquality().hash(insights));

@override
String toString() {
  return 'DailyBrief(id: $id, summary: $summary, content: $content, generatedAt: $generatedAt, highlightedTasks: $highlightedTasks, insights: $insights)';
}


}

/// @nodoc
abstract mixin class $DailyBriefCopyWith<$Res>  {
  factory $DailyBriefCopyWith(DailyBrief value, $Res Function(DailyBrief) _then) = _$DailyBriefCopyWithImpl;
@useResult
$Res call({
 String id, String summary, String content, DateTime generatedAt, List<Task> highlightedTasks, List<String> insights
});




}
/// @nodoc
class _$DailyBriefCopyWithImpl<$Res>
    implements $DailyBriefCopyWith<$Res> {
  _$DailyBriefCopyWithImpl(this._self, this._then);

  final DailyBrief _self;
  final $Res Function(DailyBrief) _then;

/// Create a copy of DailyBrief
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = null,Object? content = null,Object? generatedAt = null,Object? highlightedTasks = null,Object? insights = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,highlightedTasks: null == highlightedTasks ? _self.highlightedTasks : highlightedTasks // ignore: cast_nullable_to_non_nullable
as List<Task>,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyBrief].
extension DailyBriefPatterns on DailyBrief {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyBrief value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyBrief() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyBrief value)  $default,){
final _that = this;
switch (_that) {
case _DailyBrief():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyBrief value)?  $default,){
final _that = this;
switch (_that) {
case _DailyBrief() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String summary,  String content,  DateTime generatedAt,  List<Task> highlightedTasks,  List<String> insights)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyBrief() when $default != null:
return $default(_that.id,_that.summary,_that.content,_that.generatedAt,_that.highlightedTasks,_that.insights);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String summary,  String content,  DateTime generatedAt,  List<Task> highlightedTasks,  List<String> insights)  $default,) {final _that = this;
switch (_that) {
case _DailyBrief():
return $default(_that.id,_that.summary,_that.content,_that.generatedAt,_that.highlightedTasks,_that.insights);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String summary,  String content,  DateTime generatedAt,  List<Task> highlightedTasks,  List<String> insights)?  $default,) {final _that = this;
switch (_that) {
case _DailyBrief() when $default != null:
return $default(_that.id,_that.summary,_that.content,_that.generatedAt,_that.highlightedTasks,_that.insights);case _:
  return null;

}
}

}

/// @nodoc


class _DailyBrief implements DailyBrief {
  const _DailyBrief({required this.id, required this.summary, required this.content, required this.generatedAt, final  List<Task> highlightedTasks = const [], final  List<String> insights = const []}): _highlightedTasks = highlightedTasks,_insights = insights;
  

@override final  String id;
@override final  String summary;
@override final  String content;
@override final  DateTime generatedAt;
 final  List<Task> _highlightedTasks;
@override@JsonKey() List<Task> get highlightedTasks {
  if (_highlightedTasks is EqualUnmodifiableListView) return _highlightedTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlightedTasks);
}

 final  List<String> _insights;
@override@JsonKey() List<String> get insights {
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_insights);
}


/// Create a copy of DailyBrief
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyBriefCopyWith<_DailyBrief> get copyWith => __$DailyBriefCopyWithImpl<_DailyBrief>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyBrief&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.content, content) || other.content == content)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._highlightedTasks, _highlightedTasks)&&const DeepCollectionEquality().equals(other._insights, _insights));
}


@override
int get hashCode => Object.hash(runtimeType,id,summary,content,generatedAt,const DeepCollectionEquality().hash(_highlightedTasks),const DeepCollectionEquality().hash(_insights));

@override
String toString() {
  return 'DailyBrief(id: $id, summary: $summary, content: $content, generatedAt: $generatedAt, highlightedTasks: $highlightedTasks, insights: $insights)';
}


}

/// @nodoc
abstract mixin class _$DailyBriefCopyWith<$Res> implements $DailyBriefCopyWith<$Res> {
  factory _$DailyBriefCopyWith(_DailyBrief value, $Res Function(_DailyBrief) _then) = __$DailyBriefCopyWithImpl;
@override @useResult
$Res call({
 String id, String summary, String content, DateTime generatedAt, List<Task> highlightedTasks, List<String> insights
});




}
/// @nodoc
class __$DailyBriefCopyWithImpl<$Res>
    implements _$DailyBriefCopyWith<$Res> {
  __$DailyBriefCopyWithImpl(this._self, this._then);

  final _DailyBrief _self;
  final $Res Function(_DailyBrief) _then;

/// Create a copy of DailyBrief
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? content = null,Object? generatedAt = null,Object? highlightedTasks = null,Object? insights = null,}) {
  return _then(_DailyBrief(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,highlightedTasks: null == highlightedTasks ? _self._highlightedTasks : highlightedTasks // ignore: cast_nullable_to_non_nullable
as List<Task>,insights: null == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
