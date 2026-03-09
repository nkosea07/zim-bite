package com.zimbite.auth.service;

import com.zimbite.auth.model.dto.AuthTokensResponse;
import com.zimbite.auth.model.dto.LoginChallengeResponse;
import com.zimbite.auth.model.dto.LoginRequest;
import com.zimbite.auth.model.dto.RegisterRequest;
import com.zimbite.auth.model.entity.AuthUserEntity;
import com.zimbite.auth.model.entity.OtpChallengeEntity;
import com.zimbite.auth.model.entity.RefreshTokenEntity;
import com.zimbite.auth.repository.AuthUserRepository;
import com.zimbite.auth.repository.OtpChallengeRepository;
import com.zimbite.auth.repository.RefreshTokenRepository;
import com.zimbite.shared.security.JwtProperties;
import com.zimbite.shared.security.JwtProvider;
import com.zimbite.shared.security.JwtValidator;
import com.zimbite.shared.security.Role;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.Set;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final AuthUserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final OtpChallengeRepository otpChallengeRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;
    private final JwtValidator jwtValidator;
    private final JwtProperties jwtProperties;
    private final long otpTtlSeconds;
    private final int otpMaxAttempts;
    private final String otpDevStaticCode;

    public AuthService(AuthUserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       OtpChallengeRepository otpChallengeRepository,
                       PasswordEncoder passwordEncoder,
                       JwtProvider jwtProvider,
                       JwtValidator jwtValidator,
                       JwtProperties jwtProperties,
                       @Value("${auth.otp.ttl-seconds:300}") long otpTtlSeconds,
                       @Value("${auth.otp.max-attempts:3}") int otpMaxAttempts,
                       @Value("${auth.otp.dev-static-code:}") String otpDevStaticCode) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.otpChallengeRepository = otpChallengeRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtProvider = jwtProvider;
        this.jwtValidator = jwtValidator;
        this.jwtProperties = jwtProperties;
        this.otpTtlSeconds = otpTtlSeconds;
        this.otpMaxAttempts = otpMaxAttempts;
        this.otpDevStaticCode = otpDevStaticCode;
    }

    private static final Set<String> SELF_REGISTERABLE_ROLES = Set.of(
        Role.CUSTOMER.name(), Role.VENDOR_ADMIN.name(), Role.RIDER.name()
    );

    @Transactional
    public void register(RegisterRequest request) {
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
        }
        if (userRepository.findByPhoneNumber(request.phoneNumber()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Phone number already registered");
        }

        String resolvedRole = Role.CUSTOMER.name();
        if (request.role() != null && !request.role().isBlank()) {
            String requested = request.role().trim().toUpperCase();
            if (!SELF_REGISTERABLE_ROLES.contains(requested)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Role '" + request.role() + "' cannot be self-registered");
            }
            resolvedRole = requested;
        }

        OffsetDateTime now = OffsetDateTime.now();
        AuthUserEntity user = new AuthUserEntity();
        user.setId(UUID.randomUUID());
        user.setEmail(request.email());
        user.setPhoneNumber(request.phoneNumber());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setRole(resolvedRole);
        user.setStatus("ACTIVE");
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        userRepository.save(user);
        createOtpChallenge(user.getEmail());
    }

    @Transactional
    public LoginChallengeResponse login(LoginRequest request) {
        String normalizedPrincipal = normalizePrincipal(request.principal());
        AuthUserEntity user = findUserByPrincipal(normalizedPrincipal);

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        OtpChallengeEntity challenge = createOtpChallenge(normalizedPrincipal);
        return new LoginChallengeResponse(
            challenge.getId(),
            challenge.getPrincipal(),
            challenge.getExpiresAt(),
            challenge.getAttemptsRemaining(),
            "OTP_REQUIRED"
        );
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

    @Transactional
    public AuthTokensResponse verifyOtp(String principal, String otp) {
        String normalizedPrincipal = normalizePrincipal(principal);
        OtpChallengeEntity challenge = otpChallengeRepository.findFirstByPrincipalOrderByCreatedAtDesc(normalizedPrincipal)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "OTP challenge not found"));

        OffsetDateTime now = OffsetDateTime.now();
        if (challenge.getConsumedAt() != null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "OTP already consumed");
        }
        if (challenge.getExpiresAt().isBefore(now)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "OTP expired");
        }
        if (challenge.getAttemptsRemaining() <= 0) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "OTP attempts exceeded");
        }

        String otpHash = sha256(otp);
        if (!constantTimeEquals(otpHash, challenge.getOtpHash())) {
            challenge.setAttemptsRemaining(challenge.getAttemptsRemaining() - 1);
            otpChallengeRepository.save(challenge);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid OTP");
        }

        challenge.setConsumedAt(now);
        otpChallengeRepository.save(challenge);
        return issueTokens(findUserByPrincipal(normalizedPrincipal));
    }

    private AuthTokensResponse issueTokens(AuthUserEntity user) {
        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getRole());
        String refreshToken = jwtProvider.generateRefreshToken(user.getId());

        OffsetDateTime now = OffsetDateTime.now();
        RefreshTokenEntity entity = new RefreshTokenEntity();
        entity.setId(UUID.randomUUID());
        entity.setUserId(user.getId());
        entity.setTokenHash(sha256(refreshToken));
        entity.setExpiresAt(now.plusSeconds(jwtProperties.getRefreshTtlSeconds()));
        entity.setRevoked(false);
        entity.setCreatedAt(now);
        refreshTokenRepository.save(entity);

        return new AuthTokensResponse(accessToken, refreshToken, jwtProperties.getAccessTtlSeconds());
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

    private OtpChallengeEntity createOtpChallenge(String principal) {
        String normalizedPrincipal = normalizePrincipal(principal);
        OffsetDateTime now = OffsetDateTime.now();
        String otpValue = generateOtp();

        OtpChallengeEntity challenge = new OtpChallengeEntity();
        challenge.setId(UUID.randomUUID());
        challenge.setPrincipal(normalizedPrincipal);
        challenge.setOtpHash(sha256(otpValue));
        challenge.setExpiresAt(now.plusSeconds(otpTtlSeconds));
        challenge.setAttemptsRemaining(Math.max(otpMaxAttempts, 1));
        challenge.setCreatedAt(now);
        OtpChallengeEntity saved = otpChallengeRepository.save(challenge);

        log.info("OTP challenge issued for principal={}, expiresAt={}, devOtp={}",
            normalizedPrincipal, challenge.getExpiresAt(), otpValue);
        return saved;
    }

    private String generateOtp() {
        if (otpDevStaticCode != null && !otpDevStaticCode.isBlank()) {
            return otpDevStaticCode.trim();
        }
        int code = (int) (Math.random() * 900000) + 100000;
        return String.valueOf(code);
    }

    private String normalizePrincipal(String principal) {
        if (principal == null || principal.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Principal is required");
        }
        String trimmed = principal.trim();
        if (trimmed.contains("@")) {
            return trimmed.toLowerCase();
        }
        return trimmed;
    }

    private AuthUserEntity findUserByPrincipal(String normalizedPrincipal) {
        return userRepository.findByEmail(normalizedPrincipal)
            .or(() -> userRepository.findByPhoneNumber(normalizedPrincipal))
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));
    }

    private boolean constantTimeEquals(String left, String right) {
        return MessageDigest.isEqual(
            left.getBytes(StandardCharsets.UTF_8),
            right.getBytes(StandardCharsets.UTF_8)
        );
    }
}
