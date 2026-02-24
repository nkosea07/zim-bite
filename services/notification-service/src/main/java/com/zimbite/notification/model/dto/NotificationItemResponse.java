package com.zimbite.notification.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record NotificationItemResponse(
    UUID notificationId,
    String type,
    String message,
    boolean read,
    OffsetDateTime createdAt
) {
}
