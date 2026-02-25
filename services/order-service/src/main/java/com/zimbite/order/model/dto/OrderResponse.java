package com.zimbite.order.model.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderResponse(
    UUID orderId,
    String status,
    BigDecimal totalAmount,
    String currency,
    OffsetDateTime scheduledFor
) {
}
