package com.zimbite.delivery.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ChatMessageResponse(
    UUID id,
    UUID deliveryId,
    UUID senderId,
    String senderRole,
    String body,
    OffsetDateTime sentAt
) {}
