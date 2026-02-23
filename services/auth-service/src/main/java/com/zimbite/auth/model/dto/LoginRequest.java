package com.zimbite.auth.model.dto;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
    @NotBlank String principal,
    @NotBlank String password
) {
}
