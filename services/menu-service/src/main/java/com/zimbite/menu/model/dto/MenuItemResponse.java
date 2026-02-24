package com.zimbite.menu.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record MenuItemResponse(
    UUID id,
    UUID vendorId,
    String name,
    String category,
    BigDecimal basePrice,
    String currency,
    boolean available
) {
}
