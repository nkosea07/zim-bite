package com.zimbite.vendor.repository;

import com.zimbite.vendor.model.entity.VendorEntity;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VendorRepository extends JpaRepository<VendorEntity, UUID> {

    Optional<VendorEntity> findBySlug(String slug);

    List<VendorEntity> findByActiveTrue();

    List<VendorEntity> findByOwnerUserId(UUID ownerUserId);
}
