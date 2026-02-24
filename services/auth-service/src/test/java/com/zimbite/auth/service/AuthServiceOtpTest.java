package com.zimbite.auth.service;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.zimbite.auth.model.entity.OtpChallengeEntity;
import com.zimbite.auth.repository.AuthUserRepository;
import com.zimbite.auth.repository.OtpChallengeRepository;
import com.zimbite.auth.repository.RefreshTokenRepository;
import com.zimbite.shared.security.JwtProperties;
import com.zimbite.shared.security.JwtProvider;
import com.zimbite.shared.security.JwtValidator;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class AuthServiceOtpTest {

  @Mock
  private AuthUserRepository userRepository;

  @Mock
  private RefreshTokenRepository refreshTokenRepository;

  @Mock
  private OtpChallengeRepository otpChallengeRepository;

  private AuthService authService;

  @BeforeEach
  void setUp() {
    JwtProperties jwtProperties = new JwtProperties();
    jwtProperties.setSecret("zimbite-dev-secret-key-min-32-bytes!!");

    authService = new AuthService(
        userRepository,
        refreshTokenRepository,
        otpChallengeRepository,
        new BCryptPasswordEncoder(),
        new JwtProvider(jwtProperties),
        new JwtValidator(jwtProperties),
        300,
        3,
        "123456"
    );
  }

  @Test
  void verifyOtpConsumesValidChallenge() {
    OtpChallengeEntity challenge = new OtpChallengeEntity();
    challenge.setId(UUID.randomUUID());
    challenge.setPrincipal("user@example.com");
    challenge.setOtpHash(sha256("123456"));
    challenge.setExpiresAt(OffsetDateTime.now().plusMinutes(5));
    challenge.setAttemptsRemaining(3);
    challenge.setCreatedAt(OffsetDateTime.now());

    when(otpChallengeRepository.findFirstByPrincipalOrderByCreatedAtDesc("user@example.com"))
        .thenReturn(Optional.of(challenge));
    when(otpChallengeRepository.save(any(OtpChallengeEntity.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    authService.verifyOtp("User@Example.com", "123456");

    assertNotNull(challenge.getConsumedAt());
  }

  @Test
  void verifyOtpRejectsInvalidCode() {
    OtpChallengeEntity challenge = new OtpChallengeEntity();
    challenge.setId(UUID.randomUUID());
    challenge.setPrincipal("user@example.com");
    challenge.setOtpHash(sha256("123456"));
    challenge.setExpiresAt(OffsetDateTime.now().plusMinutes(5));
    challenge.setAttemptsRemaining(3);
    challenge.setCreatedAt(OffsetDateTime.now());

    when(otpChallengeRepository.findFirstByPrincipalOrderByCreatedAtDesc("user@example.com"))
        .thenReturn(Optional.of(challenge));
    when(otpChallengeRepository.save(any(OtpChallengeEntity.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    assertThrows(ResponseStatusException.class, () -> authService.verifyOtp("user@example.com", "000000"));
  }

  private String sha256(String input) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
      return HexFormat.of().formatHex(hash);
    } catch (Exception ex) {
      throw new IllegalStateException(ex);
    }
  }
}
