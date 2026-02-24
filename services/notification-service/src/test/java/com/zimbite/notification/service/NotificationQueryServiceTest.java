package com.zimbite.notification.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.zimbite.notification.model.dto.UpdateNotificationPreferencesRequest;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class NotificationQueryServiceTest {

  @Test
  void updatesPreferencesForUser() {
    NotificationQueryService service = new NotificationQueryService();
    UUID userId = UUID.randomUUID();

    var updated = service.updatePreferences(userId, new UpdateNotificationPreferencesRequest(true, false, true));

    assertTrue(updated.pushEnabled());
    assertFalse(updated.smsEnabled());
    assertTrue(updated.emailEnabled());
  }
}
