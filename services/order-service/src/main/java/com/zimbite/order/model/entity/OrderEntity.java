package com.zimbite.order.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "orders", schema = "ordering")
public class OrderEntity {

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(name = "vendor_id", nullable = false)
  private UUID vendorId;

  @Column(name = "delivery_address_id")
  private UUID deliveryAddressId;

  @Column(nullable = false)
  private String status;

  @Column(name = "total_amount", nullable = false)
  private BigDecimal totalAmount;

  @Column(nullable = false)
  private String currency;

  @Column(name = "pickup_lat")
  private BigDecimal pickupLat;

  @Column(name = "pickup_lng")
  private BigDecimal pickupLng;

  @Column(name = "dropoff_lat")
  private BigDecimal dropoffLat;

  @Column(name = "dropoff_lng")
  private BigDecimal dropoffLng;

  @Column(name = "scheduled_for")
  private OffsetDateTime scheduledFor;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

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

  public UUID getVendorId() {
    return vendorId;
  }

  public void setVendorId(UUID vendorId) {
    this.vendorId = vendorId;
  }

  public UUID getDeliveryAddressId() {
    return deliveryAddressId;
  }

  public void setDeliveryAddressId(UUID deliveryAddressId) {
    this.deliveryAddressId = deliveryAddressId;
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

  public BigDecimal getPickupLat() {
    return pickupLat;
  }

  public void setPickupLat(BigDecimal pickupLat) {
    this.pickupLat = pickupLat;
  }

  public BigDecimal getPickupLng() {
    return pickupLng;
  }

  public void setPickupLng(BigDecimal pickupLng) {
    this.pickupLng = pickupLng;
  }

  public BigDecimal getDropoffLat() {
    return dropoffLat;
  }

  public void setDropoffLat(BigDecimal dropoffLat) {
    this.dropoffLat = dropoffLat;
  }

  public BigDecimal getDropoffLng() {
    return dropoffLng;
  }

  public void setDropoffLng(BigDecimal dropoffLng) {
    this.dropoffLng = dropoffLng;
  }

  public OffsetDateTime getScheduledFor() {
    return scheduledFor;
  }

  public void setScheduledFor(OffsetDateTime scheduledFor) {
    this.scheduledFor = scheduledFor;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(OffsetDateTime createdAt) {
    this.createdAt = createdAt;
  }
}
