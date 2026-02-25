package com.zimbite.subscription.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "subscription_deliveries", schema = "subscription_mgmt")
public class SubscriptionDeliveryEntity {

  @Id
  private UUID id;

  @Column(name = "subscription_id", nullable = false)
  private UUID subscriptionId;

  @Column(name = "order_id")
  private UUID orderId;

  @Column(name = "scheduled_for", nullable = false)
  private OffsetDateTime scheduledFor;

  @Column(nullable = false, length = 20)
  private String status;

  @Column(name = "failure_reason")
  private String failureReason;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  public UUID getId() { return id; }
  public void setId(UUID id) { this.id = id; }

  public UUID getSubscriptionId() { return subscriptionId; }
  public void setSubscriptionId(UUID subscriptionId) { this.subscriptionId = subscriptionId; }

  public UUID getOrderId() { return orderId; }
  public void setOrderId(UUID orderId) { this.orderId = orderId; }

  public OffsetDateTime getScheduledFor() { return scheduledFor; }
  public void setScheduledFor(OffsetDateTime scheduledFor) { this.scheduledFor = scheduledFor; }

  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }

  public String getFailureReason() { return failureReason; }
  public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

  public OffsetDateTime getCreatedAt() { return createdAt; }
  public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
