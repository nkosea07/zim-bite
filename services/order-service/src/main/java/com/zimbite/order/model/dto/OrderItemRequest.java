package com.zimbite.order.model.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record OrderItemRequest(
    @NotNull UUID menuItemId,
    @NotNull Integer quantity
) {
}
