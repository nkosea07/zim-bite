package com.zimbite.shared.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.UUID;
import javax.crypto.SecretKey;

public class JwtValidator {

    private final SecretKey key;
    private final String issuer;

    public JwtValidator(JwtProperties properties) {
        this.key = Keys.hmacShaKeyFor(properties.getSecret().getBytes(StandardCharsets.UTF_8));
        this.issuer = properties.getIssuer();
    }

    public Optional<Claims> validate(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(key)
                    .requireIssuer(issuer)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return Optional.of(claims);
        } catch (JwtException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }

    public Optional<UUID> extractUserId(String token) {
        return validate(token).map(c -> UUID.fromString(c.getSubject()));
    }

    public Optional<String> extractRole(String token) {
        return validate(token).map(c -> c.get("role", String.class));
    }
}
