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
 bool get excludeWeekends;// 알림 켜기/끄기
 bool get isNotificationEnabled;// 카드 테마(0~n)
 int get themeIndex;// 아이콘(0~n)
 int get iconIndex;// 투두 리스트
 List<TodoItem> get todos;// 다이어리
// 다이어리
 List<DiaryEntry> get diaryEntries;// 정렬 순서 (오름차순)
 int get sortOrder;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.baseDate, baseDate) || other.baseDate == baseDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.includeToday, includeToday) || other.includeToday == includeToday)&&(identical(other.excludeWeekends, excludeWeekends) || other.excludeWeekends == excludeWeekends)&&(identical(other.isNotificationEnabled, isNotificationEnabled) || other.isNotificationEnabled == isNotificationEnabled)&&(identical(other.themeIndex, themeIndex) || other.themeIndex == themeIndex)&&(identical(other.iconIndex, iconIndex) || other.iconIndex == iconIndex)&&const DeepCollectionEquality().equals(other.todos, todos)&&const DeepCollectionEquality().equals(other.diaryEntries, diaryEntries)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,baseDate,targetDate,includeToday,excludeWeekends,isNotificationEnabled,themeIndex,iconIndex,const DeepCollectionEquality().hash(todos),const DeepCollectionEquality().hash(diaryEntries),sortOrder);

@override
String toString() {
  return 'Event(id: $id, title: $title, baseDate: $baseDate, targetDate: $targetDate, includeToday: $includeToday, excludeWeekends: $excludeWeekends, isNotificationEnabled: $isNotificationEnabled, themeIndex: $themeIndex, iconIndex: $iconIndex, todos: $todos, diaryEntries: $diaryEntries, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime baseDate, DateTime targetDate, bool includeToday, bool excludeWeekends, bool isNotificationEnabled, int themeIndex, int iconIndex, List<TodoItem> todos, List<DiaryEntry> diaryEntries, int sortOrder
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? baseDate = null,Object? targetDate = null,Object? includeToday = null,Object? excludeWeekends = null,Object? isNotificationEnabled = null,Object? themeIndex = null,Object? iconIndex = null,Object? todos = null,Object? diaryEntries = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,includeToday: null == includeToday ? _self.includeToday : includeToday // ignore: cast_nullable_to_non_nullable
as bool,excludeWeekends: null == excludeWeekends ? _self.excludeWeekends : excludeWeekends // ignore: cast_nullable_to_non_nullable
as bool,isNotificationEnabled: null == isNotificationEnabled ? _self.isNotificationEnabled : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,themeIndex: null == themeIndex ? _self.themeIndex : themeIndex // ignore: cast_nullable_to_non_nullable
as int,iconIndex: null == iconIndex ? _self.iconIndex : iconIndex // ignore: cast_nullable_to_non_nullable
as int,todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,diaryEntries: null == diaryEntries ? _self.diaryEntries : diaryEntries // ignore: cast_nullable_to_non_nullable
as List<DiaryEntry>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  bool isNotificationEnabled,  int themeIndex,  int iconIndex,  List<TodoItem> todos,  List<DiaryEntry> diaryEntries,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.isNotificationEnabled,_that.themeIndex,_that.iconIndex,_that.todos,_that.diaryEntries,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  bool isNotificationEnabled,  int themeIndex,  int iconIndex,  List<TodoItem> todos,  List<DiaryEntry> diaryEntries,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.isNotificationEnabled,_that.themeIndex,_that.iconIndex,_that.todos,_that.diaryEntries,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime baseDate,  DateTime targetDate,  bool includeToday,  bool excludeWeekends,  bool isNotificationEnabled,  int themeIndex,  int iconIndex,  List<TodoItem> todos,  List<DiaryEntry> diaryEntries,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.baseDate,_that.targetDate,_that.includeToday,_that.excludeWeekends,_that.isNotificationEnabled,_that.themeIndex,_that.iconIndex,_that.todos,_that.diaryEntries,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, required this.title, required this.baseDate, required this.targetDate, this.includeToday = false, this.excludeWeekends = false, this.isNotificationEnabled = true, this.themeIndex = 0, this.iconIndex = 0, final  List<TodoItem> todos = const [], final  List<DiaryEntry> diaryEntries = const [], this.sortOrder = 0}): _todos = todos,_diaryEntries = diaryEntries;
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
// 알림 켜기/끄기
@override@JsonKey() final  bool isNotificationEnabled;
// 카드 테마(0~n)
@override@JsonKey() final  int themeIndex;
// 아이콘(0~n)
@override@JsonKey() final  int iconIndex;
// 투두 리스트
 final  List<TodoItem> _todos;
