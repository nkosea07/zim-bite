package com.zimbite.gateway.config;

import static org.junit.jupiter.api.Assertions.assertTrue;

import com.zimbite.shared.security.JwtProperties;
import com.zimbite.shared.security.JwtProvider;
import com.zimbite.shared.security.JwtValidator;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtConfigTest {

  @Test
  void createsWorkingJwtBeans() {
    JwtConfig config = new JwtConfig();
    JwtProperties properties = config.jwtProperties("zimbite-dev-secret-key-min-32-bytes!!", 900, 2592000);
    JwtProvider provider = new JwtProvider(properties);
    JwtValidator validator = config.jwtValidator(properties);

    String token = provider.generateAccessToken(UUID.randomUUID(), "CUSTOMER");
    assertTrue(validator.validate(token).isPresent());
  }
}
