package com.zimbite.payment.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record InitiatePaymentRequest(
    @NotNull UUID orderId,
    @NotBlank String provider,
    @NotNull BigDecimal amount,
    @NotBlank String currency
) {
}
