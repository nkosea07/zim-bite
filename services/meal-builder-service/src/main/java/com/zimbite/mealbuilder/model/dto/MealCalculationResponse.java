package com.zimbite.mealbuilder.model.dto;

import java.math.BigDecimal;

public record MealCalculationResponse(
    BigDecimal totalPrice,
    int estimatedCalories,
    boolean available
) {
}
