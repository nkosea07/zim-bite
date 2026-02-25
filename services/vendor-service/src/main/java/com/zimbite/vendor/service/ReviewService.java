package com.zimbite.vendor.service;

import com.zimbite.vendor.model.dto.CreateReviewRequest;
import com.zimbite.vendor.model.dto.ReviewResponse;
import com.zimbite.vendor.model.entity.ReviewEntity;
import com.zimbite.vendor.repository.ReviewRepository;
import com.zimbite.vendor.repository.VendorRepository;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ReviewService {

  private final ReviewRepository reviewRepository;
  private final VendorRepository vendorRepository;

  public ReviewService(ReviewRepository reviewRepository, VendorRepository vendorRepository) {
    this.reviewRepository = reviewRepository;
    this.vendorRepository = vendorRepository;
  }

  @Transactional
  public ReviewResponse createReview(UUID vendorId, UUID userId, CreateReviewRequest request) {
    vendorRepository.findById(Objects.requireNonNull(vendorId))
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vendor not found"));

    if (reviewRepository.findByOrderIdAndUserId(request.orderId(), userId).isPresent()) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "You have already reviewed this order");
    }

    OffsetDateTime now = OffsetDateTime.now();
    ReviewEntity review = new ReviewEntity();
    review.setId(UUID.randomUUID());
    review.setVendorId(vendorId);
    review.setUserId(userId);
    review.setOrderId(request.orderId());
    review.setRating((short) request.rating().intValue());
    review.setComment(request.comment());
    review.setCreatedAt(now);
    review.setUpdatedAt(now);
    reviewRepository.save(review);

    recalculateVendorRating(vendorId);

    return toResponse(review);
  }

  public List<ReviewResponse> listByVendor(UUID vendorId) {
    return reviewRepository.findByVendorIdOrderByCreatedAtDesc(vendorId)
        .stream().map(this::toResponse).toList();
  }

  public List<ReviewResponse> listByUser(UUID userId) {
    return reviewRepository.findByUserIdOrderByCreatedAtDesc(userId)
        .stream().map(this::toResponse).toList();
  }

  @Transactional
  public void deleteReview(UUID reviewId, UUID userId) {
    ReviewEntity review = reviewRepository.findById(Objects.requireNonNull(reviewId))
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));
    if (!review.getUserId().equals(userId)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
    }
    UUID vendorId = review.getVendorId();
    reviewRepository.delete(review);
    recalculateVendorRating(vendorId);
  }

  private void recalculateVendorRating(UUID vendorId) {
    double avg = reviewRepository.computeAverageRating(Objects.requireNonNull(vendorId));
    vendorRepository.findById(Objects.requireNonNull(vendorId)).ifPresent(vendor -> {
      vendor.setRatingAvg(BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP));
      vendor.setUpdatedAt(OffsetDateTime.now());
      vendorRepository.save(vendor);
    });
  }

  private ReviewResponse toResponse(ReviewEntity r) {
    return new ReviewResponse(r.getId(), r.getVendorId(), r.getUserId(),
        r.getOrderId(), r.getRating(), r.getComment(), r.getCreatedAt());
  }
}
