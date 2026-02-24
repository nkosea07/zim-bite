package com.zimbite.delivery.controller;

import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.dto.UpdateDeliveryStatusRequest;
import com.zimbite.delivery.service.DeliveryService;
import jakarta.validation.Valid;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/deliveries")
public class DeliveryController {

    private final DeliveryService deliveryService;

    public DeliveryController(DeliveryService deliveryService) {
        this.deliveryService = deliveryService;
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
}
