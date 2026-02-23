package com.zimbite.menu.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record CreateMenuItemRequest(
    @NotBlank String name,
    @NotNull BigDecimal basePrice,
    @NotBlank String currency
) {
}
