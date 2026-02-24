package com.zimbite.analytics.repository;

import com.zimbite.analytics.model.entity.DeliveryProjectionEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeliveryProjectionRepository extends JpaRepository<DeliveryProjectionEntity, UUID> {
}
