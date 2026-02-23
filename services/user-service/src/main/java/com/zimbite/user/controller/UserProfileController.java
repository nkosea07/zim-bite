package com.zimbite.user.controller;

import com.zimbite.user.model.dto.UpdateProfileRequest;
import com.zimbite.user.model.dto.UserProfileResponse;
import com.zimbite.user.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class UserProfileController {

  private final UserProfileService userProfileService;

  public UserProfileController(UserProfileService userProfileService) {
    this.userProfileService = userProfileService;
  }

  @GetMapping("/profile")
  public ResponseEntity<UserProfileResponse> getProfile() {
    return ResponseEntity.ok(userProfileService.getCurrentProfile());
  }

  @PatchMapping("/profile")
  public ResponseEntity<UserProfileResponse> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
    return ResponseEntity.ok(userProfileService.updateCurrentProfile(request));
  }
}
