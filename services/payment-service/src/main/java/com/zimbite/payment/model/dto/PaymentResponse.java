package com.zimbite.payment.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record PaymentResponse(
    UUID paymentId,
    UUID orderId,
    String provider,
    String status,
    BigDecimal amount,
    String currency
) {
}
