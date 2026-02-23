package com.zimbite.shared.messaging.contract;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderStatusChangedEvent(
    UUID orderId,
    UUID userId,
    String previousStatus,
    String newStatus,
    OffsetDateTime changedAt
) {
}
