package com.zimbite.subscription.model.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record SubscriptionResponse(
    UUID id,
    UUID userId,
    UUID vendorId,
    String planType,
    String status,
    UUID deliveryAddressId,
    String currency,
    String presetName,
    String notes,
    OffsetDateTime nextDeliveryAt,
    List<SubscriptionItemResponse> items,
    OffsetDateTime createdAt
) {
  public record SubscriptionItemResponse(UUID menuItemId, int quantity) {}
}
