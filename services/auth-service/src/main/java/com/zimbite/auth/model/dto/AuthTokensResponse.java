package com.zimbite.auth.model.dto;

public record AuthTokensResponse(
    String accessToken,
    String refreshToken,
    long expiresIn
) {
}
