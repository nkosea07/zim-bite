package com.zimbite.mealbuilder.model.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.UUID;

public record MealCompositionRequest(
    @NotNull UUID vendorId,
    @NotNull UUID baseItemId,
    @NotEmpty List<MealComponentRequest> components
) {
}
