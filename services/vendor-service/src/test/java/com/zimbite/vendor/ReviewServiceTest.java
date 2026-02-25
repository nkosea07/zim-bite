package com.zimbite.vendor;

import com.zimbite.vendor.model.dto.CreateReviewRequest;
import com.zimbite.vendor.model.dto.ReviewResponse;
import com.zimbite.vendor.model.entity.ReviewEntity;
import com.zimbite.vendor.model.entity.VendorEntity;
import com.zimbite.vendor.repository.ReviewRepository;
import com.zimbite.vendor.repository.VendorRepository;
import com.zimbite.vendor.service.ReviewService;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ReviewServiceTest {

  @Mock ReviewRepository reviewRepository;
  @Mock VendorRepository vendorRepository;

  private ReviewService service;

  @BeforeEach
  void setUp() {
    service = new ReviewService(reviewRepository, vendorRepository);
  }

  @Test
  void createReview_persistsAndReturnsResponse() {
    UUID vendorId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    UUID orderId = UUID.randomUUID();

    when(vendorRepository.findById(vendorId)).thenReturn(Optional.of(stubVendor(vendorId)));
    when(reviewRepository.findByOrderIdAndUserId(orderId, userId)).thenReturn(Optional.empty());
    when(reviewRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    when(reviewRepository.computeAverageRating(vendorId)).thenReturn(4.5);
    when(vendorRepository.findById(vendorId)).thenReturn(Optional.of(stubVendor(vendorId)));

    CreateReviewRequest request = new CreateReviewRequest(orderId, 5, "Great breakfast!");
    ReviewResponse response = service.createReview(vendorId, userId, request);

    assertThat(response.rating()).isEqualTo(5);
    assertThat(response.comment()).isEqualTo("Great breakfast!");
    assertThat(response.vendorId()).isEqualTo(vendorId);
    assertThat(response.userId()).isEqualTo(userId);
  }

  @Test
  void createReview_rejectsVendorNotFound() {
    UUID vendorId = UUID.randomUUID();
    when(vendorRepository.findById(vendorId)).thenReturn(Optional.empty());

    assertThatThrownBy(() -> service.createReview(vendorId, UUID.randomUUID(),
        new CreateReviewRequest(UUID.randomUUID(), 4, null)))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("Vendor not found");
  }

  @Test
  void createReview_rejectsDuplicateOrderReview() {
    UUID vendorId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    UUID orderId = UUID.randomUUID();

    when(vendorRepository.findById(vendorId)).thenReturn(Optional.of(stubVendor(vendorId)));
    when(reviewRepository.findByOrderIdAndUserId(orderId, userId))
        .thenReturn(Optional.of(new ReviewEntity()));

    assertThatThrownBy(() -> service.createReview(vendorId, userId,
        new CreateReviewRequest(orderId, 3, null)))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("already reviewed");
  }

  @Test
  void deleteReview_forbidsNonOwner() {
    UUID reviewId = UUID.randomUUID();
    UUID ownerId = UUID.randomUUID();

    ReviewEntity review = new ReviewEntity();
    review.setId(reviewId);
    review.setUserId(ownerId);
    review.setVendorId(UUID.randomUUID());

    when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review));

    assertThatThrownBy(() -> service.deleteReview(reviewId, UUID.randomUUID()))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("Access denied");
  }

  @Test
  void deleteReview_updatesVendorRatingAfterDeletion() {
    UUID reviewId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    UUID vendorId = UUID.randomUUID();

    ReviewEntity review = new ReviewEntity();
    review.setId(reviewId);
    review.setUserId(userId);
    review.setVendorId(vendorId);

    when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review));
    when(reviewRepository.computeAverageRating(vendorId)).thenReturn(3.0);
    when(vendorRepository.findById(vendorId)).thenReturn(Optional.of(stubVendor(vendorId)));

    service.deleteReview(reviewId, userId);

    ArgumentCaptor<VendorEntity> captor = ArgumentCaptor.forClass(VendorEntity.class);
    verify(vendorRepository).save(captor.capture());
    assertThat(captor.getValue().getRatingAvg()).isEqualByComparingTo("3.00");
  }

  @Test
  void listByVendor_returnsReviewsInOrder() {
    UUID vendorId = UUID.randomUUID();
    ReviewEntity r1 = reviewEntity(vendorId, 5);
    ReviewEntity r2 = reviewEntity(vendorId, 3);
    when(reviewRepository.findByVendorIdOrderByCreatedAtDesc(vendorId)).thenReturn(List.of(r1, r2));

    List<ReviewResponse> results = service.listByVendor(vendorId);
    assertThat(results).hasSize(2);
    assertThat(results.get(0).rating()).isEqualTo(5);
  }

  private VendorEntity stubVendor(UUID id) {
    VendorEntity v = new VendorEntity();
    v.setId(id);
    v.setRatingAvg(BigDecimal.ZERO);
    v.setUpdatedAt(OffsetDateTime.now());
    return v;
  }

  private ReviewEntity reviewEntity(UUID vendorId, int rating) {
    ReviewEntity r = new ReviewEntity();
    r.setId(UUID.randomUUID());
    r.setVendorId(vendorId);
    r.setUserId(UUID.randomUUID());
    r.setOrderId(UUID.randomUUID());
    r.setRating((short) rating);
    r.setCreatedAt(OffsetDateTime.now());
    r.setUpdatedAt(OffsetDateTime.now());
    return r;
  }
}
