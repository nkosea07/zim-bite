package com.zimbite.menu.model.dto;

import java.math.BigDecimal;

public record UpdateMenuItemRequest(
    String name,
    String category,
    BigDecimal basePrice,
    String currency
) {
}
