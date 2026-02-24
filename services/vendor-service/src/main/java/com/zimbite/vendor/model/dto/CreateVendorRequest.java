package com.zimbite.vendor.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateVendorRequest(
    @NotBlank String name,
    @NotBlank String city,
    @NotNull Double latitude,
    @NotNull Double longitude,
    Boolean open
) {
}
