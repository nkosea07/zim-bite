package com.zimbite.auth.controller;

import com.zimbite.auth.model.dto.AuthTokensResponse;
import com.zimbite.auth.model.dto.LoginChallengeResponse;
import com.zimbite.auth.model.dto.LoginRequest;
import com.zimbite.auth.model.dto.OtpVerifyRequest;
import com.zimbite.auth.model.dto.RegisterRequest;
import com.zimbite.auth.model.dto.TokenRefreshRequest;
import com.zimbite.auth.service.AuthService;
import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/register")
  public ResponseEntity<Map<String, String>> register(@Valid @RequestBody RegisterRequest request) {
    authService.register(request);
    return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("status", "registered"));
  }

  @PostMapping("/login")
  public ResponseEntity<LoginChallengeResponse> login(@Valid @RequestBody LoginRequest request) {
    return ResponseEntity.status(HttpStatus.ACCEPTED).body(authService.login(request));
  }

  @PostMapping("/refresh")
  public ResponseEntity<AuthTokensResponse> refresh(@Valid @RequestBody TokenRefreshRequest request) {
    return ResponseEntity.ok(authService.refresh(request.refreshToken()));
  }

  @PostMapping("/verify-otp")
  public ResponseEntity<AuthTokensResponse> verifyOtp(@Valid @RequestBody OtpVerifyRequest request) {
    return ResponseEntity.ok(authService.verifyOtp(request.principal(), request.otp()));
  }
}
