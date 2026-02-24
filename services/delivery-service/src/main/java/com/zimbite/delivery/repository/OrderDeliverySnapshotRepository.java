package com.zimbite.delivery.repository;

import com.zimbite.delivery.model.entity.OrderDeliverySnapshotEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderDeliverySnapshotRepository extends JpaRepository<OrderDeliverySnapshotEntity, UUID> {
}
