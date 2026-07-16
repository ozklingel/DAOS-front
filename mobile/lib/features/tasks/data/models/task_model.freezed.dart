// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskModel {

 String get id; String get title; String get status; String get priority; double get priorityScore; String get category; String get energyLevel; String? get description; String? get senderName; String? get senderEmail; String? get emailSubject; String? get emailSnippet; DateTime? get deadline; DateTime? get snoozedUntil; DateTime? get completedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskModelCopyWith<TaskModel> get copyWith => _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.category, category) || other.category == category)&&(identical(other.energyLevel, energyLevel) || other.energyLevel == energyLevel)&&(identical(other.description, description) || other.description == description)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderEmail, senderEmail) || other.senderEmail == senderEmail)&&(identical(other.emailSubject, emailSubject) || other.emailSubject == emailSubject)&&(identical(other.emailSnippet, emailSnippet) || other.emailSnippet == emailSnippet)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.snoozedUntil, snoozedUntil) || other.snoozedUntil == snoozedUntil)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,status,priority,priorityScore,category,energyLevel,description,senderName,senderEmail,emailSubject,emailSnippet,deadline,snoozedUntil,completedAt,createdAt,updatedAt);

@override
String toString() {
  return 'TaskModel(id: $id, title: $title, status: $status, priority: $priority, priorityScore: $priorityScore, category: $category, energyLevel: $energyLevel, description: $description, senderName: $senderName, senderEmail: $senderEmail, emailSubject: $emailSubject, emailSnippet: $emailSnippet, deadline: $deadline, snoozedUntil: $snoozedUntil, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res>  {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) = _$TaskModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String status, String priority, double priorityScore, String category, String energyLevel, String? description, String? senderName, String? senderEmail, String? emailSubject, String? emailSnippet, DateTime? deadline, DateTime? snoozedUntil, DateTime? completedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TaskModelCopyWithImpl<$Res>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? priority = null,Object? priorityScore = null,Object? category = null,Object? energyLevel = null,Object? description = freezed,Object? senderName = freezed,Object? senderEmail = freezed,Object? emailSubject = freezed,Object? emailSnippet = freezed,Object? deadline = freezed,Object? snoozedUntil = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,priorityScore: null == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,energyLevel: null == energyLevel ? _self.energyLevel : energyLevel // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderEmail: freezed == senderEmail ? _self.senderEmail : senderEmail // ignore: cast_nullable_to_non_nullable
as String?,emailSubject: freezed == emailSubject ? _self.emailSubject : emailSubject // ignore: cast_nullable_to_non_nullable
as String?,emailSnippet: freezed == emailSnippet ? _self.emailSnippet : emailSnippet // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozedUntil: freezed == snoozedUntil ? _self.snoozedUntil : snoozedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String status,  String priority,  double priorityScore,  String category,  String energyLevel,  String? description,  String? senderName,  String? senderEmail,  String? emailSubject,  String? emailSnippet,  DateTime? deadline,  DateTime? snoozedUntil,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.priority,_that.priorityScore,_that.category,_that.energyLevel,_that.description,_that.senderName,_that.senderEmail,_that.emailSubject,_that.emailSnippet,_that.deadline,_that.snoozedUntil,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String status,  String priority,  double priorityScore,  String category,  String energyLevel,  String? description,  String? senderName,  String? senderEmail,  String? emailSubject,  String? emailSnippet,  DateTime? deadline,  DateTime? snoozedUntil,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that.id,_that.title,_that.status,_that.priority,_that.priorityScore,_that.category,_that.energyLevel,_that.description,_that.senderName,_that.senderEmail,_that.emailSubject,_that.emailSnippet,_that.deadline,_that.snoozedUntil,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String status,  String priority,  double priorityScore,  String category,  String energyLevel,  String? description,  String? senderName,  String? senderEmail,  String? emailSubject,  String? emailSnippet,  DateTime? deadline,  DateTime? snoozedUntil,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.priority,_that.priorityScore,_that.category,_that.energyLevel,_that.description,_that.senderName,_that.senderEmail,_that.emailSubject,_that.emailSnippet,_that.deadline,_that.snoozedUntil,_that.completedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TaskModel extends TaskModel {
  const _TaskModel({required this.id, required this.title, required this.status, required this.priority, required this.priorityScore, this.category = 'general', this.energyLevel = 'medium', this.description, this.senderName, this.senderEmail, this.emailSubject, this.emailSnippet, this.deadline, this.snoozedUntil, this.completedAt, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String status;
@override final  String priority;
@override final  double priorityScore;
@override@JsonKey() final  String category;
@override@JsonKey() final  String energyLevel;
@override final  String? description;
@override final  String? senderName;
@override final  String? senderEmail;
@override final  String? emailSubject;
@override final  String? emailSnippet;
@override final  DateTime? deadline;
@override final  DateTime? snoozedUntil;
@override final  DateTime? completedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskModelCopyWith<_TaskModel> get copyWith => __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.category, category) || other.category == category)&&(identical(other.energyLevel, energyLevel) || other.energyLevel == energyLevel)&&(identical(other.description, description) || other.description == description)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderEmail, senderEmail) || other.senderEmail == senderEmail)&&(identical(other.emailSubject, emailSubject) || other.emailSubject == emailSubject)&&(identical(other.emailSnippet, emailSnippet) || other.emailSnippet == emailSnippet)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.snoozedUntil, snoozedUntil) || other.snoozedUntil == snoozedUntil)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,status,priority,priorityScore,category,energyLevel,description,senderName,senderEmail,emailSubject,emailSnippet,deadline,snoozedUntil,completedAt,createdAt,updatedAt);

