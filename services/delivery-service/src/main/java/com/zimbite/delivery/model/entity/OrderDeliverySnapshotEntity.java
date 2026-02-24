package com.zimbite.delivery.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "orders", schema = "ordering")
public class OrderDeliverySnapshotEntity {

  @Id
  private UUID id;

  @Column(name = "pickup_lat")
  private BigDecimal pickupLat;

  @Column(name = "pickup_lng")
  private BigDecimal pickupLng;

  @Column(name = "dropoff_lat")
  private BigDecimal dropoffLat;

  @Column(name = "dropoff_lng")
  private BigDecimal dropoffLng;

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
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
}
