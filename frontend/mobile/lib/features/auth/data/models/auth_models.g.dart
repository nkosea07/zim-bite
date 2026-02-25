// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      principal: json['principal'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'password': instance.password,
    };

_$LoginChallengeResponseImpl _$$LoginChallengeResponseImplFromJson(
  Map<String, dynamic> json,
) => _$LoginChallengeResponseImpl(
  challengeId: json['challengeId'] as String,
  principal: json['principal'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  attemptsRemaining: (json['attemptsRemaining'] as num).toInt(),
  status: json['status'] as String,
);

Map<String, dynamic> _$$LoginChallengeResponseImplToJson(
  _$LoginChallengeResponseImpl instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'principal': instance.principal,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'attemptsRemaining': instance.attemptsRemaining,
  'status': instance.status,
};

_$OtpVerifyRequestImpl _$$OtpVerifyRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OtpVerifyRequestImpl(
  principal: json['principal'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$$OtpVerifyRequestImplToJson(
  _$OtpVerifyRequestImpl instance,
) => <String, dynamic>{'principal': instance.principal, 'otp': instance.otp};

_$AuthTokensResponseImpl _$$AuthTokensResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AuthTokensResponseImpl(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
);

Map<String, dynamic> _$$AuthTokensResponseImplToJson(
  _$AuthTokensResponseImpl instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
};

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestImpl(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'password': instance.password,
};
