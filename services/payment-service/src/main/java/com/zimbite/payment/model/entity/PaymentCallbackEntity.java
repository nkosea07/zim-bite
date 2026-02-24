package com.zimbite.payment.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "payment_callbacks", schema = "payment_mgmt")
public class PaymentCallbackEntity {

  @Id
  private UUID id;

  @Column(name = "payment_id", nullable = false)
  private UUID paymentId;

  @Column(nullable = false)
  private String provider;

  @Column(name = "callback_id", nullable = false)
  private String callbackId;

  @Column(nullable = false)
  private String outcome;

  @Column(name = "signature_valid", nullable = false)
  private boolean signatureValid;

  @Column
  private String reason;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public UUID getPaymentId() {
    return paymentId;
  }

  public void setPaymentId(UUID paymentId) {
    this.paymentId = paymentId;
  }

  public String getProvider() {
    return provider;
  }

  public void setProvider(String provider) {
    this.provider = provider;
  }

  public String getCallbackId() {
    return callbackId;
  }

  public void setCallbackId(String callbackId) {
    this.callbackId = callbackId;
  }

  public String getOutcome() {
    return outcome;
  }

  public void setOutcome(String outcome) {
    this.outcome = outcome;
  }

  public boolean isSignatureValid() {
    return signatureValid;
  }

  public void setSignatureValid(boolean signatureValid) {
    this.signatureValid = signatureValid;
  }

  public String getReason() {
    return reason;
  }

  public void setReason(String reason) {
    this.reason = reason;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(OffsetDateTime createdAt) {
    this.createdAt = createdAt;
  }
}
