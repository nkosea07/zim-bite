// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rider_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RiderDelivery _$RiderDeliveryFromJson(Map<String, dynamic> json) {
  return _RiderDelivery.fromJson(json);
}

/// @nodoc
mixin _$RiderDelivery {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  String get deliveryAddress => throw _privateConstructorUsedError;
  double get pickupLat => throw _privateConstructorUsedError;
  double get pickupLng => throw _privateConstructorUsedError;
  double get dropoffLat => throw _privateConstructorUsedError;
  double get dropoffLng => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;

  /// Serializes this RiderDelivery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RiderDelivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RiderDeliveryCopyWith<RiderDelivery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiderDeliveryCopyWith<$Res> {
  factory $RiderDeliveryCopyWith(
    RiderDelivery value,
    $Res Function(RiderDelivery) then,
  ) = _$RiderDeliveryCopyWithImpl<$Res, RiderDelivery>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String vendorName,
    String pickupAddress,
    String deliveryAddress,
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
    double totalAmount,
    String status,
    String? customerId,
    String? customerPhone,
  });
}

/// @nodoc
class _$RiderDeliveryCopyWithImpl<$Res, $Val extends RiderDelivery>
    implements $RiderDeliveryCopyWith<$Res> {
  _$RiderDeliveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RiderDelivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vendorName = null,
    Object? pickupAddress = null,
    Object? deliveryAddress = null,
    Object? pickupLat = null,
    Object? pickupLng = null,
    Object? dropoffLat = null,
    Object? dropoffLng = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? customerPhone = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorName: null == vendorName
                ? _value.vendorName
                : vendorName // ignore: cast_nullable_to_non_nullable
                      as String,
            pickupAddress: null == pickupAddress
                ? _value.pickupAddress
                : pickupAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryAddress: null == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            pickupLat: null == pickupLat
                ? _value.pickupLat
                : pickupLat // ignore: cast_nullable_to_non_nullable
                      as double,
            pickupLng: null == pickupLng
                ? _value.pickupLng
                : pickupLng // ignore: cast_nullable_to_non_nullable
                      as double,
            dropoffLat: null == dropoffLat
                ? _value.dropoffLat
                : dropoffLat // ignore: cast_nullable_to_non_nullable
                      as double,
            dropoffLng: null == dropoffLng
                ? _value.dropoffLng
                : dropoffLng // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RiderDeliveryImplCopyWith<$Res>
    implements $RiderDeliveryCopyWith<$Res> {
  factory _$$RiderDeliveryImplCopyWith(
    _$RiderDeliveryImpl value,
    $Res Function(_$RiderDeliveryImpl) then,
  ) = __$$RiderDeliveryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String vendorName,
    String pickupAddress,
    String deliveryAddress,
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
    double totalAmount,
    String status,
    String? customerId,
    String? customerPhone,
  });
}

