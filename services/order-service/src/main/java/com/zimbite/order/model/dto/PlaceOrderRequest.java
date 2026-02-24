package com.zimbite.order.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.UUID;

public record PlaceOrderRequest(
    UUID userId,
    @NotNull UUID vendorId,
    @NotNull UUID deliveryAddressId,
    @NotBlank String currency,
    @NotEmpty List<OrderItemRequest> items
) {
}
