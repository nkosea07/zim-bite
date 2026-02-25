package com.zimbite.subscription.repository;

import com.zimbite.subscription.model.entity.SubscriptionItemEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubscriptionItemRepository extends JpaRepository<SubscriptionItemEntity, UUID> {
  List<SubscriptionItemEntity> findBySubscriptionId(UUID subscriptionId);
  void deleteBySubscriptionId(UUID subscriptionId);
}
