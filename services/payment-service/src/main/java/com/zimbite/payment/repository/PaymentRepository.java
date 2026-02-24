package com.zimbite.payment.repository;

import com.zimbite.payment.model.entity.PaymentEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<PaymentEntity, UUID> {
  Optional<PaymentEntity> findByIdempotencyKey(String idempotencyKey);
}
