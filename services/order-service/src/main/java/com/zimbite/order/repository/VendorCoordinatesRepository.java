package com.zimbite.order.repository;

import com.zimbite.order.model.entity.VendorCoordinatesEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VendorCoordinatesRepository extends JpaRepository<VendorCoordinatesEntity, UUID> {
}
