package com.zimbite.order.repository;

import com.zimbite.order.model.entity.InventoryEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface InventoryRepository extends JpaRepository<InventoryEntity, UUID> {

  Optional<InventoryEntity> findByVendorIdAndMenuItemId(UUID vendorId, UUID menuItemId);

  @Modifying
  @Query(
      value = """
          UPDATE menu_mgmt.inventory
          SET quantity_available = quantity_available - :quantity,
              updated_at = NOW()
          WHERE vendor_id = :vendorId
            AND menu_item_id = :menuItemId
            AND quantity_available >= :quantity
          """,
      nativeQuery = true
  )
  int reserve(
      @Param("vendorId") UUID vendorId,
      @Param("menuItemId") UUID menuItemId,
      @Param("quantity") int quantity
  );

  @Modifying
  @Query(
      value = """
          UPDATE menu_mgmt.inventory
          SET quantity_available = quantity_available + :quantity,
              updated_at = NOW()
          WHERE vendor_id = :vendorId
            AND menu_item_id = :menuItemId
          """,
      nativeQuery = true
  )
  int release(
      @Param("vendorId") UUID vendorId,
      @Param("menuItemId") UUID menuItemId,
      @Param("quantity") int quantity
  );
}
