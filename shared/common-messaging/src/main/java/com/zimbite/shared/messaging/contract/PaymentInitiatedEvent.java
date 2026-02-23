package com.zimbite.shared.messaging.contract;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentInitiatedEvent(
    UUID paymentId,
    UUID orderId,
    BigDecimal amount,
    String currency,
    String provider,
    OffsetDateTime initiatedAt
) {
}
