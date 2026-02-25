package com.zimbite.subscription.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "subscription_items", schema = "subscription_mgmt")
public class SubscriptionItemEntity {

  @Id
  private UUID id;

  @Column(name = "subscription_id", nullable = false)
  private UUID subscriptionId;

  @Column(name = "menu_item_id", nullable = false)
  private UUID menuItemId;

  @Column(nullable = false)
  private short quantity;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }

  public UUID getSubscriptionId() { return subscriptionId; }
  public void setSubscriptionId(UUID subscriptionId) { this.subscriptionId = subscriptionId; }

  public UUID getMenuItemId() { return menuItemId; }
  public void setMenuItemId(UUID menuItemId) { this.menuItemId = menuItemId; }

  public short getQuantity() { return quantity; }
  public void setQuantity(short quantity) { this.quantity = quantity; }

  public OffsetDateTime getCreatedAt() { return createdAt; }
  public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
