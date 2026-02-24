package com.zimbite.user.controller;

import com.zimbite.user.model.dto.AddressRequest;
import com.zimbite.user.model.dto.AddressResponse;
import com.zimbite.user.model.dto.FavoriteItemRequest;
import com.zimbite.user.model.dto.FavoriteItemResponse;
import com.zimbite.user.model.dto.OrderHistoryItemResponse;
import com.zimbite.user.model.dto.UpdateProfileRequest;
import com.zimbite.user.model.dto.UserProfileResponse;
import com.zimbite.user.service.UserProfileService;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/users")
public class UserProfileController {

  private final UserProfileService userProfileService;

  public UserProfileController(UserProfileService userProfileService) {
    this.userProfileService = userProfileService;
  }

  @GetMapping("/profile")
  public ResponseEntity<UserProfileResponse> getProfile(HttpServletRequest request) {
    return ResponseEntity.ok(userProfileService.getCurrentProfile(currentUserId(request)));
  }

  @PatchMapping("/profile")
  public ResponseEntity<UserProfileResponse> updateProfile(
      HttpServletRequest request,
      @Valid @RequestBody UpdateProfileRequest payload
  ) {
    return ResponseEntity.ok(userProfileService.updateCurrentProfile(currentUserId(request), payload));
  }

  @GetMapping("/addresses")
  public ResponseEntity<List<AddressResponse>> listAddresses(HttpServletRequest request) {
    return ResponseEntity.ok(userProfileService.listAddresses(currentUserId(request)));
  }

  @PostMapping("/addresses")
  public ResponseEntity<AddressResponse> addAddress(
      HttpServletRequest request,
      @Valid @RequestBody AddressRequest payload
  ) {
    return ResponseEntity.status(201).body(userProfileService.addAddress(currentUserId(request), payload));
  }

  @GetMapping("/favorites")
  public ResponseEntity<List<FavoriteItemResponse>> listFavorites(HttpServletRequest request) {
    return ResponseEntity.ok(userProfileService.listFavorites(currentUserId(request)));
  }

  @PostMapping("/favorites")
  public ResponseEntity<FavoriteItemResponse> addFavorite(
      HttpServletRequest request,
      @Valid @RequestBody FavoriteItemRequest payload
  ) {
    return ResponseEntity.status(201).body(userProfileService.addFavorite(currentUserId(request), payload));
  }

  @GetMapping("/order-history")
  public ResponseEntity<List<OrderHistoryItemResponse>> listOrderHistory(
      HttpServletRequest request,
      @RequestParam(name = "limit", defaultValue = "20") int limit
  ) {
    return ResponseEntity.ok(userProfileService.listOrderHistory(currentUserId(request), limit));
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
