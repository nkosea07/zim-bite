package com.zimbite.user.model.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record FavoriteItemRequest(
    @NotNull UUID menuItemId
) {
}
