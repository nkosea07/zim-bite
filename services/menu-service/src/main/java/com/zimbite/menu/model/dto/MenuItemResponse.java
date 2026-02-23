package com.zimbite.menu.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record MenuItemResponse(
    UUID id,
    UUID vendorId,
    String name,
    BigDecimal basePrice,
    String currency,
    boolean available
) {
}
