package com.zimbite.user.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_order_history", schema = "user_mgmt")
public class UserOrderHistoryEntity {

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "order_id", nullable = false)
  private UUID orderId;

  @Column(name = "vendor_id", nullable = false)
  private UUID vendorId;

  @Column(nullable = false)
  private String status;

  @Column(name = "total_amount", nullable = false)
  private BigDecimal totalAmount;

  @Column(nullable = false)
  private String currency;

  @Column(name = "placed_at", nullable = false)
  private OffsetDateTime placedAt;

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public UUID getUserId() {
    return userId;
  }

  public void setUserId(UUID userId) {
    this.userId = userId;
  }

  public UUID getOrderId() {
    return orderId;
  }

  public void setOrderId(UUID orderId) {
    this.orderId = orderId;
  }

  public UUID getVendorId() {
    return vendorId;
  }

  public void setVendorId(UUID vendorId) {
    this.vendorId = vendorId;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public BigDecimal getTotalAmount() {
    return totalAmount;
  }

  public void setTotalAmount(BigDecimal totalAmount) {
    this.totalAmount = totalAmount;
  }

  public String getCurrency() {
    return currency;
  }

  public void setCurrency(String currency) {
    this.currency = currency;
  }

  public OffsetDateTime getPlacedAt() {
    return placedAt;
  }

  public void setPlacedAt(OffsetDateTime placedAt) {
    this.placedAt = placedAt;
  }
}
