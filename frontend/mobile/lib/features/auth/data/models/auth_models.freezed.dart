// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get principal => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
    LoginRequest value,
    $Res Function(LoginRequest) then,
  ) = _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String principal, String password});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? principal = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            principal: null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
    _$LoginRequestImpl value,
    $Res Function(_$LoginRequestImpl) then,
  ) = __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String principal, String password});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
    _$LoginRequestImpl _value,
    $Res Function(_$LoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? principal = null, Object? password = null}) {
    return _then(
      _$LoginRequestImpl(
        principal: null == principal
            ? _value.principal
            : principal // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl({required this.principal, required this.password});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String principal;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequest(principal: $principal, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, principal, password);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(this);
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest({
    required final String principal,
    required final String password,
  }) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get principal;
  @override
  String get password;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginChallengeResponse _$LoginChallengeResponseFromJson(
  Map<String, dynamic> json,
) {
  return _LoginChallengeResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginChallengeResponse {
  String get challengeId => throw _privateConstructorUsedError;
  String get principal => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  int get attemptsRemaining => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this LoginChallengeResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginChallengeResponseCopyWith<LoginChallengeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginChallengeResponseCopyWith<$Res> {
  factory $LoginChallengeResponseCopyWith(
    LoginChallengeResponse value,
    $Res Function(LoginChallengeResponse) then,
  ) = _$LoginChallengeResponseCopyWithImpl<$Res, LoginChallengeResponse>;
  @useResult
  $Res call({
    String challengeId,
    String principal,
    DateTime expiresAt,
    int attemptsRemaining,
    String status,
  });
}

/// @nodoc
class _$LoginChallengeResponseCopyWithImpl<
  $Res,
  $Val extends LoginChallengeResponse
>
    implements $LoginChallengeResponseCopyWith<$Res> {
  _$LoginChallengeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? principal = null,
    Object? expiresAt = null,
    Object? attemptsRemaining = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            challengeId: null == challengeId
                ? _value.challengeId
                : challengeId // ignore: cast_nullable_to_non_nullable
                      as String,
            principal: null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            attemptsRemaining: null == attemptsRemaining
                ? _value.attemptsRemaining
                : attemptsRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$LoginChallengeResponseImplCopyWith<$Res>
    implements $LoginChallengeResponseCopyWith<$Res> {
  factory _$$LoginChallengeResponseImplCopyWith(
    _$LoginChallengeResponseImpl value,
    $Res Function(_$LoginChallengeResponseImpl) then,
  ) = __$$LoginChallengeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String challengeId,
    String principal,
    DateTime expiresAt,
    int attemptsRemaining,
    String status,
  });
}

/// @nodoc
class __$$LoginChallengeResponseImplCopyWithImpl<$Res>
    extends
        _$LoginChallengeResponseCopyWithImpl<$Res, _$LoginChallengeResponseImpl>
    implements _$$LoginChallengeResponseImplCopyWith<$Res> {
  __$$LoginChallengeResponseImplCopyWithImpl(
    _$LoginChallengeResponseImpl _value,
    $Res Function(_$LoginChallengeResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? principal = null,
    Object? expiresAt = null,
    Object? attemptsRemaining = null,
    Object? status = null,
  }) {
    return _then(
      _$LoginChallengeResponseImpl(
        challengeId: null == challengeId
            ? _value.challengeId
            : challengeId // ignore: cast_nullable_to_non_nullable
                  as String,
        principal: null == principal
            ? _value.principal
            : principal // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        attemptsRemaining: null == attemptsRemaining
            ? _value.attemptsRemaining
            : attemptsRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$LoginChallengeResponseImpl implements _LoginChallengeResponse {
  const _$LoginChallengeResponseImpl({
    required this.challengeId,
    required this.principal,
    required this.expiresAt,
    required this.attemptsRemaining,
    required this.status,
  });

  factory _$LoginChallengeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginChallengeResponseImplFromJson(json);

  @override
  final String challengeId;
  @override
  final String principal;
  @override
  final DateTime expiresAt;
  @override
  final int attemptsRemaining;
  @override
  final String status;

  @override
  String toString() {
    return 'LoginChallengeResponse(challengeId: $challengeId, principal: $principal, expiresAt: $expiresAt, attemptsRemaining: $attemptsRemaining, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginChallengeResponseImpl &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.attemptsRemaining, attemptsRemaining) ||
                other.attemptsRemaining == attemptsRemaining) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    challengeId,
    principal,
    expiresAt,
    attemptsRemaining,
    status,
  );

  /// Create a copy of LoginChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginChallengeResponseImplCopyWith<_$LoginChallengeResponseImpl>
  get copyWith =>
      __$$LoginChallengeResponseImplCopyWithImpl<_$LoginChallengeResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginChallengeResponseImplToJson(this);
  }
}

abstract class _LoginChallengeResponse implements LoginChallengeResponse {
  const factory _LoginChallengeResponse({
    required final String challengeId,
    required final String principal,
    required final DateTime expiresAt,
    required final int attemptsRemaining,
    required final String status,
  }) = _$LoginChallengeResponseImpl;

  factory _LoginChallengeResponse.fromJson(Map<String, dynamic> json) =
      _$LoginChallengeResponseImpl.fromJson;

  @override
  String get challengeId;
  @override
  String get principal;
  @override
  DateTime get expiresAt;
  @override
  int get attemptsRemaining;
  @override
  String get status;

  /// Create a copy of LoginChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginChallengeResponseImplCopyWith<_$LoginChallengeResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OtpVerifyRequest _$OtpVerifyRequestFromJson(Map<String, dynamic> json) {
  return _OtpVerifyRequest.fromJson(json);
}

/// @nodoc
mixin _$OtpVerifyRequest {
  String get principal => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;

  /// Serializes this OtpVerifyRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtpVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpVerifyRequestCopyWith<OtpVerifyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpVerifyRequestCopyWith<$Res> {
  factory $OtpVerifyRequestCopyWith(
    OtpVerifyRequest value,
    $Res Function(OtpVerifyRequest) then,
  ) = _$OtpVerifyRequestCopyWithImpl<$Res, OtpVerifyRequest>;
  @useResult
  $Res call({String principal, String otp});
}

/// @nodoc
class _$OtpVerifyRequestCopyWithImpl<$Res, $Val extends OtpVerifyRequest>
    implements $OtpVerifyRequestCopyWith<$Res> {
  _$OtpVerifyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? principal = null, Object? otp = null}) {
    return _then(
      _value.copyWith(
            principal: null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                      as String,
            otp: null == otp
                ? _value.otp
                : otp // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OtpVerifyRequestImplCopyWith<$Res>
    implements $OtpVerifyRequestCopyWith<$Res> {
  factory _$$OtpVerifyRequestImplCopyWith(
    _$OtpVerifyRequestImpl value,
    $Res Function(_$OtpVerifyRequestImpl) then,
  ) = __$$OtpVerifyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String principal, String otp});
}

/// @nodoc
class __$$OtpVerifyRequestImplCopyWithImpl<$Res>
    extends _$OtpVerifyRequestCopyWithImpl<$Res, _$OtpVerifyRequestImpl>
    implements _$$OtpVerifyRequestImplCopyWith<$Res> {
  __$$OtpVerifyRequestImplCopyWithImpl(
    _$OtpVerifyRequestImpl _value,
    $Res Function(_$OtpVerifyRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OtpVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? principal = null, Object? otp = null}) {
    return _then(
      _$OtpVerifyRequestImpl(
        principal: null == principal
            ? _value.principal
            : principal // ignore: cast_nullable_to_non_nullable
                  as String,
        otp: null == otp
            ? _value.otp
            : otp // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpVerifyRequestImpl implements _OtpVerifyRequest {
  const _$OtpVerifyRequestImpl({required this.principal, required this.otp});

  factory _$OtpVerifyRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpVerifyRequestImplFromJson(json);

  @override
  final String principal;
  @override
  final String otp;

  @override
  String toString() {
    return 'OtpVerifyRequest(principal: $principal, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpVerifyRequestImpl &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.otp, otp) || other.otp == otp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, principal, otp);

  /// Create a copy of OtpVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpVerifyRequestImplCopyWith<_$OtpVerifyRequestImpl> get copyWith =>
      __$$OtpVerifyRequestImplCopyWithImpl<_$OtpVerifyRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpVerifyRequestImplToJson(this);
  }
}

abstract class _OtpVerifyRequest implements OtpVerifyRequest {
  const factory _OtpVerifyRequest({
    required final String principal,
    required final String otp,
  }) = _$OtpVerifyRequestImpl;

  factory _OtpVerifyRequest.fromJson(Map<String, dynamic> json) =
      _$OtpVerifyRequestImpl.fromJson;

  @override
  String get principal;
  @override
  String get otp;

  /// Create a copy of OtpVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpVerifyRequestImplCopyWith<_$OtpVerifyRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthTokensResponse _$AuthTokensResponseFromJson(Map<String, dynamic> json) {
  return _AuthTokensResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthTokensResponse {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  int? get expiresIn => throw _privateConstructorUsedError;

  /// Serializes this AuthTokensResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthTokensResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthTokensResponseCopyWith<AuthTokensResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthTokensResponseCopyWith<$Res> {
  factory $AuthTokensResponseCopyWith(
    AuthTokensResponse value,
    $Res Function(AuthTokensResponse) then,
  ) = _$AuthTokensResponseCopyWithImpl<$Res, AuthTokensResponse>;
  @useResult
  $Res call({String accessToken, String refreshToken, int? expiresIn});
}

/// @nodoc
class _$AuthTokensResponseCopyWithImpl<$Res, $Val extends AuthTokensResponse>
    implements $AuthTokensResponseCopyWith<$Res> {
  _$AuthTokensResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthTokensResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresIn = freezed,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresIn: freezed == expiresIn
                ? _value.expiresIn
                : expiresIn // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthTokensResponseImplCopyWith<$Res>
    implements $AuthTokensResponseCopyWith<$Res> {
  factory _$$AuthTokensResponseImplCopyWith(
    _$AuthTokensResponseImpl value,
    $Res Function(_$AuthTokensResponseImpl) then,
  ) = __$$AuthTokensResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String refreshToken, int? expiresIn});
}

/// @nodoc
class __$$AuthTokensResponseImplCopyWithImpl<$Res>
    extends _$AuthTokensResponseCopyWithImpl<$Res, _$AuthTokensResponseImpl>
    implements _$$AuthTokensResponseImplCopyWith<$Res> {
  __$$AuthTokensResponseImplCopyWithImpl(
    _$AuthTokensResponseImpl _value,
    $Res Function(_$AuthTokensResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthTokensResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresIn = freezed,
  }) {
    return _then(
      _$AuthTokensResponseImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresIn: freezed == expiresIn
            ? _value.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthTokensResponseImpl implements _AuthTokensResponse {
  const _$AuthTokensResponseImpl({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory _$AuthTokensResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthTokensResponseImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final int? expiresIn;

  @override
  String toString() {
    return 'AuthTokensResponse(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthTokensResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, expiresIn);

  /// Create a copy of AuthTokensResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthTokensResponseImplCopyWith<_$AuthTokensResponseImpl> get copyWith =>
      __$$AuthTokensResponseImplCopyWithImpl<_$AuthTokensResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthTokensResponseImplToJson(this);
  }
}

abstract class _AuthTokensResponse implements AuthTokensResponse {
  const factory _AuthTokensResponse({
    required final String accessToken,
    required final String refreshToken,
    final int? expiresIn,
  }) = _$AuthTokensResponseImpl;

  factory _AuthTokensResponse.fromJson(Map<String, dynamic> json) =
      _$AuthTokensResponseImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  int? get expiresIn;

  /// Create a copy of AuthTokensResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthTokensResponseImplCopyWith<_$AuthTokensResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) {
  return _RegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequest {
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(
    RegisterRequest value,
    $Res Function(RegisterRequest) then,
  ) = _$RegisterRequestCopyWithImpl<$Res, RegisterRequest>;
  @useResult
  $Res call({
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
    String? role,
  });
}

/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res, $Val extends RegisterRequest>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? password = null,
    Object? role = freezed,
  }) {
    return _then(
      _value.copyWith(
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterRequestImplCopyWith<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  factory _$$RegisterRequestImplCopyWith(
    _$RegisterRequestImpl value,
    $Res Function(_$RegisterRequestImpl) then,
  ) = __$$RegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
    String? role,
  });
}

/// @nodoc
class __$$RegisterRequestImplCopyWithImpl<$Res>
    extends _$RegisterRequestCopyWithImpl<$Res, _$RegisterRequestImpl>
    implements _$$RegisterRequestImplCopyWith<$Res> {
  __$$RegisterRequestImplCopyWithImpl(
    _$RegisterRequestImpl _value,
    $Res Function(_$RegisterRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? password = null,
    Object? role = freezed,
  }) {
    return _then(
      _$RegisterRequestImpl(
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestImpl implements _RegisterRequest {
  const _$RegisterRequestImpl({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.role,
  });

  factory _$RegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestImplFromJson(json);

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final String phoneNumber;
  @override
  final String password;
  @override
  final String? role;

  @override
  String toString() {
    return 'RegisterRequest(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, password: $password, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    firstName,
    lastName,
    email,
    phoneNumber,
    password,
    role,
  );

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      __$$RegisterRequestImplCopyWithImpl<_$RegisterRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestImplToJson(this);
  }
}

abstract class _RegisterRequest implements RegisterRequest {
  const factory _RegisterRequest({
    required final String firstName,
    required final String lastName,
    required final String email,
    required final String phoneNumber,
    required final String password,
    final String? role,
  }) = _$RegisterRequestImpl;

  factory _RegisterRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestImpl.fromJson;

  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  String get password;
  @override
  String? get role;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
