package com.zimbite.order.repository;

import com.zimbite.order.model.entity.MenuItemPricingEntity;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MenuItemPricingRepository extends JpaRepository<MenuItemPricingEntity, UUID> {
  List<MenuItemPricingEntity> findByIdInAndVendorId(Collection<UUID> ids, UUID vendorId);
}