// 투두 리스트
@override@JsonKey() List<TodoItem> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

// 다이어리
// 다이어리
 final  List<DiaryEntry> _diaryEntries;
// 다이어리
// 다이어리
@override@JsonKey() List<DiaryEntry> get diaryEntries {
  if (_diaryEntries is EqualUnmodifiableListView) return _diaryEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diaryEntries);
}

// 정렬 순서 (오름차순)
@override@JsonKey() final  int sortOrder;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.baseDate, baseDate) || other.baseDate == baseDate)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.includeToday, includeToday) || other.includeToday == includeToday)&&(identical(other.excludeWeekends, excludeWeekends) || other.excludeWeekends == excludeWeekends)&&(identical(other.isNotificationEnabled, isNotificationEnabled) || other.isNotificationEnabled == isNotificationEnabled)&&(identical(other.themeIndex, themeIndex) || other.themeIndex == themeIndex)&&(identical(other.iconIndex, iconIndex) || other.iconIndex == iconIndex)&&const DeepCollectionEquality().equals(other._todos, _todos)&&const DeepCollectionEquality().equals(other._diaryEntries, _diaryEntries)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,baseDate,targetDate,includeToday,excludeWeekends,isNotificationEnabled,themeIndex,iconIndex,const DeepCollectionEquality().hash(_todos),const DeepCollectionEquality().hash(_diaryEntries),sortOrder);

@override
String toString() {
  return 'Event(id: $id, title: $title, baseDate: $baseDate, targetDate: $targetDate, includeToday: $includeToday, excludeWeekends: $excludeWeekends, isNotificationEnabled: $isNotificationEnabled, themeIndex: $themeIndex, iconIndex: $iconIndex, todos: $todos, diaryEntries: $diaryEntries, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime baseDate, DateTime targetDate, bool includeToday, bool excludeWeekends, bool isNotificationEnabled, int themeIndex, int iconIndex, List<TodoItem> todos, List<DiaryEntry> diaryEntries, int sortOrder
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? baseDate = null,Object? targetDate = null,Object? includeToday = null,Object? excludeWeekends = null,Object? isNotificationEnabled = null,Object? themeIndex = null,Object? iconIndex = null,Object? todos = null,Object? diaryEntries = null,Object? sortOrder = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,includeToday: null == includeToday ? _self.includeToday : includeToday // ignore: cast_nullable_to_non_nullable
as bool,excludeWeekends: null == excludeWeekends ? _self.excludeWeekends : excludeWeekends // ignore: cast_nullable_to_non_nullable
as bool,isNotificationEnabled: null == isNotificationEnabled ? _self.isNotificationEnabled : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
as bool,themeIndex: null == themeIndex ? _self.themeIndex : themeIndex // ignore: cast_nullable_to_non_nullable
as int,iconIndex: null == iconIndex ? _self.iconIndex : iconIndex // ignore: cast_nullable_to_non_nullable
as int,todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,diaryEntries: null == diaryEntries ? _self._diaryEntries : diaryEntries // ignore: cast_nullable_to_non_nullable
as List<DiaryEntry>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
