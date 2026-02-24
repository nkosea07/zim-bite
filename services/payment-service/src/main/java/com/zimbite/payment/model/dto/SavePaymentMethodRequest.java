package com.zimbite.payment.model.dto;

import jakarta.validation.constraints.NotBlank;

public record SavePaymentMethodRequest(
    @NotBlank String provider,
    @NotBlank String tokenReference,
    @NotBlank String last4
) {
}
