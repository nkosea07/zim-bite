package com.zimbite.analytics.repository;

import com.zimbite.analytics.model.entity.SucceededPaymentProjectionEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SucceededPaymentProjectionRepository extends JpaRepository<SucceededPaymentProjectionEntity, UUID> {
}
