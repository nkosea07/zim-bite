package com.zimbite.analytics.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_projections", schema = "analytics_mgmt")
public class DeliveryProjectionEntity {

  @Id
  @Column(name = "delivery_id")
  private UUID deliveryId;

  @Column(name = "order_id", nullable = false)
  private UUID orderId;

  @Column(name = "rider_id")
  private UUID riderId;

  @Column(name = "assigned_at")
  private OffsetDateTime assignedAt;

  @Column(name = "completed_at")
  private OffsetDateTime completedAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  public UUID getDeliveryId() {
    return deliveryId;
  }

  public void setDeliveryId(UUID deliveryId) {
    this.deliveryId = deliveryId;
  }

  public UUID getOrderId() {
    return orderId;
  }

  public void setOrderId(UUID orderId) {
    this.orderId = orderId;
  }

  public UUID getRiderId() {
    return riderId;
  }

  public void setRiderId(UUID riderId) {
    this.riderId = riderId;
  }

  public OffsetDateTime getAssignedAt() {
    return assignedAt;
  }

  public void setAssignedAt(OffsetDateTime assignedAt) {
    this.assignedAt = assignedAt;
  }

  public OffsetDateTime getCompletedAt() {
    return completedAt;
  }

  public void setCompletedAt(OffsetDateTime completedAt) {
    this.completedAt = completedAt;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }

  public void setUpdatedAt(OffsetDateTime updatedAt) {
    this.updatedAt = updatedAt;
  }
}
