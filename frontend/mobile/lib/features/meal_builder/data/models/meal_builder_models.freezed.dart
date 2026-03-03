// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_builder_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealComponent _$MealComponentFromJson(Map<String, dynamic> json) {
  return _MealComponent.fromJson(json);
}

/// @nodoc
mixin _$MealComponent {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get calories => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this MealComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealComponentCopyWith<MealComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealComponentCopyWith<$Res> {
  factory $MealComponentCopyWith(
    MealComponent value,
    $Res Function(MealComponent) then,
  ) = _$MealComponentCopyWithImpl<$Res, MealComponent>;
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    double price,
    int calories,
    String imageUrl,
  });
}

/// @nodoc
class _$MealComponentCopyWithImpl<$Res, $Val extends MealComponent>
    implements $MealComponentCopyWith<$Res> {
  _$MealComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? calories = null,
    Object? imageUrl = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            calories: null == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealComponentImplCopyWith<$Res>
    implements $MealComponentCopyWith<$Res> {
  factory _$$MealComponentImplCopyWith(
    _$MealComponentImpl value,
    $Res Function(_$MealComponentImpl) then,
  ) = __$$MealComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    double price,
    int calories,
    String imageUrl,
  });
}

/// @nodoc
class __$$MealComponentImplCopyWithImpl<$Res>
    extends _$MealComponentCopyWithImpl<$Res, _$MealComponentImpl>
    implements _$$MealComponentImplCopyWith<$Res> {
  __$$MealComponentImplCopyWithImpl(
    _$MealComponentImpl _value,
    $Res Function(_$MealComponentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? calories = null,
    Object? imageUrl = null,
  }) {
    return _then(
      _$MealComponentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        calories: null == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealComponentImpl implements _MealComponent {
  const _$MealComponentImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.calories,
    required this.imageUrl,
  });

  factory _$MealComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealComponentImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  @override
  final double price;
  @override
  final int calories;
  @override
  final String imageUrl;

  @override
  String toString() {
    return 'MealComponent(id: $id, name: $name, category: $category, price: $price, calories: $calories, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, category, price, calories, imageUrl);

  /// Create a copy of MealComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealComponentImplCopyWith<_$MealComponentImpl> get copyWith =>
      __$$MealComponentImplCopyWithImpl<_$MealComponentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealComponentImplToJson(this);
  }
}

abstract class _MealComponent implements MealComponent {
  const factory _MealComponent({
    required final String id,
    required final String name,
    required final String category,
    required final double price,
    required final int calories,
    required final String imageUrl,
  }) = _$MealComponentImpl;

  factory _MealComponent.fromJson(Map<String, dynamic> json) =
      _$MealComponentImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category;
  @override
  double get price;
  @override
  int get calories;
  @override
  String get imageUrl;

  /// Create a copy of MealComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealComponentImplCopyWith<_$MealComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealPreset _$MealPresetFromJson(Map<String, dynamic> json) {
  return _MealPreset.fromJson(json);
}

/// @nodoc
mixin _$MealPreset {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get components => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  int get totalCalories => throw _privateConstructorUsedError;

  /// Serializes this MealPreset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealPresetCopyWith<MealPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealPresetCopyWith<$Res> {
  factory $MealPresetCopyWith(
    MealPreset value,
    $Res Function(MealPreset) then,
  ) = _$MealPresetCopyWithImpl<$Res, MealPreset>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> components,
    double totalPrice,
    int totalCalories,
  });
}

/// @nodoc
class _$MealPresetCopyWithImpl<$Res, $Val extends MealPreset>
    implements $MealPresetCopyWith<$Res> {
  _$MealPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? components = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCalories: null == totalCalories
                ? _value.totalCalories
                : totalCalories // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealPresetImplCopyWith<$Res>
    implements $MealPresetCopyWith<$Res> {
  factory _$$MealPresetImplCopyWith(
    _$MealPresetImpl value,
    $Res Function(_$MealPresetImpl) then,
  ) = __$$MealPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> components,
    double totalPrice,
    int totalCalories,
  });
}

