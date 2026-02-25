package com.zimbite.vendor.controller;

import com.zimbite.shared.security.UserContext;
import com.zimbite.vendor.model.dto.CreateReviewRequest;
import com.zimbite.vendor.model.dto.ReviewResponse;
import com.zimbite.vendor.service.ReviewService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1")
public class ReviewController {

  private final ReviewService reviewService;

  public ReviewController(ReviewService reviewService) {
    this.reviewService = reviewService;
  }

  @PostMapping("/vendors/{vendorId}/reviews")
  public ResponseEntity<ReviewResponse> createReview(
      HttpServletRequest servletRequest,
      @PathVariable UUID vendorId,
      @Valid @RequestBody CreateReviewRequest request
  ) {
    UUID userId = currentUserId(servletRequest);
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(reviewService.createReview(vendorId, userId, request));
  }

  @GetMapping("/vendors/{vendorId}/reviews")
  public ResponseEntity<List<ReviewResponse>> listByVendor(@PathVariable UUID vendorId) {
    return ResponseEntity.ok(reviewService.listByVendor(vendorId));
  }

  @GetMapping("/users/me/reviews")
  public ResponseEntity<List<ReviewResponse>> listMyReviews(HttpServletRequest servletRequest) {
    return ResponseEntity.ok(reviewService.listByUser(currentUserId(servletRequest)));
  }

  @DeleteMapping("/reviews/{reviewId}")
  public ResponseEntity<Void> deleteReview(
      HttpServletRequest servletRequest,
      @PathVariable UUID reviewId
  ) {
    reviewService.deleteReview(reviewId, currentUserId(servletRequest));
    return ResponseEntity.noContent().build();
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
