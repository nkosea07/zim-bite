package com.zimbite.payment.model.dto;

import java.util.UUID;

public record SavePaymentMethodResponse(
    UUID paymentMethodId,
    String provider,
    String last4,
    String status,
    boolean isDefault
) {
}
