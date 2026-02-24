package com.zimbite.shared.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtKeyRotationRehearsalTest {

  @Test
  void oldTokensAreRejectedAfterSecretRotationAndNewTokensValidate() {
    UUID userId = UUID.randomUUID();

    JwtProperties oldKeyProperties = new JwtProperties();
    oldKeyProperties.setSecret("zimbite-old-signing-secret-minimum-32-bytes!!");
    oldKeyProperties.setIssuer("zimbite");

    JwtProperties newKeyProperties = new JwtProperties();
    newKeyProperties.setSecret("zimbite-new-signing-secret-minimum-32-bytes!!");
    newKeyProperties.setIssuer("zimbite");

    String tokenFromOldKey = new JwtProvider(oldKeyProperties).generateAccessToken(userId, "CUSTOMER");
    JwtValidator oldValidator = new JwtValidator(oldKeyProperties);
    JwtValidator newValidator = new JwtValidator(newKeyProperties);

    assertTrue(oldValidator.validate(tokenFromOldKey).isPresent());
    assertTrue(newValidator.validate(tokenFromOldKey).isEmpty());

    String tokenFromNewKey = new JwtProvider(newKeyProperties).generateAccessToken(userId, "CUSTOMER");
    assertTrue(newValidator.validate(tokenFromNewKey).isPresent());
    assertEquals(userId.toString(), newValidator.validate(tokenFromNewKey).orElseThrow().getSubject());
  }
}
