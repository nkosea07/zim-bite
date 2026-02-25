// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_builder_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealComponentImpl _$$MealComponentImplFromJson(Map<String, dynamic> json) =>
    _$MealComponentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      calories: (json['calories'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$$MealComponentImplToJson(_$MealComponentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'price': instance.price,
      'calories': instance.calories,
      'imageUrl': instance.imageUrl,
    };

_$MealPresetImpl _$$MealPresetImplFromJson(Map<String, dynamic> json) =>
    _$MealPresetImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      components: (json['components'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toInt(),
    );

Map<String, dynamic> _$$MealPresetImplToJson(_$MealPresetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'components': instance.components,
      'totalPrice': instance.totalPrice,
      'totalCalories': instance.totalCalories,
    };

_$MealCalculationImpl _$$MealCalculationImplFromJson(
  Map<String, dynamic> json,
) => _$MealCalculationImpl(
  components: (json['components'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  totalCalories: (json['totalCalories'] as num).toInt(),
);

Map<String, dynamic> _$$MealCalculationImplToJson(
  _$MealCalculationImpl instance,
) => <String, dynamic>{
  'components': instance.components,
  'totalPrice': instance.totalPrice,
  'totalCalories': instance.totalCalories,
};

_$MealCalculateRequestImpl _$$MealCalculateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MealCalculateRequestImpl(
  componentIds: (json['componentIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$MealCalculateRequestImplToJson(
  _$MealCalculateRequestImpl instance,
) => <String, dynamic>{'componentIds': instance.componentIds};
