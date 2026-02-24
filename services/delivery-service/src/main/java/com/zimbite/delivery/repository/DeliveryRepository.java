package com.zimbite.delivery.repository;

import com.zimbite.delivery.model.entity.DeliveryEntity;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeliveryRepository extends JpaRepository<DeliveryEntity, UUID> {

    Optional<DeliveryEntity> findByOrderId(UUID orderId);

    List<DeliveryEntity> findByStatusInAndAssignedAtAfter(Collection<String> statuses, OffsetDateTime assignedAfter);

    long countByRiderIdAndStatusIn(UUID riderId, Collection<String> statuses);
}
