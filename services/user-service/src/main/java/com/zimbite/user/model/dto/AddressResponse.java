package com.zimbite.user.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record AddressResponse(
    UUID id,
    String label,
    String line1,
    String line2,
    String city,
    String area,
    Double latitude,
    Double longitude,
    OffsetDateTime createdAt
) {
}
