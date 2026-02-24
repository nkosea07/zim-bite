package com.zimbite.vendor.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record VendorStatsResponse(
    UUID vendorId,
    int totalOrdersToday,
    BigDecimal grossRevenueToday,
    String currency,
    double averageRating
) {
}
