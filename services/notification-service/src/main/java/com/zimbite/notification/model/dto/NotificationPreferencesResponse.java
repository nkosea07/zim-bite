package com.zimbite.notification.model.dto;

public record NotificationPreferencesResponse(
    boolean pushEnabled,
    boolean smsEnabled,
    boolean emailEnabled
) {
}
