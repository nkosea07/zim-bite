package com.zimbite.notification.model.dto;

public record UpdateNotificationPreferencesRequest(
    Boolean pushEnabled,
    Boolean smsEnabled,
    Boolean emailEnabled
) {
}
