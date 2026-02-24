package com.zimbite.user.model.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderHistoryItemResponse(
    UUID orderId,
    UUID vendorId,
    String status,
    BigDecimal totalAmount,
    String currency,
    OffsetDateTime placedAt
) {
}
