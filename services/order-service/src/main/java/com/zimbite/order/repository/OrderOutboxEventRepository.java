package com.zimbite.order.repository;

import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderOutboxEventRepository extends JpaRepository<OrderOutboxEventEntity, UUID> {
}
