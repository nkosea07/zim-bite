package com.zimbite.shared.messaging.contract;

import java.time.OffsetDateTime;
import java.util.UUID;

public record DeliveryAssignedEvent(
    UUID deliveryId,
    UUID orderId,
    UUID riderId,
    OffsetDateTime assignedAt
) {
}
