package com.zimbite.analytics.repository;

import com.zimbite.analytics.model.entity.OrderProjectionEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderProjectionRepository extends JpaRepository<OrderProjectionEntity, UUID> {
}
