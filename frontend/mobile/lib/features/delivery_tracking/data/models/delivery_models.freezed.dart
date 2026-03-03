// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeliveryTracking _$DeliveryTrackingFromJson(Map<String, dynamic> json) {
  return _DeliveryTracking.fromJson(json);
}

/// @nodoc
mixin _$DeliveryTracking {
  String get deliveryId => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get driverName => throw _privateConstructorUsedError;
  String? get driverPhone => throw _privateConstructorUsedError;
  DateTime? get estimatedArrival => throw _privateConstructorUsedError;
  double? get currentLatitude => throw _privateConstructorUsedError;
  double? get currentLongitude => throw _privateConstructorUsedError;
  double? get deliveryLatitude => throw _privateConstructorUsedError;
  double? get deliveryLongitude => throw _privateConstructorUsedError;

  /// Serializes this DeliveryTracking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryTrackingCopyWith<DeliveryTracking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryTrackingCopyWith<$Res> {
  factory $DeliveryTrackingCopyWith(
    DeliveryTracking value,
    $Res Function(DeliveryTracking) then,
  ) = _$DeliveryTrackingCopyWithImpl<$Res, DeliveryTracking>;
  @useResult
  $Res call({
    String deliveryId,
    String orderId,
    String status,
    String? driverName,
    String? driverPhone,
    DateTime? estimatedArrival,
    double? currentLatitude,
    double? currentLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
  });
}

/// @nodoc
class _$DeliveryTrackingCopyWithImpl<$Res, $Val extends DeliveryTracking>
    implements $DeliveryTrackingCopyWith<$Res> {
  _$DeliveryTrackingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryId = null,
    Object? orderId = null,
    Object? status = null,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? estimatedArrival = freezed,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? deliveryLatitude = freezed,
    Object? deliveryLongitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            deliveryId: null == deliveryId
                ? _value.deliveryId
                : deliveryId // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            driverName: freezed == driverName
                ? _value.driverName
                : driverName // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverPhone: freezed == driverPhone
                ? _value.driverPhone
                : driverPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedArrival: freezed == estimatedArrival
                ? _value.estimatedArrival
                : estimatedArrival // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            currentLatitude: freezed == currentLatitude
                ? _value.currentLatitude
                : currentLatitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            currentLongitude: freezed == currentLongitude
                ? _value.currentLongitude
                : currentLongitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            deliveryLatitude: freezed == deliveryLatitude
                ? _value.deliveryLatitude
                : deliveryLatitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            deliveryLongitude: freezed == deliveryLongitude
                ? _value.deliveryLongitude
                : deliveryLongitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryTrackingImplCopyWith<$Res>
    implements $DeliveryTrackingCopyWith<$Res> {
  factory _$$DeliveryTrackingImplCopyWith(
    _$DeliveryTrackingImpl value,
    $Res Function(_$DeliveryTrackingImpl) then,
  ) = __$$DeliveryTrackingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deliveryId,
    String orderId,
    String status,
    String? driverName,
    String? driverPhone,
    DateTime? estimatedArrival,
    double? currentLatitude,
    double? currentLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
  });
}

