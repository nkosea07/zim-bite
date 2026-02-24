package com.zimbite.mealbuilder.model.dto;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record MealComponentRequest(
    @NotNull UUID componentId,
    @NotNull BigDecimal quantity
) {
}
