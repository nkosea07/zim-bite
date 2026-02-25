// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderItemRequest _$OrderItemRequestFromJson(Map<String, dynamic> json) {
  return _OrderItemRequest.fromJson(json);
}

/// @nodoc
mixin _$OrderItemRequest {
  String get menuItemId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this OrderItemRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemRequestCopyWith<OrderItemRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemRequestCopyWith<$Res> {
  factory $OrderItemRequestCopyWith(
    OrderItemRequest value,
    $Res Function(OrderItemRequest) then,
  ) = _$OrderItemRequestCopyWithImpl<$Res, OrderItemRequest>;
  @useResult
  $Res call({String menuItemId, int quantity, double unitPrice});
}

/// @nodoc
class _$OrderItemRequestCopyWithImpl<$Res, $Val extends OrderItemRequest>
    implements $OrderItemRequestCopyWith<$Res> {
  _$OrderItemRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _value.copyWith(
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemRequestImplCopyWith<$Res>
    implements $OrderItemRequestCopyWith<$Res> {
  factory _$$OrderItemRequestImplCopyWith(
    _$OrderItemRequestImpl value,
    $Res Function(_$OrderItemRequestImpl) then,
  ) = __$$OrderItemRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String menuItemId, int quantity, double unitPrice});
}

/// @nodoc
class __$$OrderItemRequestImplCopyWithImpl<$Res>
    extends _$OrderItemRequestCopyWithImpl<$Res, _$OrderItemRequestImpl>
    implements _$$OrderItemRequestImplCopyWith<$Res> {
  __$$OrderItemRequestImplCopyWithImpl(
    _$OrderItemRequestImpl _value,
    $Res Function(_$OrderItemRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _$OrderItemRequestImpl(
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemRequestImpl implements _OrderItemRequest {
  const _$OrderItemRequestImpl({
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
  });

  factory _$OrderItemRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemRequestImplFromJson(json);

  @override
  final String menuItemId;
  @override
  final int quantity;
  @override
  final double unitPrice;

  @override
  String toString() {
    return 'OrderItemRequest(menuItemId: $menuItemId, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemRequestImpl &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, menuItemId, quantity, unitPrice);

  /// Create a copy of OrderItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemRequestImplCopyWith<_$OrderItemRequestImpl> get copyWith =>
      __$$OrderItemRequestImplCopyWithImpl<_$OrderItemRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemRequestImplToJson(this);
  }
}

abstract class _OrderItemRequest implements OrderItemRequest {
  const factory _OrderItemRequest({
    required final String menuItemId,
    required final int quantity,
    required final double unitPrice,
  }) = _$OrderItemRequestImpl;

  factory _OrderItemRequest.fromJson(Map<String, dynamic> json) =
      _$OrderItemRequestImpl.fromJson;

  @override
  String get menuItemId;
  @override
  int get quantity;
  @override
  double get unitPrice;

  /// Create a copy of OrderItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemRequestImplCopyWith<_$OrderItemRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaceOrderRequest _$PlaceOrderRequestFromJson(Map<String, dynamic> json) {
  return _PlaceOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$PlaceOrderRequest {
  String get vendorId => throw _privateConstructorUsedError;
  List<OrderItemRequest> get items => throw _privateConstructorUsedError;
  String get deliveryAddressId => throw _privateConstructorUsedError;
  DateTime? get scheduledFor => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;

  /// Serializes this PlaceOrderRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceOrderRequestCopyWith<PlaceOrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceOrderRequestCopyWith<$Res> {
  factory $PlaceOrderRequestCopyWith(
    PlaceOrderRequest value,
    $Res Function(PlaceOrderRequest) then,
  ) = _$PlaceOrderRequestCopyWithImpl<$Res, PlaceOrderRequest>;
  @useResult
  $Res call({
    String vendorId,
    List<OrderItemRequest> items,
    String deliveryAddressId,
    DateTime? scheduledFor,
    String paymentMethod,
  });
}

/// @nodoc
class _$PlaceOrderRequestCopyWithImpl<$Res, $Val extends PlaceOrderRequest>
    implements $PlaceOrderRequestCopyWith<$Res> {
  _$PlaceOrderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? items = null,
    Object? deliveryAddressId = null,
    Object? scheduledFor = freezed,
    Object? paymentMethod = null,
  }) {
    return _then(
      _value.copyWith(
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItemRequest>,
            deliveryAddressId: null == deliveryAddressId
                ? _value.deliveryAddressId
                : deliveryAddressId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledFor: freezed == scheduledFor
                ? _value.scheduledFor
                : scheduledFor // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceOrderRequestImplCopyWith<$Res>
    implements $PlaceOrderRequestCopyWith<$Res> {
  factory _$$PlaceOrderRequestImplCopyWith(
    _$PlaceOrderRequestImpl value,
    $Res Function(_$PlaceOrderRequestImpl) then,
  ) = __$$PlaceOrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String vendorId,
    List<OrderItemRequest> items,
    String deliveryAddressId,
    DateTime? scheduledFor,
    String paymentMethod,
  });
}

/// @nodoc
class __$$PlaceOrderRequestImplCopyWithImpl<$Res>
    extends _$PlaceOrderRequestCopyWithImpl<$Res, _$PlaceOrderRequestImpl>
    implements _$$PlaceOrderRequestImplCopyWith<$Res> {
  __$$PlaceOrderRequestImplCopyWithImpl(
    _$PlaceOrderRequestImpl _value,
    $Res Function(_$PlaceOrderRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? items = null,
    Object? deliveryAddressId = null,
    Object? scheduledFor = freezed,
    Object? paymentMethod = null,
  }) {
    return _then(
      _$PlaceOrderRequestImpl(
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItemRequest>,
        deliveryAddressId: null == deliveryAddressId
            ? _value.deliveryAddressId
            : deliveryAddressId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledFor: freezed == scheduledFor
            ? _value.scheduledFor
            : scheduledFor // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceOrderRequestImpl implements _PlaceOrderRequest {
  const _$PlaceOrderRequestImpl({
    required this.vendorId,
    required final List<OrderItemRequest> items,
    required this.deliveryAddressId,
    this.scheduledFor,
    required this.paymentMethod,
  }) : _items = items;

  factory _$PlaceOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceOrderRequestImplFromJson(json);

  @override
  final String vendorId;
  final List<OrderItemRequest> _items;
  @override
  List<OrderItemRequest> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String deliveryAddressId;
  @override
  final DateTime? scheduledFor;
  @override
  final String paymentMethod;

  @override
  String toString() {
    return 'PlaceOrderRequest(vendorId: $vendorId, items: $items, deliveryAddressId: $deliveryAddressId, scheduledFor: $scheduledFor, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceOrderRequestImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.deliveryAddressId, deliveryAddressId) ||
                other.deliveryAddressId == deliveryAddressId) &&
            (identical(other.scheduledFor, scheduledFor) ||
                other.scheduledFor == scheduledFor) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    vendorId,
    const DeepCollectionEquality().hash(_items),
    deliveryAddressId,
    scheduledFor,
    paymentMethod,
  );

  /// Create a copy of PlaceOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceOrderRequestImplCopyWith<_$PlaceOrderRequestImpl> get copyWith =>
      __$$PlaceOrderRequestImplCopyWithImpl<_$PlaceOrderRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceOrderRequestImplToJson(this);
  }
}

abstract class _PlaceOrderRequest implements PlaceOrderRequest {
  const factory _PlaceOrderRequest({
    required final String vendorId,
    required final List<OrderItemRequest> items,
    required final String deliveryAddressId,
    final DateTime? scheduledFor,
    required final String paymentMethod,
  }) = _$PlaceOrderRequestImpl;

  factory _PlaceOrderRequest.fromJson(Map<String, dynamic> json) =
      _$PlaceOrderRequestImpl.fromJson;

  @override
  String get vendorId;
  @override
  List<OrderItemRequest> get items;
  @override
  String get deliveryAddressId;
  @override
  DateTime? get scheduledFor;
  @override
  String get paymentMethod;

  /// Create a copy of PlaceOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceOrderRequestImplCopyWith<_$PlaceOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentInitiateRequest _$PaymentInitiateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentInitiateRequest.fromJson(json);
}

/// @nodoc
mixin _$PaymentInitiateRequest {
  String get orderId => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this PaymentInitiateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentInitiateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentInitiateRequestCopyWith<PaymentInitiateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentInitiateRequestCopyWith<$Res> {
  factory $PaymentInitiateRequestCopyWith(
    PaymentInitiateRequest value,
    $Res Function(PaymentInitiateRequest) then,
  ) = _$PaymentInitiateRequestCopyWithImpl<$Res, PaymentInitiateRequest>;
  @useResult
  $Res call({String orderId, String method, double amount, String currency});
}

/// @nodoc
class _$PaymentInitiateRequestCopyWithImpl<
  $Res,
  $Val extends PaymentInitiateRequest
>
    implements $PaymentInitiateRequestCopyWith<$Res> {
  _$PaymentInitiateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentInitiateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? method = null,
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentInitiateRequestImplCopyWith<$Res>
    implements $PaymentInitiateRequestCopyWith<$Res> {
  factory _$$PaymentInitiateRequestImplCopyWith(
    _$PaymentInitiateRequestImpl value,
    $Res Function(_$PaymentInitiateRequestImpl) then,
  ) = __$$PaymentInitiateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String orderId, String method, double amount, String currency});
}

/// @nodoc
class __$$PaymentInitiateRequestImplCopyWithImpl<$Res>
    extends
        _$PaymentInitiateRequestCopyWithImpl<$Res, _$PaymentInitiateRequestImpl>
    implements _$$PaymentInitiateRequestImplCopyWith<$Res> {
  __$$PaymentInitiateRequestImplCopyWithImpl(
    _$PaymentInitiateRequestImpl _value,
    $Res Function(_$PaymentInitiateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentInitiateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? method = null,
    Object? amount = null,
    Object? currency = null,
  }) {
    return _then(
      _$PaymentInitiateRequestImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentInitiateRequestImpl implements _PaymentInitiateRequest {
  const _$PaymentInitiateRequestImpl({
    required this.orderId,
    required this.method,
    required this.amount,
    required this.currency,
  });

  factory _$PaymentInitiateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentInitiateRequestImplFromJson(json);

  @override
  final String orderId;
  @override
  final String method;
  @override
  final double amount;
  @override
  final String currency;

  @override
  String toString() {
    return 'PaymentInitiateRequest(orderId: $orderId, method: $method, amount: $amount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInitiateRequestImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, method, amount, currency);

  /// Create a copy of PaymentInitiateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentInitiateRequestImplCopyWith<_$PaymentInitiateRequestImpl>
  get copyWith =>
      __$$PaymentInitiateRequestImplCopyWithImpl<_$PaymentInitiateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentInitiateRequestImplToJson(this);
  }
}

abstract class _PaymentInitiateRequest implements PaymentInitiateRequest {
  const factory _PaymentInitiateRequest({
    required final String orderId,
    required final String method,
    required final double amount,
    required final String currency,
  }) = _$PaymentInitiateRequestImpl;

  factory _PaymentInitiateRequest.fromJson(Map<String, dynamic> json) =
      _$PaymentInitiateRequestImpl.fromJson;

  @override
  String get orderId;
  @override
  String get method;
  @override
  double get amount;
  @override
  String get currency;

  /// Create a copy of PaymentInitiateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentInitiateRequestImplCopyWith<_$PaymentInitiateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PaymentInitiateResponse _$PaymentInitiateResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentInitiateResponse.fromJson(json);
}

/// @nodoc
mixin _$PaymentInitiateResponse {
  String get paymentId => throw _privateConstructorUsedError;
  String? get redirectUrl => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this PaymentInitiateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentInitiateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentInitiateResponseCopyWith<PaymentInitiateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentInitiateResponseCopyWith<$Res> {
  factory $PaymentInitiateResponseCopyWith(
    PaymentInitiateResponse value,
    $Res Function(PaymentInitiateResponse) then,
  ) = _$PaymentInitiateResponseCopyWithImpl<$Res, PaymentInitiateResponse>;
  @useResult
  $Res call({String paymentId, String? redirectUrl, String status});
}

/// @nodoc
class _$PaymentInitiateResponseCopyWithImpl<
  $Res,
  $Val extends PaymentInitiateResponse
>
    implements $PaymentInitiateResponseCopyWith<$Res> {
  _$PaymentInitiateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentInitiateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? redirectUrl = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            paymentId: null == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String,
            redirectUrl: freezed == redirectUrl
                ? _value.redirectUrl
                : redirectUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentInitiateResponseImplCopyWith<$Res>
    implements $PaymentInitiateResponseCopyWith<$Res> {
  factory _$$PaymentInitiateResponseImplCopyWith(
    _$PaymentInitiateResponseImpl value,
    $Res Function(_$PaymentInitiateResponseImpl) then,
  ) = __$$PaymentInitiateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String paymentId, String? redirectUrl, String status});
}

/// @nodoc
class __$$PaymentInitiateResponseImplCopyWithImpl<$Res>
    extends
        _$PaymentInitiateResponseCopyWithImpl<
          $Res,
          _$PaymentInitiateResponseImpl
        >
    implements _$$PaymentInitiateResponseImplCopyWith<$Res> {
  __$$PaymentInitiateResponseImplCopyWithImpl(
    _$PaymentInitiateResponseImpl _value,
    $Res Function(_$PaymentInitiateResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentInitiateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? redirectUrl = freezed,
    Object? status = null,
  }) {
    return _then(
      _$PaymentInitiateResponseImpl(
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        redirectUrl: freezed == redirectUrl
            ? _value.redirectUrl
            : redirectUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentInitiateResponseImpl implements _PaymentInitiateResponse {
  const _$PaymentInitiateResponseImpl({
    required this.paymentId,
    this.redirectUrl,
    required this.status,
  });

  factory _$PaymentInitiateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentInitiateResponseImplFromJson(json);

  @override
  final String paymentId;
  @override
  final String? redirectUrl;
  @override
  final String status;

  @override
  String toString() {
    return 'PaymentInitiateResponse(paymentId: $paymentId, redirectUrl: $redirectUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInitiateResponseImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.redirectUrl, redirectUrl) ||
                other.redirectUrl == redirectUrl) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, paymentId, redirectUrl, status);

  /// Create a copy of PaymentInitiateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentInitiateResponseImplCopyWith<_$PaymentInitiateResponseImpl>
  get copyWith =>
      __$$PaymentInitiateResponseImplCopyWithImpl<
        _$PaymentInitiateResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentInitiateResponseImplToJson(this);
  }
}

abstract class _PaymentInitiateResponse implements PaymentInitiateResponse {
  const factory _PaymentInitiateResponse({
    required final String paymentId,
    final String? redirectUrl,
    required final String status,
  }) = _$PaymentInitiateResponseImpl;

  factory _PaymentInitiateResponse.fromJson(Map<String, dynamic> json) =
      _$PaymentInitiateResponseImpl.fromJson;

  @override
  String get paymentId;
  @override
  String? get redirectUrl;
  @override
  String get status;

  /// Create a copy of PaymentInitiateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentInitiateResponseImplCopyWith<_$PaymentInitiateResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
