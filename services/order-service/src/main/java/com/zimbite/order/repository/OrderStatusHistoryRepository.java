package com.zimbite.order.repository;

import com.zimbite.order.model.entity.OrderStatusHistoryEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderStatusHistoryRepository extends JpaRepository<OrderStatusHistoryEntity, UUID> {
  List<OrderStatusHistoryEntity> findByOrderIdOrderByCreatedAtDesc(UUID orderId);
}
