package com.zimbite.shared.security;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Optional;
import java.util.UUID;

public final class UserContext {

    private UserContext() {
    }

    public static Optional<UUID> getUserId(HttpServletRequest request) {
        String header = request.getHeader(SecurityHeaders.USER_ID);
        if (header == null || header.isBlank()) {
            return Optional.empty();
        }
        return Optional.of(UUID.fromString(header));
    }
}
