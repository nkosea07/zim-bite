package com.zimbite.shared.messaging;

public final class Topics {
  public static final String ORDER_CREATED = "order.created";
  public static final String ORDER_STATUS_CHANGED = "order.status.changed";
  public static final String PAYMENT_INITIATED = "payment.initiated";
  public static final String PAYMENT_SUCCEEDED = "payment.succeeded";
  public static final String PAYMENT_FAILED = "payment.failed";
  public static final String DELIVERY_ASSIGNED = "delivery.assigned";

  private Topics() {
  }
}
