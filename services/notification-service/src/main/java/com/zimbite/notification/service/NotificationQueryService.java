package com.zimbite.notification.service;

import com.zimbite.notification.model.dto.NotificationItemResponse;
import com.zimbite.notification.model.dto.NotificationPreferencesResponse;
import com.zimbite.notification.model.dto.UpdateNotificationPreferencesRequest;
import com.zimbite.notification.model.entity.NotificationEntity;
import com.zimbite.notification.model.entity.NotificationPreferenceEntity;
import com.zimbite.notification.repository.NotificationPreferenceRepository;
import com.zimbite.notification.repository.NotificationRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationQueryService {

    private final NotificationRepository notificationRepository;
    private final NotificationPreferenceRepository preferenceRepository;

    public NotificationQueryService(NotificationRepository notificationRepository,
                                     NotificationPreferenceRepository preferenceRepository) {
        this.notificationRepository = notificationRepository;
        this.preferenceRepository = preferenceRepository;
    }

    public List<NotificationItemResponse> list(UUID userId, boolean unreadOnly) {
        List<NotificationEntity> notifications = unreadOnly
                ? notificationRepository.findByUserIdAndReadFalseOrderByCreatedAtDesc(userId)
                : notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return notifications.stream().map(this::toResponse).toList();
    }

    @Transactional
    public boolean markRead(UUID userId, UUID notificationId) {
        return notificationRepository.findById(notificationId)
                .filter(n -> n.getUserId().equals(userId))
                .map(n -> {
                    n.setRead(true);
                    notificationRepository.save(n);
                    return true;
                })
                .orElse(false);
    }

    public NotificationPreferencesResponse getPreferences(UUID userId) {
        NotificationPreferenceEntity pref = getOrCreatePreference(userId);
        return new NotificationPreferencesResponse(pref.isPushEnabled(), pref.isSmsEnabled(), pref.isEmailEnabled());
    }

    @Transactional
    public NotificationPreferencesResponse updatePreferences(UUID userId, UpdateNotificationPreferencesRequest request) {
        NotificationPreferenceEntity pref = getOrCreatePreference(userId);
        if (request.pushEnabled() != null) pref.setPushEnabled(request.pushEnabled());
        if (request.smsEnabled() != null) pref.setSmsEnabled(request.smsEnabled());
        if (request.emailEnabled() != null) pref.setEmailEnabled(request.emailEnabled());
        pref.setUpdatedAt(OffsetDateTime.now());
        preferenceRepository.save(pref);
        return new NotificationPreferencesResponse(pref.isPushEnabled(), pref.isSmsEnabled(), pref.isEmailEnabled());
    }

    @Transactional
    public void createNotification(UUID userId, String type, String message) {
        NotificationEntity entity = new NotificationEntity();
        entity.setId(UUID.randomUUID());
        entity.setUserId(userId);
        entity.setType(type);
        entity.setMessage(message);
        entity.setRead(false);
        entity.setCreatedAt(OffsetDateTime.now());
        notificationRepository.save(entity);
    }

    private NotificationPreferenceEntity getOrCreatePreference(UUID userId) {
        return preferenceRepository.findByUserId(userId).orElseGet(() -> {
            NotificationPreferenceEntity pref = new NotificationPreferenceEntity();
            pref.setId(UUID.randomUUID());
            pref.setUserId(userId);
            pref.setPushEnabled(true);
            pref.setSmsEnabled(true);
            pref.setEmailEnabled(false);
            pref.setUpdatedAt(OffsetDateTime.now());
            return preferenceRepository.save(pref);
        });
    }

    private NotificationItemResponse toResponse(NotificationEntity entity) {
        return new NotificationItemResponse(
                entity.getId(), entity.getType(), entity.getMessage(),
                entity.isRead(), entity.getCreatedAt());
    }
}
