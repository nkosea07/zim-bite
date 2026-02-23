package com.zimbite.order.repository;

import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import java.util.UUID;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Pageable;

public interface OrderOutboxEventRepository extends JpaRepository<OrderOutboxEventEntity, UUID> {
  List<OrderOutboxEventEntity> findByPublishedFalseOrderByCreatedAtAsc(Pageable pageable);
}
