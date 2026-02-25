import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_builder_models.freezed.dart';
part 'meal_builder_models.g.dart';

@freezed
class MealComponent with _$MealComponent {
  const factory MealComponent({
    required String id,
    required String name,
    required String category,
    required double price,
    required int calories,
    required String imageUrl,
  }) = _MealComponent;

  factory MealComponent.fromJson(Map<String, dynamic> json) =>
      _$MealComponentFromJson(json);
}

@freezed
class MealPreset with _$MealPreset {
  const factory MealPreset({
    required String id,
    required String name,
    required List<String> components,
    required double totalPrice,
    required int totalCalories,
  }) = _MealPreset;

  factory MealPreset.fromJson(Map<String, dynamic> json) =>
      _$MealPresetFromJson(json);
}

@freezed
class MealCalculation with _$MealCalculation {
  const factory MealCalculation({
    required List<String> components,
    required double totalPrice,
    required int totalCalories,
  }) = _MealCalculation;

  factory MealCalculation.fromJson(Map<String, dynamic> json) =>
      _$MealCalculationFromJson(json);
}

@freezed
class MealCalculateRequest with _$MealCalculateRequest {
  const factory MealCalculateRequest({
    required List<String> componentIds,
  }) = _MealCalculateRequest;

  factory MealCalculateRequest.fromJson(Map<String, dynamic> json) =>
      _$MealCalculateRequestFromJson(json);
}
