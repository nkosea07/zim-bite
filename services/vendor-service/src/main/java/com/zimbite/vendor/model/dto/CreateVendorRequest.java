package com.zimbite.vendor.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record CreateVendorRequest(
    UUID ownerUserId,
    @NotBlank String name,
    @NotBlank String phoneNumber,
    String supportEmail,
    String description,
    @NotNull BigDecimal latitude,
    @NotNull BigDecimal longitude
) {
}