/// @nodoc
class __$$DeliveryTrackingImplCopyWithImpl<$Res>
    extends _$DeliveryTrackingCopyWithImpl<$Res, _$DeliveryTrackingImpl>
    implements _$$DeliveryTrackingImplCopyWith<$Res> {
  __$$DeliveryTrackingImplCopyWithImpl(
    _$DeliveryTrackingImpl _value,
    $Res Function(_$DeliveryTrackingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryId = null,
    Object? orderId = null,
    Object? status = null,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? estimatedArrival = freezed,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? deliveryLatitude = freezed,
    Object? deliveryLongitude = freezed,
  }) {
    return _then(
      _$DeliveryTrackingImpl(
        deliveryId: null == deliveryId
            ? _value.deliveryId
            : deliveryId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        driverName: freezed == driverName
            ? _value.driverName
            : driverName // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverPhone: freezed == driverPhone
            ? _value.driverPhone
            : driverPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedArrival: freezed == estimatedArrival
            ? _value.estimatedArrival
            : estimatedArrival // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        currentLatitude: freezed == currentLatitude
            ? _value.currentLatitude
            : currentLatitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        currentLongitude: freezed == currentLongitude
            ? _value.currentLongitude
            : currentLongitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        deliveryLatitude: freezed == deliveryLatitude
            ? _value.deliveryLatitude
            : deliveryLatitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        deliveryLongitude: freezed == deliveryLongitude
            ? _value.deliveryLongitude
            : deliveryLongitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryTrackingImpl implements _DeliveryTracking {
  const _$DeliveryTrackingImpl({
    required this.deliveryId,
    required this.orderId,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.estimatedArrival,
    this.currentLatitude,
    this.currentLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  factory _$DeliveryTrackingImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryTrackingImplFromJson(json);

  @override
  final String deliveryId;
  @override
  final String orderId;
  @override
  final String status;
  @override
  final String? driverName;
  @override
  final String? driverPhone;
  @override
  final DateTime? estimatedArrival;
  @override
  final double? currentLatitude;
  @override
  final double? currentLongitude;
  @override
  final double? deliveryLatitude;
  @override
  final double? deliveryLongitude;

  @override
  String toString() {
    return 'DeliveryTracking(deliveryId: $deliveryId, orderId: $orderId, status: $status, driverName: $driverName, driverPhone: $driverPhone, estimatedArrival: $estimatedArrival, currentLatitude: $currentLatitude, currentLongitude: $currentLongitude, deliveryLatitude: $deliveryLatitude, deliveryLongitude: $deliveryLongitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryTrackingImpl &&
            (identical(other.deliveryId, deliveryId) ||
                other.deliveryId == deliveryId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.driverName, driverName) ||
                other.driverName == driverName) &&
            (identical(other.driverPhone, driverPhone) ||
                other.driverPhone == driverPhone) &&
            (identical(other.estimatedArrival, estimatedArrival) ||
                other.estimatedArrival == estimatedArrival) &&
            (identical(other.currentLatitude, currentLatitude) ||
                other.currentLatitude == currentLatitude) &&
            (identical(other.currentLongitude, currentLongitude) ||
                other.currentLongitude == currentLongitude) &&
            (identical(other.deliveryLatitude, deliveryLatitude) ||
                other.deliveryLatitude == deliveryLatitude) &&
            (identical(other.deliveryLongitude, deliveryLongitude) ||
                other.deliveryLongitude == deliveryLongitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deliveryId,
    orderId,
    status,
    driverName,
    driverPhone,
    estimatedArrival,
    currentLatitude,
    currentLongitude,
    deliveryLatitude,
    deliveryLongitude,
  );

  /// Create a copy of DeliveryTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryTrackingImplCopyWith<_$DeliveryTrackingImpl> get copyWith =>
      __$$DeliveryTrackingImplCopyWithImpl<_$DeliveryTrackingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryTrackingImplToJson(this);
  }
}

abstract class _DeliveryTracking implements DeliveryTracking {
  const factory _DeliveryTracking({
    required final String deliveryId,
    required final String orderId,
    required final String status,
    final String? driverName,
    final String? driverPhone,
    final DateTime? estimatedArrival,
    final double? currentLatitude,
    final double? currentLongitude,
    final double? deliveryLatitude,
    final double? deliveryLongitude,
  }) = _$DeliveryTrackingImpl;

  factory _DeliveryTracking.fromJson(Map<String, dynamic> json) =
      _$DeliveryTrackingImpl.fromJson;

  @override
  String get deliveryId;
  @override
  String get orderId;
  @override
  String get status;
  @override
  String? get driverName;
  @override
  String? get driverPhone;
  @override
  DateTime? get estimatedArrival;
  @override
  double? get currentLatitude;
  @override
  double? get currentLongitude;
  @override
  double? get deliveryLatitude;
  @override
  double? get deliveryLongitude;

  /// Create a copy of DeliveryTracking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryTrackingImplCopyWith<_$DeliveryTrackingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
