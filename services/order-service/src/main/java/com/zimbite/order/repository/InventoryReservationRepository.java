package com.zimbite.order.repository;

import com.zimbite.order.model.entity.InventoryReservationEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryReservationRepository extends JpaRepository<InventoryReservationEntity, UUID> {
  List<InventoryReservationEntity> findByOrderIdAndStatus(UUID orderId, String status);
}
