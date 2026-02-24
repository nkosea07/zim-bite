package com.zimbite.delivery.repository;

import com.zimbite.delivery.model.entity.DeliveryLocationEntity;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeliveryLocationRepository extends JpaRepository<DeliveryLocationEntity, UUID> {

    Optional<DeliveryLocationEntity> findFirstByDeliveryIdOrderByRecordedAtDesc(UUID deliveryId);

    List<DeliveryLocationEntity> findTop5ByDeliveryIdOrderByRecordedAtDesc(UUID deliveryId);
}
