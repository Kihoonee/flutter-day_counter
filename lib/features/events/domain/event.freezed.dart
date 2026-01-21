// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {

 String get id; String get title;// 기준일
 DateTime get baseDate;// 목표일
 DateTime get targetDate;// 당일 포함
 bool get includeToday;// 주말 제외
 bool get excludeWeekends;// 카드 테마(0~n)
 int get themeIndex;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.baseDate, baseDate) || other.baseDate == baseDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.includeToday, includeToday) || other.includeToday == includeToday)&&(identical(other.excludeWeekends, excludeWeekends) || other.excludeWeekends == excludeWeekends)&&(identical(other.themeIndex, themeIndex) || other.themeIndex == themeIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,baseDate,targetDate,includeToday,excludeWeekends,themeIndex);

@override
String toString() {
  return 'Event(id: $id, title: $title, baseDate: $baseDate, targetDate: $targetDate, includeToday: $includeToday, excludeWeekends: $excludeWeekends, themeIndex: $themeIndex)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime baseDate, DateTime targetDate, bool includeToday, bool excludeWeekends, int themeIndex
});




}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? baseDate = null,Object? targetDate = null,Object? includeToday = null,Object? excludeWeekends = null,Object? themeIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,includeToday: null == includeToday ? _self.includeToday : includeToday // ignore: cast_nullable_to_non_nullable
as bool,excludeWeekends: null == excludeWeekends ? _self.excludeWeekends : excludeWeekends // ignore: cast_nullable_to_non_nullable
as bool,themeIndex: null == themeIndex ? _self.themeIndex : themeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  int themeIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.themeIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  int themeIndex)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.themeIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  int themeIndex)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.themeIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.title, required this.baseDate, required this.targetDate, this.includeToday = false, this.excludeWeekends = false, this.themeIndex = 0});
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override final  String title;
// 기준일
@override final  DateTime baseDate;
// 목표일
@override final  DateTime targetDate;
// 당일 포함
@override@JsonKey() final  bool includeToday;
// 주말 제외
@override@JsonKey() final  bool excludeWeekends;
// 카드 테마(0~n)
@override@JsonKey() final  int themeIndex;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.baseDate, baseDate) || other.baseDate == baseDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.includeToday, includeToday) || other.includeToday == includeToday)&&(identical(other.excludeWeekends, excludeWeekends) || other.excludeWeekends == excludeWeekends)&&(identical(other.themeIndex, themeIndex) || other.themeIndex == themeIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,baseDate,targetDate,includeToday,excludeWeekends,themeIndex);

@override
String toString() {
  return 'Event(id: $id, title: $title, baseDate: $baseDate, targetDate: $targetDate, includeToday: $includeToday, excludeWeekends: $excludeWeekends, themeIndex: $themeIndex)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime baseDate, DateTime targetDate, bool includeToday, bool excludeWeekends, int themeIndex
});




}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? baseDate = null,Object? targetDate = null,Object? includeToday = null,Object? excludeWeekends = null,Object? themeIndex = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,includeToday: null == includeToday ? _self.includeToday : includeToday // ignore: cast_nullable_to_non_nullable
as bool,excludeWeekends: null == excludeWeekends ? _self.excludeWeekends : excludeWeekends // ignore: cast_nullable_to_non_nullable
as bool,themeIndex: null == themeIndex ? _self.themeIndex : themeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
