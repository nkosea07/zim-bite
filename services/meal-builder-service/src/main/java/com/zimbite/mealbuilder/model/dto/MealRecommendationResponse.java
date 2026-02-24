package com.zimbite.mealbuilder.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record MealRecommendationResponse(
    UUID recommendationId,
    String name,
    BigDecimal estimatedPrice,
    int estimatedCalories
) {
}
