package com.zimbite.notification.controller;

import com.zimbite.notification.model.dto.NotificationItemResponse;
import com.zimbite.notification.model.dto.NotificationPreferencesResponse;
import com.zimbite.notification.model.dto.UpdateNotificationPreferencesRequest;
import com.zimbite.notification.service.NotificationQueryService;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

  private final NotificationQueryService notificationQueryService;

  public NotificationController(NotificationQueryService notificationQueryService) {
    this.notificationQueryService = notificationQueryService;
  }

  @GetMapping
  public ResponseEntity<List<NotificationItemResponse>> list(
      HttpServletRequest request,
      @RequestParam(name = "unread_only", defaultValue = "false") boolean unreadOnly
  ) {
    return ResponseEntity.ok(notificationQueryService.list(currentUserId(request), unreadOnly));
  }

  @PostMapping("/{notificationId}/read")
  public ResponseEntity<Map<String, String>> markRead(
      HttpServletRequest request,
      @PathVariable UUID notificationId
  ) {
    boolean found = notificationQueryService.markRead(currentUserId(request), notificationId);
    if (!found) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(Map.of("status", "read"));
  }

  @GetMapping("/preferences")
  public ResponseEntity<NotificationPreferencesResponse> getPreferences(HttpServletRequest request) {
    return ResponseEntity.ok(notificationQueryService.getPreferences(currentUserId(request)));
  }

  @PatchMapping("/preferences")
  public ResponseEntity<NotificationPreferencesResponse> updatePreferences(
      HttpServletRequest request,
      @RequestBody UpdateNotificationPreferencesRequest payload
  ) {
    return ResponseEntity.ok(notificationQueryService.updatePreferences(currentUserId(request), payload));
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
