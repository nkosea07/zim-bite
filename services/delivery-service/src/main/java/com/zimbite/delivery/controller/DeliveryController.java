package com.zimbite.delivery.controller;

import com.zimbite.delivery.model.dto.AcceptDeliveryRequest;
import com.zimbite.delivery.model.dto.ChatMessageResponse;
import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.dto.RiderDeliveryResponse;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.dto.UpdateDeliveryStatusRequest;
import com.zimbite.delivery.model.entity.ChatMessageEntity;
import com.zimbite.delivery.repository.ChatMessageRepository;
import com.zimbite.delivery.service.DeliveryService;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
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
@RequestMapping("/api/v1/deliveries")
public class DeliveryController {

    private final DeliveryService deliveryService;
    private final ChatMessageRepository chatMessageRepository;

    public DeliveryController(DeliveryService deliveryService, ChatMessageRepository chatMessageRepository) {
        this.deliveryService = deliveryService;
        this.chatMessageRepository = chatMessageRepository;
    }

    @PatchMapping("/{deliveryId}/status")
    public ResponseEntity<Map<String, String>> updateStatus(
            @PathVariable UUID deliveryId,
            @Valid @RequestBody UpdateDeliveryStatusRequest request) {
        deliveryService.updateStatus(deliveryId, request);
        return ResponseEntity.ok(Map.of("status", "accepted"));
    }

    @PostMapping("/{deliveryId}/location")
    public ResponseEntity<Map<String, String>> updateLocation(
            @PathVariable UUID deliveryId,
            @Valid @RequestBody UpdateDeliveryLocationRequest request) {
        deliveryService.recordLocation(deliveryId, request);
        return ResponseEntity.accepted().body(Map.of("status", "accepted"));
    }

    @GetMapping("/orders/{orderId}/tracking")
    public ResponseEntity<DeliveryTrackingResponse> getTracking(@PathVariable UUID orderId) {
        return ResponseEntity.ok(deliveryService.getTracking(orderId));
    }

    @GetMapping("/rider/available")
    public ResponseEntity<List<RiderDeliveryResponse>> getAvailableForRider(
            @RequestParam double lat,
            @RequestParam double lng) {
        return ResponseEntity.ok(deliveryService.getAvailableForRider(lat, lng));
    }

    @PostMapping("/{deliveryId}/accept")
    public ResponseEntity<RiderDeliveryResponse> acceptDelivery(
            HttpServletRequest servletRequest,
            @PathVariable UUID deliveryId,
            @RequestBody AcceptDeliveryRequest request) {
        UUID riderId = extractUserId(servletRequest);
        return ResponseEntity.ok(deliveryService.acceptDelivery(deliveryId, riderId, request.riderLat(), request.riderLng()));
    }

    @GetMapping("/rider/active")
    public ResponseEntity<List<RiderDeliveryResponse>> getRiderActive(HttpServletRequest servletRequest) {
        UUID riderId = extractUserId(servletRequest);
        return ResponseEntity.ok(deliveryService.getRiderActive(riderId));
    }

    @GetMapping("/{deliveryId}/chat")
    public ResponseEntity<List<ChatMessageResponse>> getChatHistory(@PathVariable UUID deliveryId) {
        List<ChatMessageEntity> messages = chatMessageRepository.findTop50ByDeliveryIdOrderBySentAtDesc(deliveryId);
        List<ChatMessageResponse> response = messages.stream()
                .map(m -> new ChatMessageResponse(m.getId(), m.getDeliveryId(), m.getSenderId(),
                        m.getSenderRole(), m.getBody(), m.getSentAt()))
                .collect(Collectors.toList());
        Collections.reverse(response);
        return ResponseEntity.ok(response);
    }

    private UUID extractUserId(HttpServletRequest request) {
        return UserContext.getUserId(request)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
    }
}
