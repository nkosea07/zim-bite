package com.zimbite.order.model.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record OrderStatusResponse(
    UUID orderId,
    String status,
    OffsetDateTime lastTransitionAt,
    List<OrderStatusTimelineItemResponse> timeline
) {
}
