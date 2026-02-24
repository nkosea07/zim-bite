package com.zimbite.shared.messaging.contract;

import java.time.OffsetDateTime;
import java.util.UUID;

public record DeliveryCompletedEvent(
    UUID deliveryId,
    UUID orderId,
    UUID riderId,
    OffsetDateTime completedAt
) {
}
