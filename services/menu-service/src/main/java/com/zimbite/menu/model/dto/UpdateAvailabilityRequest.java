package com.zimbite.menu.model.dto;

import jakarta.validation.constraints.NotNull;

public record UpdateAvailabilityRequest(
    @NotNull Boolean available
) {
}
