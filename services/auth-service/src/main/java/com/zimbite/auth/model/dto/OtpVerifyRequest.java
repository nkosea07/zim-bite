package com.zimbite.auth.model.dto;

import jakarta.validation.constraints.NotBlank;

public record OtpVerifyRequest(
    @NotBlank String principal,
    @NotBlank String otp
) {
}
