package com.zimbite.subscription.controller;

import com.zimbite.shared.security.UserContext;
import com.zimbite.subscription.model.dto.CreateSubscriptionRequest;
import com.zimbite.subscription.model.dto.SubscriptionDeliveryResponse;
import com.zimbite.subscription.model.dto.SubscriptionResponse;
import com.zimbite.subscription.service.SubscriptionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/subscriptions")
public class SubscriptionController {

  private final SubscriptionService subscriptionService;

  public SubscriptionController(SubscriptionService subscriptionService) {
    this.subscriptionService = subscriptionService;
  }

  @PostMapping
  public ResponseEntity<SubscriptionResponse> createSubscription(
      HttpServletRequest servletRequest,
      @Valid @RequestBody CreateSubscriptionRequest request
  ) {
    UUID userId = currentUserId(servletRequest);
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(subscriptionService.createSubscription(userId, request));
  }

  @GetMapping
  public ResponseEntity<List<SubscriptionResponse>> listSubscriptions(HttpServletRequest servletRequest) {
    return ResponseEntity.ok(subscriptionService.listSubscriptions(currentUserId(servletRequest)));
  }

  @GetMapping("/{subscriptionId}")
  public ResponseEntity<SubscriptionResponse> getSubscription(
      HttpServletRequest servletRequest,
      @PathVariable UUID subscriptionId
  ) {
    return ResponseEntity.ok(subscriptionService.getSubscription(subscriptionId, currentUserId(servletRequest)));
  }

  @PostMapping("/{subscriptionId}/pause")
  public ResponseEntity<SubscriptionResponse> pauseSubscription(
      HttpServletRequest servletRequest,
      @PathVariable UUID subscriptionId
  ) {
    return ResponseEntity.ok(subscriptionService.pauseSubscription(subscriptionId, currentUserId(servletRequest)));
  }

  @PostMapping("/{subscriptionId}/resume")
  public ResponseEntity<SubscriptionResponse> resumeSubscription(
      HttpServletRequest servletRequest,
      @PathVariable UUID subscriptionId
  ) {
    return ResponseEntity.ok(subscriptionService.resumeSubscription(subscriptionId, currentUserId(servletRequest)));
  }

  @PostMapping("/{subscriptionId}/cancel")
  public ResponseEntity<SubscriptionResponse> cancelSubscription(
      HttpServletRequest servletRequest,
      @PathVariable UUID subscriptionId
  ) {
    return ResponseEntity.ok(subscriptionService.cancelSubscription(subscriptionId, currentUserId(servletRequest)));
  }

  @GetMapping("/{subscriptionId}/deliveries")
  public ResponseEntity<List<SubscriptionDeliveryResponse>> listDeliveries(
      HttpServletRequest servletRequest,
      @PathVariable UUID subscriptionId
  ) {
    return ResponseEntity.ok(subscriptionService.listDeliveries(subscriptionId, currentUserId(servletRequest)));
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
