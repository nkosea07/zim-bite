package com.zimbite.auth.model.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record LoginChallengeResponse(
    UUID challengeId,
    String principal,
    OffsetDateTime expiresAt,
    int attemptsRemaining,
    String status
) {
}
