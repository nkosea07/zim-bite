package com.zimbite.vendor.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ReviewResponse(
    UUID id,
    UUID vendorId,
    UUID userId,
    UUID orderId,
    int rating,
    String comment,
    OffsetDateTime createdAt
) {}
