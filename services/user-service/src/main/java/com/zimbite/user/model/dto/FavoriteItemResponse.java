package com.zimbite.user.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record FavoriteItemResponse(
    UUID menuItemId,
    OffsetDateTime addedAt
) {
}
