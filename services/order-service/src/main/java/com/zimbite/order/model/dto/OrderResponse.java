package com.zimbite.order.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record OrderResponse(
    UUID orderId,
    String status,
    BigDecimal totalAmount,
    String currency
) {
}
