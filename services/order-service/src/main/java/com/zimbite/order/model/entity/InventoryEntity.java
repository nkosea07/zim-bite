package com.zimbite.order.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "inventory", schema = "menu_mgmt")
public class InventoryEntity {

  @Id
  private UUID id;

  @Column(name = "vendor_id", nullable = false)
  private UUID vendorId;

  @Column(name = "menu_item_id", nullable = false)
  private UUID menuItemId;

  @Column(name = "quantity_available", nullable = false)
  private int quantityAvailable;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public UUID getVendorId() {
    return vendorId;
  }

  public void setVendorId(UUID vendorId) {
    this.vendorId = vendorId;
  }

  public UUID getMenuItemId() {
    return menuItemId;
  }

  public void setMenuItemId(UUID menuItemId) {
    this.menuItemId = menuItemId;
  }

  public int getQuantityAvailable() {
    return quantityAvailable;
  }

  public void setQuantityAvailable(int quantityAvailable) {
    this.quantityAvailable = quantityAvailable;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(OffsetDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }
}
