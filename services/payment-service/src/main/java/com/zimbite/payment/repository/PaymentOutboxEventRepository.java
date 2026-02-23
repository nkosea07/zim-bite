package com.zimbite.payment.repository;

import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import java.util.UUID;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Pageable;

public interface PaymentOutboxEventRepository extends JpaRepository<PaymentOutboxEventEntity, UUID> {
  List<PaymentOutboxEventEntity> findByPublishedFalseOrderByCreatedAtAsc(Pageable pageable);
}
