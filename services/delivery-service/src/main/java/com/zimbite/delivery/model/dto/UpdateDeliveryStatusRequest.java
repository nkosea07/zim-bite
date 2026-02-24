package com.zimbite.delivery.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record UpdateDeliveryStatusRequest(
    @NotNull UUID orderId,
    @NotNull UUID riderId,
    @NotBlank String status
) {
}