/// @nodoc
class __$$RiderDeliveryImplCopyWithImpl<$Res>
    extends _$RiderDeliveryCopyWithImpl<$Res, _$RiderDeliveryImpl>
    implements _$$RiderDeliveryImplCopyWith<$Res> {
  __$$RiderDeliveryImplCopyWithImpl(
    _$RiderDeliveryImpl _value,
    $Res Function(_$RiderDeliveryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RiderDelivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vendorName = null,
    Object? pickupAddress = null,
    Object? deliveryAddress = null,
    Object? pickupLat = null,
    Object? pickupLng = null,
    Object? dropoffLat = null,
    Object? dropoffLng = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? customerPhone = freezed,
  }) {
    return _then(
      _$RiderDeliveryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorName: null == vendorName
            ? _value.vendorName
            : vendorName // ignore: cast_nullable_to_non_nullable
                  as String,
        pickupAddress: null == pickupAddress
            ? _value.pickupAddress
            : pickupAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryAddress: null == deliveryAddress
            ? _value.deliveryAddress
            : deliveryAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        pickupLat: null == pickupLat
            ? _value.pickupLat
            : pickupLat // ignore: cast_nullable_to_non_nullable
                  as double,
        pickupLng: null == pickupLng
            ? _value.pickupLng
            : pickupLng // ignore: cast_nullable_to_non_nullable
                  as double,
        dropoffLat: null == dropoffLat
            ? _value.dropoffLat
            : dropoffLat // ignore: cast_nullable_to_non_nullable
                  as double,
        dropoffLng: null == dropoffLng
            ? _value.dropoffLng
            : dropoffLng // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RiderDeliveryImpl implements _RiderDelivery {
  const _$RiderDeliveryImpl({
    required this.id,
    required this.orderId,
    this.vendorName = 'Vendor',
    this.pickupAddress = 'Pickup location',
    this.deliveryAddress = 'Delivery address',
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.totalAmount = 0.0,
    required this.status,
    this.customerId,
    this.customerPhone,
  });

  factory _$RiderDeliveryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiderDeliveryImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  @JsonKey()
  final String vendorName;
  @override
  @JsonKey()
  final String pickupAddress;
  @override
  @JsonKey()
  final String deliveryAddress;
  @override
  final double pickupLat;
  @override
  final double pickupLng;
  @override
  final double dropoffLat;
  @override
  final double dropoffLng;
  @override
  @JsonKey()
  final double totalAmount;
  @override
  final String status;
  @override
  final String? customerId;
  @override
  final String? customerPhone;

  @override
  String toString() {
    return 'RiderDelivery(id: $id, orderId: $orderId, vendorName: $vendorName, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress, pickupLat: $pickupLat, pickupLng: $pickupLng, dropoffLat: $dropoffLat, dropoffLng: $dropoffLng, totalAmount: $totalAmount, status: $status, customerId: $customerId, customerPhone: $customerPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiderDeliveryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.pickupLat, pickupLat) ||
                other.pickupLat == pickupLat) &&
            (identical(other.pickupLng, pickupLng) ||
                other.pickupLng == pickupLng) &&
            (identical(other.dropoffLat, dropoffLat) ||
                other.dropoffLat == dropoffLat) &&
            (identical(other.dropoffLng, dropoffLng) ||
                other.dropoffLng == dropoffLng) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    vendorName,
    pickupAddress,
    deliveryAddress,
    pickupLat,
    pickupLng,
    dropoffLat,
    dropoffLng,
    totalAmount,
    status,
    customerId,
    customerPhone,
  );

  /// Create a copy of RiderDelivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RiderDeliveryImplCopyWith<_$RiderDeliveryImpl> get copyWith =>
      __$$RiderDeliveryImplCopyWithImpl<_$RiderDeliveryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiderDeliveryImplToJson(this);
  }
}

abstract class _RiderDelivery implements RiderDelivery {
  const factory _RiderDelivery({
    required final String id,
    required final String orderId,
    final String vendorName,
    final String pickupAddress,
    final String deliveryAddress,
    required final double pickupLat,
    required final double pickupLng,
    required final double dropoffLat,
    required final double dropoffLng,
    final double totalAmount,
    required final String status,
    final String? customerId,
    final String? customerPhone,
  }) = _$RiderDeliveryImpl;

  factory _RiderDelivery.fromJson(Map<String, dynamic> json) =
      _$RiderDeliveryImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get vendorName;
  @override
  String get pickupAddress;
  @override
  String get deliveryAddress;
  @override
  double get pickupLat;
  @override
  double get pickupLng;
  @override
  double get dropoffLat;
  @override
  double get dropoffLng;
  @override
  double get totalAmount;
  @override
  String get status;
  @override
  String? get customerId;
  @override
  String? get customerPhone;

  /// Create a copy of RiderDelivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RiderDeliveryImplCopyWith<_$RiderDeliveryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get deliveryId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderRole => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get sentAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String deliveryId,
    String senderId,
    String senderRole,
    String body,
    DateTime sentAt,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deliveryId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? body = null,
    Object? sentAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryId: null == deliveryId
                ? _value.deliveryId
                : deliveryId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderRole: null == senderRole
                ? _value.senderRole
                : senderRole // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            sentAt: null == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String deliveryId,
    String senderId,
    String senderRole,
    String body,
    DateTime sentAt,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deliveryId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? body = null,
    Object? sentAt = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryId: null == deliveryId
            ? _value.deliveryId
            : deliveryId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderRole: null == senderRole
            ? _value.senderRole
            : senderRole // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        sentAt: null == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.deliveryId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.sentAt,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String deliveryId;
  @override
  final String senderId;
  @override
  final String senderRole;
  @override
  final String body;
  @override
  final DateTime sentAt;

