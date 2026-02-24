package com.zimbite.payment.model.dto;

import java.util.UUID;

public record PaymentMethodResponse(
    UUID paymentMethodId,
    String provider,
    String last4,
    boolean isDefault
) {
}
