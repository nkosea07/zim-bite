package com.zimbite.vendor.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record VendorResponse(
    UUID id,
    String name,
    String slug,
    String description,
    String phoneNumber,
    String city,
    BigDecimal latitude,
    BigDecimal longitude,
    short averagePrepMinutes,
    BigDecimal deliveryRadiusKm,
    BigDecimal minOrderValue,
    boolean acceptsCash,
    boolean open,
    BigDecimal ratingAvg
) {
}
