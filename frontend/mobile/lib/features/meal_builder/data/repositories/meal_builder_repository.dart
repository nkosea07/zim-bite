import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/meal_builder_models.dart';

class MealBuilderRepository {
  final Dio _dio;

  MealBuilderRepository(this._dio);

  Future<List<MealPreset>> getPresets() async {
    final response = await _dio.get(ApiEndpoints.mealBuilderPresets);
    return (response.data as List)
        .map((json) => MealPreset.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MealCalculation> calculate(MealCalculateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.mealBuilderCalculate,
      data: request.toJson(),
    );
    return MealCalculation.fromJson(response.data);
  }
}
