// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get id; String get email; String? get name; String? get avatarUrl; bool get gmailConnected; bool get outlookConnected; bool get whatsappConnected; String? get whatsappPhone;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.gmailConnected, gmailConnected) || other.gmailConnected == gmailConnected)&&(identical(other.outlookConnected, outlookConnected) || other.outlookConnected == outlookConnected)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.whatsappPhone, whatsappPhone) || other.whatsappPhone == whatsappPhone));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,name,avatarUrl,gmailConnected,outlookConnected,whatsappConnected,whatsappPhone);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, gmailConnected: $gmailConnected, outlookConnected: $outlookConnected, whatsappConnected: $whatsappConnected, whatsappPhone: $whatsappPhone)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String? name, String? avatarUrl, bool gmailConnected, bool outlookConnected, bool whatsappConnected, String? whatsappPhone
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = freezed,Object? avatarUrl = freezed,Object? gmailConnected = null,Object? outlookConnected = null,Object? whatsappConnected = null,Object? whatsappPhone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,gmailConnected: null == gmailConnected ? _self.gmailConnected : gmailConnected // ignore: cast_nullable_to_non_nullable
as bool,outlookConnected: null == outlookConnected ? _self.outlookConnected : outlookConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappPhone: freezed == whatsappPhone ? _self.whatsappPhone : whatsappPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String? name,  String? avatarUrl,  bool gmailConnected,  bool outlookConnected,  bool whatsappConnected,  String? whatsappPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.gmailConnected,_that.outlookConnected,_that.whatsappConnected,_that.whatsappPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String? name,  String? avatarUrl,  bool gmailConnected,  bool outlookConnected,  bool whatsappConnected,  String? whatsappPhone)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.gmailConnected,_that.outlookConnected,_that.whatsappConnected,_that.whatsappPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String? name,  String? avatarUrl,  bool gmailConnected,  bool outlookConnected,  bool whatsappConnected,  String? whatsappPhone)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.avatarUrl,_that.gmailConnected,_that.outlookConnected,_that.whatsappConnected,_that.whatsappPhone);case _:
  return null;

}
}

}

/// @nodoc


class _User implements User {
  const _User({required this.id, required this.email, this.name, this.avatarUrl, this.gmailConnected = false, this.outlookConnected = false, this.whatsappConnected = false, this.whatsappPhone});
  

@override final  String id;
@override final  String email;
@override final  String? name;
@override final  String? avatarUrl;
@override@JsonKey() final  bool gmailConnected;
@override@JsonKey() final  bool outlookConnected;
@override@JsonKey() final  bool whatsappConnected;
@override final  String? whatsappPhone;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.gmailConnected, gmailConnected) || other.gmailConnected == gmailConnected)&&(identical(other.outlookConnected, outlookConnected) || other.outlookConnected == outlookConnected)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.whatsappPhone, whatsappPhone) || other.whatsappPhone == whatsappPhone));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,name,avatarUrl,gmailConnected,outlookConnected,whatsappConnected,whatsappPhone);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, gmailConnected: $gmailConnected, outlookConnected: $outlookConnected, whatsappConnected: $whatsappConnected, whatsappPhone: $whatsappPhone)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String? name, String? avatarUrl, bool gmailConnected, bool outlookConnected, bool whatsappConnected, String? whatsappPhone
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = freezed,Object? avatarUrl = freezed,Object? gmailConnected = null,Object? outlookConnected = null,Object? whatsappConnected = null,Object? whatsappPhone = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,gmailConnected: null == gmailConnected ? _self.gmailConnected : gmailConnected // ignore: cast_nullable_to_non_nullable
as bool,outlookConnected: null == outlookConnected ? _self.outlookConnected : outlookConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as bool,whatsappPhone: freezed == whatsappPhone ? _self.whatsappPhone : whatsappPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
