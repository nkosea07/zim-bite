package com.zimbite.order.repository;

import com.zimbite.order.model.entity.OrderEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRepository extends JpaRepository<OrderEntity, UUID> {
  List<OrderEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);

  List<OrderEntity> findAllByOrderByCreatedAtDesc();
}
