package com.zimbite.delivery.model.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record DeliveryTrackingResponse(
    UUID orderId,
    UUID deliveryId,
    UUID riderId,
    String status,
    BigDecimal lastLatitude,
    BigDecimal lastLongitude,
    OffsetDateTime lastUpdatedAt,
    OffsetDateTime estimatedArrivalAt
) {
}
