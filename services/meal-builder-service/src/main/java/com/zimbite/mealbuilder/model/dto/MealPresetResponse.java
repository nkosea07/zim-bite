package com.zimbite.mealbuilder.model.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record MealPresetResponse(
    UUID presetId,
    String name,
    UUID vendorId,
    UUID baseItemId,
    List<MealComponentRequest> components,
    OffsetDateTime createdAt
) {
}
