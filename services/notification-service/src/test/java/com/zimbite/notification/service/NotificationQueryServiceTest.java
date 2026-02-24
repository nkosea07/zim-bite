package com.zimbite.notification.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.zimbite.notification.model.dto.UpdateNotificationPreferencesRequest;
import com.zimbite.notification.model.entity.NotificationPreferenceEntity;
import com.zimbite.notification.repository.NotificationPreferenceRepository;
import com.zimbite.notification.repository.NotificationRepository;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NotificationQueryServiceTest {

  @Mock
  private NotificationRepository notificationRepository;

  @Mock
  private NotificationPreferenceRepository preferenceRepository;

  private NotificationQueryService service;

  @BeforeEach
  void setUp() {
    service = new NotificationQueryService(notificationRepository, preferenceRepository);
  }

  @Test
  void updatesPreferencesForUser() {
    UUID userId = UUID.randomUUID();
    NotificationPreferenceEntity existing = new NotificationPreferenceEntity();
    existing.setId(UUID.randomUUID());
    existing.setUserId(userId);
    existing.setPushEnabled(false);
    existing.setSmsEnabled(true);
    existing.setEmailEnabled(false);
    existing.setUpdatedAt(OffsetDateTime.now());

    when(preferenceRepository.findByUserId(userId)).thenReturn(Optional.of(existing));
    when(preferenceRepository.save(any(NotificationPreferenceEntity.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    var updated = service.updatePreferences(userId, new UpdateNotificationPreferencesRequest(true, false, true));

    assertTrue(updated.pushEnabled());
    assertFalse(updated.smsEnabled());
    assertTrue(updated.emailEnabled());
  }
}