/// @nodoc
class __$$MealPresetImplCopyWithImpl<$Res>
    extends _$MealPresetCopyWithImpl<$Res, _$MealPresetImpl>
    implements _$$MealPresetImplCopyWith<$Res> {
  __$$MealPresetImplCopyWithImpl(
    _$MealPresetImpl _value,
    $Res Function(_$MealPresetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? components = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
  }) {
    return _then(
      _$MealPresetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCalories: null == totalCalories
            ? _value.totalCalories
            : totalCalories // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealPresetImpl implements _MealPreset {
  const _$MealPresetImpl({
    required this.id,
    required this.name,
    required final List<String> components,
    required this.totalPrice,
    required this.totalCalories,
  }) : _components = components;

  factory _$MealPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealPresetImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _components;
  @override
  List<String> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  @override
  final double totalPrice;
  @override
  final int totalCalories;

  @override
  String toString() {
    return 'MealPreset(id: $id, name: $name, components: $components, totalPrice: $totalPrice, totalCalories: $totalCalories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_components),
    totalPrice,
    totalCalories,
  );

  /// Create a copy of MealPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealPresetImplCopyWith<_$MealPresetImpl> get copyWith =>
      __$$MealPresetImplCopyWithImpl<_$MealPresetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealPresetImplToJson(this);
  }
}

abstract class _MealPreset implements MealPreset {
  const factory _MealPreset({
    required final String id,
    required final String name,
    required final List<String> components,
    required final double totalPrice,
    required final int totalCalories,
  }) = _$MealPresetImpl;

  factory _MealPreset.fromJson(Map<String, dynamic> json) =
      _$MealPresetImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get components;
  @override
  double get totalPrice;
  @override
  int get totalCalories;

  /// Create a copy of MealPreset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPresetImplCopyWith<_$MealPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealCalculation _$MealCalculationFromJson(Map<String, dynamic> json) {
  return _MealCalculation.fromJson(json);
}

/// @nodoc
mixin _$MealCalculation {
  List<String> get components => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  int get totalCalories => throw _privateConstructorUsedError;

  /// Serializes this MealCalculation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealCalculationCopyWith<MealCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCalculationCopyWith<$Res> {
  factory $MealCalculationCopyWith(
    MealCalculation value,
    $Res Function(MealCalculation) then,
  ) = _$MealCalculationCopyWithImpl<$Res, MealCalculation>;
  @useResult
  $Res call({List<String> components, double totalPrice, int totalCalories});
}

/// @nodoc
class _$MealCalculationCopyWithImpl<$Res, $Val extends MealCalculation>
    implements $MealCalculationCopyWith<$Res> {
  _$MealCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
  }) {
    return _then(
      _value.copyWith(
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCalories: null == totalCalories
                ? _value.totalCalories
                : totalCalories // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealCalculationImplCopyWith<$Res>
    implements $MealCalculationCopyWith<$Res> {
  factory _$$MealCalculationImplCopyWith(
    _$MealCalculationImpl value,
    $Res Function(_$MealCalculationImpl) then,
  ) = __$$MealCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> components, double totalPrice, int totalCalories});
}

/// @nodoc
class __$$MealCalculationImplCopyWithImpl<$Res>
    extends _$MealCalculationCopyWithImpl<$Res, _$MealCalculationImpl>
    implements _$$MealCalculationImplCopyWith<$Res> {
  __$$MealCalculationImplCopyWithImpl(
    _$MealCalculationImpl _value,
    $Res Function(_$MealCalculationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
  }) {
    return _then(
      _$MealCalculationImpl(
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCalories: null == totalCalories
            ? _value.totalCalories
            : totalCalories // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealCalculationImpl implements _MealCalculation {
  const _$MealCalculationImpl({
    required final List<String> components,
    required this.totalPrice,
    required this.totalCalories,
  }) : _components = components;

  factory _$MealCalculationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealCalculationImplFromJson(json);

  final List<String> _components;
  @override
  List<String> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  @override
  final double totalPrice;
  @override
  final int totalCalories;

  @override
  String toString() {
    return 'MealCalculation(components: $components, totalPrice: $totalPrice, totalCalories: $totalCalories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealCalculationImpl &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_components),
    totalPrice,
    totalCalories,
  );

  /// Create a copy of MealCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealCalculationImplCopyWith<_$MealCalculationImpl> get copyWith =>
      __$$MealCalculationImplCopyWithImpl<_$MealCalculationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MealCalculationImplToJson(this);
  }
}

abstract class _MealCalculation implements MealCalculation {
  const factory _MealCalculation({
    required final List<String> components,
    required final double totalPrice,
    required final int totalCalories,
  }) = _$MealCalculationImpl;

  factory _MealCalculation.fromJson(Map<String, dynamic> json) =
      _$MealCalculationImpl.fromJson;

  @override
  List<String> get components;
  @override
  double get totalPrice;
  @override
  int get totalCalories;

  /// Create a copy of MealCalculation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealCalculationImplCopyWith<_$MealCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealCalculateRequest _$MealCalculateRequestFromJson(Map<String, dynamic> json) {
  return _MealCalculateRequest.fromJson(json);
}

/// @nodoc
mixin _$MealCalculateRequest {
  List<String> get componentIds => throw _privateConstructorUsedError;

  /// Serializes this MealCalculateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealCalculateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealCalculateRequestCopyWith<MealCalculateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCalculateRequestCopyWith<$Res> {
  factory $MealCalculateRequestCopyWith(
    MealCalculateRequest value,
    $Res Function(MealCalculateRequest) then,
  ) = _$MealCalculateRequestCopyWithImpl<$Res, MealCalculateRequest>;
  @useResult
  $Res call({List<String> componentIds});
}

/// @nodoc
class _$MealCalculateRequestCopyWithImpl<
  $Res,
  $Val extends MealCalculateRequest
>
    implements $MealCalculateRequestCopyWith<$Res> {
  _$MealCalculateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealCalculateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? componentIds = null}) {
    return _then(
      _value.copyWith(
            componentIds: null == componentIds
                ? _value.componentIds
                : componentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealCalculateRequestImplCopyWith<$Res>
    implements $MealCalculateRequestCopyWith<$Res> {
  factory _$$MealCalculateRequestImplCopyWith(
    _$MealCalculateRequestImpl value,
    $Res Function(_$MealCalculateRequestImpl) then,
  ) = __$$MealCalculateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> componentIds});
}

/// @nodoc
class __$$MealCalculateRequestImplCopyWithImpl<$Res>
    extends _$MealCalculateRequestCopyWithImpl<$Res, _$MealCalculateRequestImpl>
    implements _$$MealCalculateRequestImplCopyWith<$Res> {
  __$$MealCalculateRequestImplCopyWithImpl(
    _$MealCalculateRequestImpl _value,
    $Res Function(_$MealCalculateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealCalculateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? componentIds = null}) {
    return _then(
      _$MealCalculateRequestImpl(
        componentIds: null == componentIds
            ? _value._componentIds
            : componentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealCalculateRequestImpl implements _MealCalculateRequest {
  const _$MealCalculateRequestImpl({required final List<String> componentIds})
    : _componentIds = componentIds;

  factory _$MealCalculateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealCalculateRequestImplFromJson(json);

  final List<String> _componentIds;
  @override
  List<String> get componentIds {
    if (_componentIds is EqualUnmodifiableListView) return _componentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_componentIds);
  }

  @override
  String toString() {
    return 'MealCalculateRequest(componentIds: $componentIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealCalculateRequestImpl &&
            const DeepCollectionEquality().equals(
              other._componentIds,
              _componentIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_componentIds),
  );

  /// Create a copy of MealCalculateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealCalculateRequestImplCopyWith<_$MealCalculateRequestImpl>
  get copyWith =>
      __$$MealCalculateRequestImplCopyWithImpl<_$MealCalculateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MealCalculateRequestImplToJson(this);
  }
}

abstract class _MealCalculateRequest implements MealCalculateRequest {
  const factory _MealCalculateRequest({
    required final List<String> componentIds,
  }) = _$MealCalculateRequestImpl;

  factory _MealCalculateRequest.fromJson(Map<String, dynamic> json) =
      _$MealCalculateRequestImpl.fromJson;

  @override
  List<String> get componentIds;

  /// Create a copy of MealCalculateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealCalculateRequestImplCopyWith<_$MealCalculateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PlateIngredient {
  String get componentId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get calories => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get plateX => throw _privateConstructorUsedError;
  double get plateY => throw _privateConstructorUsedError;

  /// Create a copy of PlateIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlateIngredientCopyWith<PlateIngredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlateIngredientCopyWith<$Res> {
  factory $PlateIngredientCopyWith(
    PlateIngredient value,
    $Res Function(PlateIngredient) then,
  ) = _$PlateIngredientCopyWithImpl<$Res, PlateIngredient>;
  @useResult
  $Res call({
    String componentId,
    String name,
    String category,
    double price,
    int calories,
    int quantity,
    double plateX,
    double plateY,
  });
}

/// @nodoc
class _$PlateIngredientCopyWithImpl<$Res, $Val extends PlateIngredient>
    implements $PlateIngredientCopyWith<$Res> {
  _$PlateIngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlateIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? componentId = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? calories = null,
    Object? quantity = null,
    Object? plateX = null,
    Object? plateY = null,
  }) {
    return _then(
      _value.copyWith(
            componentId: null == componentId
                ? _value.componentId
                : componentId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            calories: null == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as int,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            plateX: null == plateX
                ? _value.plateX
                : plateX // ignore: cast_nullable_to_non_nullable
                      as double,
            plateY: null == plateY
                ? _value.plateY
                : plateY // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlateIngredientImplCopyWith<$Res>
    implements $PlateIngredientCopyWith<$Res> {
  factory _$$PlateIngredientImplCopyWith(
    _$PlateIngredientImpl value,
    $Res Function(_$PlateIngredientImpl) then,
  ) = __$$PlateIngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String componentId,
    String name,
    String category,
    double price,
    int calories,
    int quantity,
    double plateX,
    double plateY,
  });
}

/// @nodoc
class __$$PlateIngredientImplCopyWithImpl<$Res>
    extends _$PlateIngredientCopyWithImpl<$Res, _$PlateIngredientImpl>
    implements _$$PlateIngredientImplCopyWith<$Res> {
  __$$PlateIngredientImplCopyWithImpl(
    _$PlateIngredientImpl _value,
    $Res Function(_$PlateIngredientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlateIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? componentId = null,
    Object? name = null,
    Object? category = null,
    Object? price = null,
    Object? calories = null,
    Object? quantity = null,
    Object? plateX = null,
    Object? plateY = null,
  }) {
    return _then(
      _$PlateIngredientImpl(
        componentId: null == componentId
            ? _value.componentId
            : componentId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        calories: null == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as int,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        plateX: null == plateX
            ? _value.plateX
            : plateX // ignore: cast_nullable_to_non_nullable
                  as double,
        plateY: null == plateY
            ? _value.plateY
            : plateY // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$PlateIngredientImpl implements _PlateIngredient {
  const _$PlateIngredientImpl({
    required this.componentId,
    required this.name,
    required this.category,
    required this.price,
    required this.calories,
    required this.quantity,
    this.plateX = 0.5,
    this.plateY = 0.5,
  });

  @override
  final String componentId;
  @override
  final String name;
  @override
  final String category;
  @override
  final double price;
  @override
  final int calories;
  @override
  final int quantity;
  @override
  @JsonKey()
  final double plateX;
  @override
  @JsonKey()
  final double plateY;

  @override
  String toString() {
    return 'PlateIngredient(componentId: $componentId, name: $name, category: $category, price: $price, calories: $calories, quantity: $quantity, plateX: $plateX, plateY: $plateY)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlateIngredientImpl &&
            (identical(other.componentId, componentId) ||
                other.componentId == componentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.plateX, plateX) || other.plateX == plateX) &&
            (identical(other.plateY, plateY) || other.plateY == plateY));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    componentId,
    name,
    category,
    price,
    calories,
    quantity,
    plateX,
    plateY,
  );

  /// Create a copy of PlateIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlateIngredientImplCopyWith<_$PlateIngredientImpl> get copyWith =>
      __$$PlateIngredientImplCopyWithImpl<_$PlateIngredientImpl>(
        this,
        _$identity,
      );
}

abstract class _PlateIngredient implements PlateIngredient {
  const factory _PlateIngredient({
    required final String componentId,
    required final String name,
    required final String category,
    required final double price,
    required final int calories,
    required final int quantity,
    final double plateX,
    final double plateY,
  }) = _$PlateIngredientImpl;

  @override
  String get componentId;
  @override
  String get name;
  @override
  String get category;
  @override
  double get price;
  @override
  int get calories;
  @override
  int get quantity;
  @override
  double get plateX;
  @override
  double get plateY;

  /// Create a copy of PlateIngredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlateIngredientImplCopyWith<_$PlateIngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MealDraft {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  List<PlateIngredient> get ingredients => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  int get totalCalories => throw _privateConstructorUsedError;
  bool get available => throw _privateConstructorUsedError;

  /// Create a copy of MealDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealDraftCopyWith<MealDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealDraftCopyWith<$Res> {
  factory $MealDraftCopyWith(MealDraft value, $Res Function(MealDraft) then) =
      _$MealDraftCopyWithImpl<$Res, MealDraft>;
  @useResult
  $Res call({
    String id,
    String label,
    List<PlateIngredient> ingredients,
    double totalPrice,
    int totalCalories,
    bool available,
  });
}

/// @nodoc
class _$MealDraftCopyWithImpl<$Res, $Val extends MealDraft>
    implements $MealDraftCopyWith<$Res> {
  _$MealDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? ingredients = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
    Object? available = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<PlateIngredient>,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCalories: null == totalCalories
                ? _value.totalCalories
                : totalCalories // ignore: cast_nullable_to_non_nullable
                      as int,
            available: null == available
                ? _value.available
                : available // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealDraftImplCopyWith<$Res>
    implements $MealDraftCopyWith<$Res> {
  factory _$$MealDraftImplCopyWith(
    _$MealDraftImpl value,
    $Res Function(_$MealDraftImpl) then,
  ) = __$$MealDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    List<PlateIngredient> ingredients,
    double totalPrice,
    int totalCalories,
    bool available,
  });
}

/// @nodoc
class __$$MealDraftImplCopyWithImpl<$Res>
    extends _$MealDraftCopyWithImpl<$Res, _$MealDraftImpl>
    implements _$$MealDraftImplCopyWith<$Res> {
  __$$MealDraftImplCopyWithImpl(
    _$MealDraftImpl _value,
    $Res Function(_$MealDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? ingredients = null,
    Object? totalPrice = null,
    Object? totalCalories = null,
    Object? available = null,
  }) {
    return _then(
      _$MealDraftImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<PlateIngredient>,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCalories: null == totalCalories
            ? _value.totalCalories
            : totalCalories // ignore: cast_nullable_to_non_nullable
                  as int,
        available: null == available
            ? _value.available
            : available // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MealDraftImpl implements _MealDraft {
  const _$MealDraftImpl({
    required this.id,
    required this.label,
    final List<PlateIngredient> ingredients = const [],
    this.totalPrice = 0.0,
    this.totalCalories = 0,
    this.available = true,
  }) : _ingredients = ingredients;

  @override
  final String id;
  @override
  final String label;
  final List<PlateIngredient> _ingredients;
  @override
  @JsonKey()
  List<PlateIngredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  @override
  @JsonKey()
  final double totalPrice;
  @override
  @JsonKey()
  final int totalCalories;
  @override
  @JsonKey()
  final bool available;

  @override
  String toString() {
    return 'MealDraft(id: $id, label: $label, ingredients: $ingredients, totalPrice: $totalPrice, totalCalories: $totalCalories, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealDraftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    const DeepCollectionEquality().hash(_ingredients),
    totalPrice,
    totalCalories,
    available,
  );

  /// Create a copy of MealDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealDraftImplCopyWith<_$MealDraftImpl> get copyWith =>
      __$$MealDraftImplCopyWithImpl<_$MealDraftImpl>(this, _$identity);
}

abstract class _MealDraft implements MealDraft {
  const factory _MealDraft({
    required final String id,
    required final String label,
    final List<PlateIngredient> ingredients,
    final double totalPrice,
    final int totalCalories,
    final bool available,
  }) = _$MealDraftImpl;

  @override
  String get id;
  @override
  String get label;
  @override
  List<PlateIngredient> get ingredients;
  @override
  double get totalPrice;
  @override
  int get totalCalories;
  @override
  bool get available;

  /// Create a copy of MealDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealDraftImplCopyWith<_$MealDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
