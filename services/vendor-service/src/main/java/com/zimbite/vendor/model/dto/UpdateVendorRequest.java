package com.zimbite.vendor.model.dto;

import java.math.BigDecimal;

public record UpdateVendorRequest(
    String name,
    String description,
    String phoneNumber,
    String supportEmail,
    BigDecimal latitude,
    BigDecimal longitude,
    Short averagePrepMinutes,
    BigDecimal deliveryRadiusKm,
    BigDecimal minOrderValue,
    Boolean acceptsCash,
    Boolean active
) {
}
