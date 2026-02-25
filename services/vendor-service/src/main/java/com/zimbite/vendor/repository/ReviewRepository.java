package com.zimbite.vendor.repository;

import com.zimbite.vendor.model.entity.ReviewEntity;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ReviewRepository extends JpaRepository<ReviewEntity, UUID> {
  List<ReviewEntity> findByVendorIdOrderByCreatedAtDesc(UUID vendorId);
  List<ReviewEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);
  Optional<ReviewEntity> findByOrderIdAndUserId(UUID orderId, UUID userId);

  @Query("SELECT COALESCE(AVG(r.rating), 0) FROM ReviewEntity r WHERE r.vendorId = :vendorId")
  double computeAverageRating(UUID vendorId);
}
