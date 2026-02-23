package com.zimbite.user.model.dto;

import java.util.UUID;

public record UserProfileResponse(
    UUID id,
    String firstName,
    String lastName,
    String email,
    String phoneNumber
) {
}
