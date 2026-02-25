package com.zimbite.subscription.repository;

import com.zimbite.subscription.model.entity.SubscriptionEntity;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubscriptionRepository extends JpaRepository<SubscriptionEntity, UUID> {
  List<SubscriptionEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);
  List<SubscriptionEntity> findByStatusAndNextDeliveryAtBefore(String status, OffsetDateTime threshold);
}
