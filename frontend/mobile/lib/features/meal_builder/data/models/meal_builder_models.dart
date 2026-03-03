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

// ── Local-only models for drag-and-drop meal builder ──

@Freezed(toJson: false, fromJson: false)
class PlateIngredient with _$PlateIngredient {
  const factory PlateIngredient({
    required String componentId,
    required String name,
    required String category,
    required double price,
    required int calories,
    required int quantity,
    @Default(0.5) double plateX,
    @Default(0.5) double plateY,
  }) = _PlateIngredient;
}

@Freezed(toJson: false, fromJson: false)
class MealDraft with _$MealDraft {
  const factory MealDraft({
    required String id,
    required String label,
    @Default([]) List<PlateIngredient> ingredients,
    @Default(0.0) double totalPrice,
    @Default(0) int totalCalories,
    @Default(true) bool available,
  }) = _MealDraft;
}
