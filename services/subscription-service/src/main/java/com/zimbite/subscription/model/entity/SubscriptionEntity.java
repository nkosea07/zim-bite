package com.zimbite.subscription.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "subscriptions", schema = "subscription_mgmt")
public class SubscriptionEntity {

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "vendor_id", nullable = false)
  private UUID vendorId;

  @Column(name = "plan_type", nullable = false, length = 20)
  private String planType;

  @Column(nullable = false, length = 20)
  private String status;

  @Column(name = "delivery_address_id", nullable = false)
  private UUID deliveryAddressId;

  @Column(nullable = false, length = 3)
  private String currency;

  @Column(name = "preset_name", length = 120)
  private String presetName;

  @Column
  private String notes;

  @Column(name = "next_delivery_at", nullable = false)
  private OffsetDateTime nextDeliveryAt;

  @Column(name = "paused_at")
  private OffsetDateTime pausedAt;

  @Column(name = "cancelled_at")
  private OffsetDateTime cancelledAt;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }

  public UUID getUserId() { return userId; }
  public void setUserId(UUID userId) { this.userId = userId; }

  public UUID getVendorId() { return vendorId; }
  public void setVendorId(UUID vendorId) { this.vendorId = vendorId; }

  public String getPlanType() { return planType; }
  public void setPlanType(String planType) { this.planType = planType; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }

  public UUID getDeliveryAddressId() { return deliveryAddressId; }
  public void setDeliveryAddressId(UUID deliveryAddressId) { this.deliveryAddressId = deliveryAddressId; }

  public String getCurrency() { return currency; }
  public void setCurrency(String currency) { this.currency = currency; }

  public String getPresetName() { return presetName; }
  public void setPresetName(String presetName) { this.presetName = presetName; }

  public String getNotes() { return notes; }
  public void setNotes(String notes) { this.notes = notes; }

  public OffsetDateTime getNextDeliveryAt() { return nextDeliveryAt; }
  public void setNextDeliveryAt(OffsetDateTime nextDeliveryAt) { this.nextDeliveryAt = nextDeliveryAt; }

  public OffsetDateTime getPausedAt() { return pausedAt; }
  public void setPausedAt(OffsetDateTime pausedAt) { this.pausedAt = pausedAt; }

  public OffsetDateTime getCancelledAt() { return cancelledAt; }
  public void setCancelledAt(OffsetDateTime cancelledAt) { this.cancelledAt = cancelledAt; }

  public OffsetDateTime getCreatedAt() { return createdAt; }
  public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

  public OffsetDateTime getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
}