@override
String toString() {
  return 'TaskModel(id: $id, title: $title, status: $status, priority: $priority, priorityScore: $priorityScore, category: $category, energyLevel: $energyLevel, description: $description, senderName: $senderName, senderEmail: $senderEmail, emailSubject: $emailSubject, emailSnippet: $emailSnippet, deadline: $deadline, snoozedUntil: $snoozedUntil, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res> implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(_TaskModel value, $Res Function(_TaskModel) _then) = __$TaskModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String status, String priority, double priorityScore, String category, String energyLevel, String? description, String? senderName, String? senderEmail, String? emailSubject, String? emailSnippet, DateTime? deadline, DateTime? snoozedUntil, DateTime? completedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TaskModelCopyWithImpl<$Res>
    implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? priority = null,Object? priorityScore = null,Object? category = null,Object? energyLevel = null,Object? description = freezed,Object? senderName = freezed,Object? senderEmail = freezed,Object? emailSubject = freezed,Object? emailSnippet = freezed,Object? deadline = freezed,Object? snoozedUntil = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,priorityScore: null == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,energyLevel: null == energyLevel ? _self.energyLevel : energyLevel // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderEmail: freezed == senderEmail ? _self.senderEmail : senderEmail // ignore: cast_nullable_to_non_nullable
as String?,emailSubject: freezed == emailSubject ? _self.emailSubject : emailSubject // ignore: cast_nullable_to_non_nullable
as String?,emailSnippet: freezed == emailSnippet ? _self.emailSnippet : emailSnippet // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,snoozedUntil: freezed == snoozedUntil ? _self.snoozedUntil : snoozedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$TaskListResponse {

 List<TaskModel> get tasks; int get total; int get page; bool get hasMore;
/// Create a copy of TaskListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskListResponseCopyWith<TaskListResponse> get copyWith => _$TaskListResponseCopyWithImpl<TaskListResponse>(this as TaskListResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskListResponse&&const DeepCollectionEquality().equals(other.tasks, tasks)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),total,page,hasMore);

@override
String toString() {
  return 'TaskListResponse(tasks: $tasks, total: $total, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $TaskListResponseCopyWith<$Res>  {
  factory $TaskListResponseCopyWith(TaskListResponse value, $Res Function(TaskListResponse) _then) = _$TaskListResponseCopyWithImpl;
@useResult
$Res call({
 List<TaskModel> tasks, int total, int page, bool hasMore
});




}
/// @nodoc
class _$TaskListResponseCopyWithImpl<$Res>
    implements $TaskListResponseCopyWith<$Res> {
  _$TaskListResponseCopyWithImpl(this._self, this._then);

  final TaskListResponse _self;
  final $Res Function(TaskListResponse) _then;

/// Create a copy of TaskListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? total = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskListResponse].
extension TaskListResponsePatterns on TaskListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskListResponse value)  $default,){
final _that = this;
switch (_that) {
case _TaskListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TaskListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TaskModel> tasks,  int total,  int page,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskListResponse() when $default != null:
return $default(_that.tasks,_that.total,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TaskModel> tasks,  int total,  int page,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _TaskListResponse():
return $default(_that.tasks,_that.total,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TaskModel> tasks,  int total,  int page,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _TaskListResponse() when $default != null:
return $default(_that.tasks,_that.total,_that.page,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _TaskListResponse extends TaskListResponse {
  const _TaskListResponse({required final  List<TaskModel> tasks, this.total = 0, this.page = 1, this.hasMore = false}): _tasks = tasks,super._();
  

 final  List<TaskModel> _tasks;
@override List<TaskModel> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey() final  bool hasMore;

/// Create a copy of TaskListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskListResponseCopyWith<_TaskListResponse> get copyWith => __$TaskListResponseCopyWithImpl<_TaskListResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskListResponse&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),total,page,hasMore);

@override
String toString() {
  return 'TaskListResponse(tasks: $tasks, total: $total, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$TaskListResponseCopyWith<$Res> implements $TaskListResponseCopyWith<$Res> {
  factory _$TaskListResponseCopyWith(_TaskListResponse value, $Res Function(_TaskListResponse) _then) = __$TaskListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<TaskModel> tasks, int total, int page, bool hasMore
});




}
/// @nodoc
class __$TaskListResponseCopyWithImpl<$Res>
    implements _$TaskListResponseCopyWith<$Res> {
  __$TaskListResponseCopyWithImpl(this._self, this._then);

  final _TaskListResponse _self;
  final $Res Function(_TaskListResponse) _then;

/// Create a copy of TaskListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? total = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_TaskListResponse(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
