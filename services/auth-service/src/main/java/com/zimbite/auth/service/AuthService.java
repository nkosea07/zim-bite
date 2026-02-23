package com.zimbite.auth.service;

import com.zimbite.auth.model.dto.AuthTokensResponse;
import com.zimbite.auth.model.dto.LoginRequest;
import com.zimbite.auth.model.dto.RegisterRequest;
import com.zimbite.auth.model.entity.AuthUserEntity;
import com.zimbite.auth.model.entity.RefreshTokenEntity;
import com.zimbite.auth.repository.AuthUserRepository;
import com.zimbite.auth.repository.RefreshTokenRepository;
import com.zimbite.shared.security.JwtProvider;
import com.zimbite.shared.security.JwtValidator;
import com.zimbite.shared.security.Role;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private final AuthUserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;
    private final JwtValidator jwtValidator;

    public AuthService(AuthUserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtProvider jwtProvider,
                       JwtValidator jwtValidator) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtProvider = jwtProvider;
        this.jwtValidator = jwtValidator;
    }

    @Transactional
    public void register(RegisterRequest request) {
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
        }
        if (userRepository.findByPhoneNumber(request.phoneNumber()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Phone number already registered");
        }

        OffsetDateTime now = OffsetDateTime.now();
        AuthUserEntity user = new AuthUserEntity();
        user.setId(UUID.randomUUID());
        user.setEmail(request.email());
        user.setPhoneNumber(request.phoneNumber());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setRole(Role.CUSTOMER.name());
        user.setStatus("ACTIVE");
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        userRepository.save(user);
    }

    @Transactional
    public AuthTokensResponse login(LoginRequest request) {
        AuthUserEntity user = userRepository.findByEmail(request.principal())
                .or(() -> userRepository.findByPhoneNumber(request.principal()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        return issueTokens(user);
    }

    @Transactional
    public AuthTokensResponse refresh(String rawRefreshToken) {
        var claims = jwtValidator.validate(rawRefreshToken)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));

        String tokenType = claims.get("type", String.class);
        if (!"refresh".equals(tokenType)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Not a refresh token");
        }

        String hash = sha256(rawRefreshToken);
        RefreshTokenEntity stored = refreshTokenRepository.findByTokenHash(hash)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token not found"));

        if (stored.isRevoked()) {
            refreshTokenRepository.deleteByUserId(stored.getUserId());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token revoked");
        }

        stored.setRevoked(true);
        refreshTokenRepository.save(stored);

        AuthUserEntity user = userRepository.findById(stored.getUserId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
        return issueTokens(user);
    }

    public void verifyOtp(String principal, String otp) {
        // Stub -- OTP verification deferred to a future stage.
    }

    private AuthTokensResponse issueTokens(AuthUserEntity user) {
        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getRole());
        String refreshToken = jwtProvider.generateRefreshToken(user.getId());

        OffsetDateTime now = OffsetDateTime.now();
        RefreshTokenEntity entity = new RefreshTokenEntity();
        entity.setId(UUID.randomUUID());
        entity.setUserId(user.getId());
        entity.setTokenHash(sha256(refreshToken));
        entity.setExpiresAt(now.plusSeconds(2592000));
        entity.setRevoked(false);
        entity.setCreatedAt(now);
        refreshTokenRepository.save(entity);

        return new AuthTokensResponse(accessToken, refreshToken, 900);
    }

    private String sha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}
