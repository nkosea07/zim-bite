package com.zimbite.subscription.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record SubscriptionDeliveryResponse(
    UUID id,
    UUID subscriptionId,
    UUID orderId,
    OffsetDateTime scheduledFor,
    String status,
    String failureReason,
    OffsetDateTime createdAt
) {}
