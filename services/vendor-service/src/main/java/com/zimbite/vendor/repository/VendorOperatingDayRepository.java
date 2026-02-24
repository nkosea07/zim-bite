package com.zimbite.vendor.repository;

import com.zimbite.vendor.model.entity.VendorOperatingDayEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VendorOperatingDayRepository extends JpaRepository<VendorOperatingDayEntity, UUID> {

    List<VendorOperatingDayEntity> findByVendorId(UUID vendorId);
}
