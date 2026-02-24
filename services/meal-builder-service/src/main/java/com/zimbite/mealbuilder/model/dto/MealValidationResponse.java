package com.zimbite.mealbuilder.model.dto;

import java.util.List;
import java.util.UUID;

public record MealValidationResponse(
    boolean valid,
    List<UUID> unavailableComponents
) {
}
