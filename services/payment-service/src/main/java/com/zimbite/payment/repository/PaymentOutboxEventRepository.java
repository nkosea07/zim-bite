package com.zimbite.payment.repository;

import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentOutboxEventRepository extends JpaRepository<PaymentOutboxEventEntity, UUID> {
}
