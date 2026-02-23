package com.zimbite.menu.repository;

import com.zimbite.menu.model.entity.MenuItemEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MenuItemRepository extends JpaRepository<MenuItemEntity, UUID> {
  List<MenuItemEntity> findByVendorId(UUID vendorId);
}
