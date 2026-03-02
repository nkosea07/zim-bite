package com.zimbite.delivery.model.dto;

import java.util.UUID;

public record ChatSendRequest(UUID deliveryId, UUID senderId, String senderRole, String body) {}
