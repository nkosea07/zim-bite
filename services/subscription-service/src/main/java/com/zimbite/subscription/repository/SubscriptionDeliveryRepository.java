package com.zimbite.subscription.repository;

import com.zimbite.subscription.model.entity.SubscriptionDeliveryEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubscriptionDeliveryRepository extends JpaRepository<SubscriptionDeliveryEntity, UUID> {
  List<SubscriptionDeliveryEntity> findBySubscriptionIdOrderByScheduledForDesc(UUID subscriptionId);
}
