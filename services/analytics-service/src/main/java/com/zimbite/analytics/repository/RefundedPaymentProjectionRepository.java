package com.zimbite.analytics.repository;

import com.zimbite.analytics.model.entity.RefundedPaymentProjectionEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefundedPaymentProjectionRepository extends JpaRepository<RefundedPaymentProjectionEntity, UUID> {
}
