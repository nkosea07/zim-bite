package com.zimbite.shared.messaging;

public final class Topics {
  public static final String ORDER_CREATED = "order.created";
  public static final String ORDER_STATUS_CHANGED = "order.status.changed";
  public static final String PAYMENT_INITIATED = "payment.initiated";
  public static final String PAYMENT_SUCCEEDED = "payment.succeeded";
  public static final String PAYMENT_FAILED = "payment.failed";
  public static final String PAYMENT_REFUNDED = "payment.refunded";
  public static final String DELIVERY_ASSIGNED = "delivery.assigned";
  public static final String DELIVERY_COMPLETED = "delivery.completed";
  public static final String SUBSCRIPTION_CREATED = "subscription.created";
  public static final String SUBSCRIPTION_PAUSED = "subscription.paused";
  public static final String SUBSCRIPTION_CANCELLED = "subscription.cancelled";
  public static final String SUBSCRIPTION_DELIVERY_DUE = "subscription.delivery.due";

  private Topics() {
  }
}