  @override
  String toString() {
    return 'ChatMessage(id: $id, deliveryId: $deliveryId, senderId: $senderId, senderRole: $senderRole, body: $body, sentAt: $sentAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deliveryId, deliveryId) ||
                other.deliveryId == deliveryId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    deliveryId,
    senderId,
    senderRole,
    body,
    sentAt,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String deliveryId,
    required final String senderId,
    required final String senderRole,
    required final String body,
    required final DateTime sentAt,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get deliveryId;
  @override
  String get senderId;
  @override
  String get senderRole;
  @override
  String get body;
  @override
  DateTime get sentAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationUpdate _$LocationUpdateFromJson(Map<String, dynamic> json) {
  return _LocationUpdate.fromJson(json);
}

/// @nodoc
mixin _$LocationUpdate {
  String get deliveryId => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  double? get speedKmh => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;

  /// Serializes this LocationUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationUpdateCopyWith<LocationUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationUpdateCopyWith<$Res> {
  factory $LocationUpdateCopyWith(
    LocationUpdate value,
    $Res Function(LocationUpdate) then,
  ) = _$LocationUpdateCopyWithImpl<$Res, LocationUpdate>;
  @useResult
  $Res call({
    String deliveryId,
    double lat,
    double lng,
    double? heading,
    double? speedKmh,
    int timestamp,
  });
}

/// @nodoc
class _$LocationUpdateCopyWithImpl<$Res, $Val extends LocationUpdate>
    implements $LocationUpdateCopyWith<$Res> {
  _$LocationUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryId = null,
    Object? lat = null,
    Object? lng = null,
    Object? heading = freezed,
    Object? speedKmh = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            deliveryId: null == deliveryId
                ? _value.deliveryId
                : deliveryId // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            heading: freezed == heading
                ? _value.heading
                : heading // ignore: cast_nullable_to_non_nullable
                      as double?,
            speedKmh: freezed == speedKmh
                ? _value.speedKmh
                : speedKmh // ignore: cast_nullable_to_non_nullable
                      as double?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationUpdateImplCopyWith<$Res>
    implements $LocationUpdateCopyWith<$Res> {
  factory _$$LocationUpdateImplCopyWith(
    _$LocationUpdateImpl value,
    $Res Function(_$LocationUpdateImpl) then,
  ) = __$$LocationUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deliveryId,
    double lat,
    double lng,
    double? heading,
    double? speedKmh,
    int timestamp,
  });
}

/// @nodoc
class __$$LocationUpdateImplCopyWithImpl<$Res>
    extends _$LocationUpdateCopyWithImpl<$Res, _$LocationUpdateImpl>
    implements _$$LocationUpdateImplCopyWith<$Res> {
  __$$LocationUpdateImplCopyWithImpl(
    _$LocationUpdateImpl _value,
    $Res Function(_$LocationUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryId = null,
    Object? lat = null,
    Object? lng = null,
    Object? heading = freezed,
    Object? speedKmh = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$LocationUpdateImpl(
        deliveryId: null == deliveryId
            ? _value.deliveryId
            : deliveryId // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        heading: freezed == heading
            ? _value.heading
            : heading // ignore: cast_nullable_to_non_nullable
                  as double?,
        speedKmh: freezed == speedKmh
            ? _value.speedKmh
            : speedKmh // ignore: cast_nullable_to_non_nullable
                  as double?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationUpdateImpl implements _LocationUpdate {
  const _$LocationUpdateImpl({
    required this.deliveryId,
    required this.lat,
    required this.lng,
    this.heading,
    this.speedKmh,
    required this.timestamp,
  });

  factory _$LocationUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationUpdateImplFromJson(json);

  @override
  final String deliveryId;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final double? heading;
  @override
  final double? speedKmh;
  @override
  final int timestamp;

  @override
  String toString() {
    return 'LocationUpdate(deliveryId: $deliveryId, lat: $lat, lng: $lng, heading: $heading, speedKmh: $speedKmh, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationUpdateImpl &&
            (identical(other.deliveryId, deliveryId) ||
                other.deliveryId == deliveryId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.speedKmh, speedKmh) ||
                other.speedKmh == speedKmh) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deliveryId,
    lat,
    lng,
    heading,
    speedKmh,
    timestamp,
  );

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationUpdateImplCopyWith<_$LocationUpdateImpl> get copyWith =>
      __$$LocationUpdateImplCopyWithImpl<_$LocationUpdateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationUpdateImplToJson(this);
  }
}

abstract class _LocationUpdate implements LocationUpdate {
  const factory _LocationUpdate({
    required final String deliveryId,
    required final double lat,
    required final double lng,
    final double? heading,
    final double? speedKmh,
    required final int timestamp,
  }) = _$LocationUpdateImpl;

  factory _LocationUpdate.fromJson(Map<String, dynamic> json) =
      _$LocationUpdateImpl.fromJson;

  @override
  String get deliveryId;
  @override
  double get lat;
  @override
  double get lng;
  @override
  double? get heading;
  @override
  double? get speedKmh;
  @override
  int get timestamp;

  /// Create a copy of LocationUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationUpdateImplCopyWith<_$LocationUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
