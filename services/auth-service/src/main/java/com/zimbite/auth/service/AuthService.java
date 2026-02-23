package com.zimbite.auth.service;

import com.zimbite.auth.model.dto.AuthTokensResponse;
import com.zimbite.auth.model.dto.LoginRequest;
import com.zimbite.auth.model.dto.RegisterRequest;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  public void register(RegisterRequest request) {
    // Placeholder for persistence and user onboarding workflows.
  }

  public AuthTokensResponse login(LoginRequest request) {
    return issueTokens();
  }

  public AuthTokensResponse refresh(String refreshToken) {
    return issueTokens();
  }

  public void verifyOtp(String principal, String otp) {
    // Placeholder for OTP provider verification.
  }

  private AuthTokensResponse issueTokens() {
    return new AuthTokensResponse(
        "acc-" + UUID.randomUUID(),
        "ref-" + UUID.randomUUID(),
        900
    );
  }
}
