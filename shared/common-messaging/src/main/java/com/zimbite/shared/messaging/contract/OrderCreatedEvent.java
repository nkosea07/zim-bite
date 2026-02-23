package com.zimbite.shared.messaging.contract;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderCreatedEvent(
    UUID orderId,
    UUID userId,
    UUID vendorId,
    BigDecimal totalAmount,
    String currency,
    OffsetDateTime createdAt
) {
}
