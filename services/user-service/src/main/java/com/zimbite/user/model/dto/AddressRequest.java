package com.zimbite.user.model.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;

public record AddressRequest(
    @NotBlank String label,
    @NotBlank String line1,
    String line2,
    @NotBlank String city,
    String area,
    @DecimalMin("-90.0") @DecimalMax("90.0") Double latitude,
    @DecimalMin("-180.0") @DecimalMax("180.0") Double longitude
) {
}
