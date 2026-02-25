// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  DateTime? get nextDelivery => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    String planName,
    String status,
    String frequency,
    DateTime? nextDelivery,
    double amount,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? planName = null,
    Object? status = null,
    Object? frequency = null,
    Object? nextDelivery = freezed,
    Object? amount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorName: null == vendorName
                ? _value.vendorName
                : vendorName // ignore: cast_nullable_to_non_nullable
                      as String,
            planName: null == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDelivery: freezed == nextDelivery
                ? _value.nextDelivery
                : nextDelivery // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    String planName,
    String status,
    String frequency,
    DateTime? nextDelivery,
    double amount,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? planName = null,
    Object? status = null,
    Object? frequency = null,
    Object? nextDelivery = freezed,
    Object? amount = null,
  }) {
    return _then(
      _$SubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorName: null == vendorName
            ? _value.vendorName
            : vendorName // ignore: cast_nullable_to_non_nullable
                  as String,
        planName: null == planName
            ? _value.planName
            : planName // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDelivery: freezed == nextDelivery
            ? _value.nextDelivery
            : nextDelivery // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.planName,
    required this.status,
    required this.frequency,
    this.nextDelivery,
    required this.amount,
  });

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final String planName;
  @override
  final String status;
  @override
  final String frequency;
  @override
  final DateTime? nextDelivery;
  @override
  final double amount;

  @override
  String toString() {
    return 'Subscription(id: $id, vendorId: $vendorId, vendorName: $vendorName, planName: $planName, status: $status, frequency: $frequency, nextDelivery: $nextDelivery, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.nextDelivery, nextDelivery) ||
                other.nextDelivery == nextDelivery) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vendorId,
    vendorName,
    planName,
    status,
    frequency,
    nextDelivery,
    amount,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription({
    required final String id,
    required final String vendorId,
    required final String vendorName,
    required final String planName,
    required final String status,
    required final String frequency,
    final DateTime? nextDelivery,
    required final double amount,
  }) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  String get planName;
  @override
  String get status;
  @override
  String get frequency;
  @override
  DateTime? get nextDelivery;
  @override
  double get amount;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateSubscriptionRequest _$CreateSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateSubscriptionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSubscriptionRequest {
  String get vendorId => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  String get deliveryAddressId => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  List<OrderItemRequest> get items => throw _privateConstructorUsedError;

  /// Serializes this CreateSubscriptionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSubscriptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSubscriptionRequestCopyWith<CreateSubscriptionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSubscriptionRequestCopyWith<$Res> {
  factory $CreateSubscriptionRequestCopyWith(
    CreateSubscriptionRequest value,
    $Res Function(CreateSubscriptionRequest) then,
  ) = _$CreateSubscriptionRequestCopyWithImpl<$Res, CreateSubscriptionRequest>;
  @useResult
  $Res call({
    String vendorId,
    String planName,
    String frequency,
    String deliveryAddressId,
    String paymentMethod,
    List<OrderItemRequest> items,
  });
}

/// @nodoc
class _$CreateSubscriptionRequestCopyWithImpl<
  $Res,
  $Val extends CreateSubscriptionRequest
>
    implements $CreateSubscriptionRequestCopyWith<$Res> {
  _$CreateSubscriptionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSubscriptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? planName = null,
    Object? frequency = null,
    Object? deliveryAddressId = null,
    Object? paymentMethod = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            planName: null == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryAddressId: null == deliveryAddressId
                ? _value.deliveryAddressId
                : deliveryAddressId // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItemRequest>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateSubscriptionRequestImplCopyWith<$Res>
    implements $CreateSubscriptionRequestCopyWith<$Res> {
  factory _$$CreateSubscriptionRequestImplCopyWith(
    _$CreateSubscriptionRequestImpl value,
    $Res Function(_$CreateSubscriptionRequestImpl) then,
  ) = __$$CreateSubscriptionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String vendorId,
    String planName,
    String frequency,
    String deliveryAddressId,
    String paymentMethod,
    List<OrderItemRequest> items,
  });
}

/// @nodoc
class __$$CreateSubscriptionRequestImplCopyWithImpl<$Res>
    extends
        _$CreateSubscriptionRequestCopyWithImpl<
          $Res,
          _$CreateSubscriptionRequestImpl
        >
    implements _$$CreateSubscriptionRequestImplCopyWith<$Res> {
  __$$CreateSubscriptionRequestImplCopyWithImpl(
    _$CreateSubscriptionRequestImpl _value,
    $Res Function(_$CreateSubscriptionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSubscriptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? planName = null,
    Object? frequency = null,
    Object? deliveryAddressId = null,
    Object? paymentMethod = null,
    Object? items = null,
  }) {
    return _then(
      _$CreateSubscriptionRequestImpl(
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        planName: null == planName
            ? _value.planName
            : planName // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryAddressId: null == deliveryAddressId
            ? _value.deliveryAddressId
            : deliveryAddressId // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItemRequest>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSubscriptionRequestImpl implements _CreateSubscriptionRequest {
  const _$CreateSubscriptionRequestImpl({
    required this.vendorId,
    required this.planName,
    required this.frequency,
    required this.deliveryAddressId,
    required this.paymentMethod,
    required final List<OrderItemRequest> items,
  }) : _items = items;

  factory _$CreateSubscriptionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSubscriptionRequestImplFromJson(json);

  @override
  final String vendorId;
  @override
  final String planName;
  @override
  final String frequency;
  @override
  final String deliveryAddressId;
  @override
  final String paymentMethod;
  final List<OrderItemRequest> _items;
  @override
  List<OrderItemRequest> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CreateSubscriptionRequest(vendorId: $vendorId, planName: $planName, frequency: $frequency, deliveryAddressId: $deliveryAddressId, paymentMethod: $paymentMethod, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSubscriptionRequestImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.deliveryAddressId, deliveryAddressId) ||
                other.deliveryAddressId == deliveryAddressId) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    vendorId,
    planName,
    frequency,
    deliveryAddressId,
    paymentMethod,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of CreateSubscriptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSubscriptionRequestImplCopyWith<_$CreateSubscriptionRequestImpl>
  get copyWith =>
      __$$CreateSubscriptionRequestImplCopyWithImpl<
        _$CreateSubscriptionRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSubscriptionRequestImplToJson(this);
  }
}

abstract class _CreateSubscriptionRequest implements CreateSubscriptionRequest {
  const factory _CreateSubscriptionRequest({
    required final String vendorId,
    required final String planName,
    required final String frequency,
    required final String deliveryAddressId,
    required final String paymentMethod,
    required final List<OrderItemRequest> items,
  }) = _$CreateSubscriptionRequestImpl;

  factory _CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateSubscriptionRequestImpl.fromJson;

  @override
  String get vendorId;
  @override
  String get planName;
  @override
  String get frequency;
  @override
  String get deliveryAddressId;
  @override
  String get paymentMethod;
  @override
  List<OrderItemRequest> get items;

  /// Create a copy of CreateSubscriptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSubscriptionRequestImplCopyWith<_$CreateSubscriptionRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
