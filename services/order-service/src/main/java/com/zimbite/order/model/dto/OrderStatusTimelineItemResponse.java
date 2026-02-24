package com.zimbite.order.model.dto;

import java.time.OffsetDateTime;

public record OrderStatusTimelineItemResponse(
    String status,
    String source,
    String note,
    OffsetDateTime createdAt
) {
}
