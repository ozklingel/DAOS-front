// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 bool get pushNotificationsEnabled; bool get dailyBriefEnabled; bool get emailSyncEnabled; String get dailyBriefTime; String get language;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.dailyBriefEnabled, dailyBriefEnabled) || other.dailyBriefEnabled == dailyBriefEnabled)&&(identical(other.emailSyncEnabled, emailSyncEnabled) || other.emailSyncEnabled == emailSyncEnabled)&&(identical(other.dailyBriefTime, dailyBriefTime) || other.dailyBriefTime == dailyBriefTime)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,pushNotificationsEnabled,dailyBriefEnabled,emailSyncEnabled,dailyBriefTime,language);

@override
String toString() {
  return 'AppSettings(pushNotificationsEnabled: $pushNotificationsEnabled, dailyBriefEnabled: $dailyBriefEnabled, emailSyncEnabled: $emailSyncEnabled, dailyBriefTime: $dailyBriefTime, language: $language)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool pushNotificationsEnabled, bool dailyBriefEnabled, bool emailSyncEnabled, String dailyBriefTime, String language
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushNotificationsEnabled = null,Object? dailyBriefEnabled = null,Object? emailSyncEnabled = null,Object? dailyBriefTime = null,Object? language = null,}) {
  return _then(_self.copyWith(
pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyBriefEnabled: null == dailyBriefEnabled ? _self.dailyBriefEnabled : dailyBriefEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailSyncEnabled: null == emailSyncEnabled ? _self.emailSyncEnabled : emailSyncEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyBriefTime: null == dailyBriefTime ? _self.dailyBriefTime : dailyBriefTime // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pushNotificationsEnabled,  bool dailyBriefEnabled,  bool emailSyncEnabled,  String dailyBriefTime,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.pushNotificationsEnabled,_that.dailyBriefEnabled,_that.emailSyncEnabled,_that.dailyBriefTime,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pushNotificationsEnabled,  bool dailyBriefEnabled,  bool emailSyncEnabled,  String dailyBriefTime,  String language)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.pushNotificationsEnabled,_that.dailyBriefEnabled,_that.emailSyncEnabled,_that.dailyBriefTime,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pushNotificationsEnabled,  bool dailyBriefEnabled,  bool emailSyncEnabled,  String dailyBriefTime,  String language)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.pushNotificationsEnabled,_that.dailyBriefEnabled,_that.emailSyncEnabled,_that.dailyBriefTime,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({this.pushNotificationsEnabled = true, this.dailyBriefEnabled = true, this.emailSyncEnabled = true, this.dailyBriefTime = '09:00', this.language = 'en'});
  

@override@JsonKey() final  bool pushNotificationsEnabled;
@override@JsonKey() final  bool dailyBriefEnabled;
@override@JsonKey() final  bool emailSyncEnabled;
@override@JsonKey() final  String dailyBriefTime;
@override@JsonKey() final  String language;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.pushNotificationsEnabled, pushNotificationsEnabled) || other.pushNotificationsEnabled == pushNotificationsEnabled)&&(identical(other.dailyBriefEnabled, dailyBriefEnabled) || other.dailyBriefEnabled == dailyBriefEnabled)&&(identical(other.emailSyncEnabled, emailSyncEnabled) || other.emailSyncEnabled == emailSyncEnabled)&&(identical(other.dailyBriefTime, dailyBriefTime) || other.dailyBriefTime == dailyBriefTime)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode => Object.hash(runtimeType,pushNotificationsEnabled,dailyBriefEnabled,emailSyncEnabled,dailyBriefTime,language);

@override
String toString() {
  return 'AppSettings(pushNotificationsEnabled: $pushNotificationsEnabled, dailyBriefEnabled: $dailyBriefEnabled, emailSyncEnabled: $emailSyncEnabled, dailyBriefTime: $dailyBriefTime, language: $language)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool pushNotificationsEnabled, bool dailyBriefEnabled, bool emailSyncEnabled, String dailyBriefTime, String language
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushNotificationsEnabled = null,Object? dailyBriefEnabled = null,Object? emailSyncEnabled = null,Object? dailyBriefTime = null,Object? language = null,}) {
  return _then(_AppSettings(
pushNotificationsEnabled: null == pushNotificationsEnabled ? _self.pushNotificationsEnabled : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyBriefEnabled: null == dailyBriefEnabled ? _self.dailyBriefEnabled : dailyBriefEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailSyncEnabled: null == emailSyncEnabled ? _self.emailSyncEnabled : emailSyncEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyBriefTime: null == dailyBriefTime ? _self.dailyBriefTime : dailyBriefTime // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
