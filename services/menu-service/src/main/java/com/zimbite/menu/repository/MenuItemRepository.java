package com.zimbite.menu.repository;

import com.zimbite.menu.model.entity.MenuItemEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MenuItemRepository extends JpaRepository<MenuItemEntity, UUID> {
  List<MenuItemEntity> findByVendorId(UUID vendorId);

  @Query("""
      select distinct i.category
      from MenuItemEntity i
      where i.vendorId = :vendorId
      order by i.category asc
      """)
  List<String> findDistinctCategoriesByVendorId(UUID vendorId);
}
