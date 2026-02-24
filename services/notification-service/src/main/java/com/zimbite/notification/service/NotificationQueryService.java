package com.zimbite.notification.service;

import com.zimbite.notification.model.dto.NotificationItemResponse;
import com.zimbite.notification.model.dto.NotificationPreferencesResponse;
import com.zimbite.notification.model.dto.UpdateNotificationPreferencesRequest;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class NotificationQueryService {

  private final Map<UUID, List<NotificationRecord>> notificationsByUser = new ConcurrentHashMap<>();
  private final Map<UUID, PreferenceRecord> preferencesByUser = new ConcurrentHashMap<>();

  public List<NotificationItemResponse> list(UUID userId, boolean unreadOnly) {
    ensureSeedData(userId);
    return notificationsByUser.getOrDefault(userId, List.of()).stream()
        .filter(n -> !unreadOnly || !n.read())
        .map(this::toResponse)
        .toList();
  }

  public boolean markRead(UUID userId, UUID notificationId) {
    ensureSeedData(userId);
    List<NotificationRecord> notifications = notificationsByUser.getOrDefault(userId, List.of());
    for (int i = 0; i < notifications.size(); i++) {
      NotificationRecord current = notifications.get(i);
      if (current.notificationId().equals(notificationId)) {
        notifications.set(i, current.withRead(true));
        return true;
      }
    }
    return false;
  }

  public NotificationPreferencesResponse getPreferences(UUID userId) {
    PreferenceRecord current = preferencesByUser.computeIfAbsent(userId, ignored -> new PreferenceRecord(true, true, false));
    return new NotificationPreferencesResponse(current.pushEnabled(), current.smsEnabled(), current.emailEnabled());
  }

  public NotificationPreferencesResponse updatePreferences(UUID userId, UpdateNotificationPreferencesRequest request) {
    PreferenceRecord current = preferencesByUser.computeIfAbsent(userId, ignored -> new PreferenceRecord(true, true, false));
    PreferenceRecord updated = new PreferenceRecord(
        request.pushEnabled() == null ? current.pushEnabled() : request.pushEnabled(),
        request.smsEnabled() == null ? current.smsEnabled() : request.smsEnabled(),
        request.emailEnabled() == null ? current.emailEnabled() : request.emailEnabled()
    );
    preferencesByUser.put(userId, updated);
    return new NotificationPreferencesResponse(updated.pushEnabled(), updated.smsEnabled(), updated.emailEnabled());
  }

  private void ensureSeedData(UUID userId) {
    notificationsByUser.computeIfAbsent(userId, ignored -> {
      List<NotificationRecord> seed = new ArrayList<>();
      seed.add(new NotificationRecord(
          UUID.randomUUID(),
          "ORDER_STATUS_CHANGED",
          "Your order is being prepared.",
          false,
          OffsetDateTime.now().minusMinutes(20)
      ));
      seed.add(new NotificationRecord(
          UUID.randomUUID(),
          "DELIVERY_ASSIGNED",
          "A rider has been assigned to your delivery.",
          false,
          OffsetDateTime.now().minusMinutes(10)
      ));
      return seed;
    });
  }

  private NotificationItemResponse toResponse(NotificationRecord record) {
    return new NotificationItemResponse(
        record.notificationId(),
        record.type(),
        record.message(),
        record.read(),
        record.createdAt()
    );
  }

  private record NotificationRecord(
      UUID notificationId,
      String type,
      String message,
      boolean read,
      OffsetDateTime createdAt
  ) {
    private NotificationRecord withRead(boolean value) {
      return new NotificationRecord(notificationId, type, message, value, createdAt);
    }
  }

  private record PreferenceRecord(
      boolean pushEnabled,
      boolean smsEnabled,
      boolean emailEnabled
  ) {
  }
}
