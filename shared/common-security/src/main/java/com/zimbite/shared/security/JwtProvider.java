package com.zimbite.shared.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;

public class JwtProvider {

    private final SecretKey key;
    private final JwtProperties properties;

    public JwtProvider(JwtProperties properties) {
        this.properties = properties;
        this.key = Keys.hmacShaKeyFor(properties.getSecret().getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(UUID userId, String role) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + properties.getAccessTtlSeconds() * 1000);
        return Jwts.builder()
                .subject(userId.toString())
                .claim("role", role)
                .issuer(properties.getIssuer())
                .issuedAt(now)
                .expiration(expiry)
                .signWith(key)
                .compact();
    }

    public String generateRefreshToken(UUID userId) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + properties.getRefreshTtlSeconds() * 1000);
        return Jwts.builder()
                .subject(userId.toString())
                .claim("type", "refresh")
                .issuer(properties.getIssuer())
                .issuedAt(now)
                .expiration(expiry)
                .signWith(key)
                .compact();
    }
}
