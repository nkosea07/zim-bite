package com.zimbite.delivery.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.dto.UpdateDeliveryStatusRequest;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import jakarta.validation.Valid;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
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

  private static final Logger log = LoggerFactory.getLogger(DeliveryController.class);

  private final KafkaTemplate<String, String> kafkaTemplate;
  private final ObjectMapper objectMapper;

  public DeliveryController(KafkaTemplate<String, String> kafkaTemplate, ObjectMapper objectMapper) {
    this.kafkaTemplate = kafkaTemplate;
    this.objectMapper = objectMapper;
  }

  @PatchMapping("/{deliveryId}/status")
  public ResponseEntity<Map<String, String>> updateStatus(
      @PathVariable UUID deliveryId,
      @Valid @RequestBody UpdateDeliveryStatusRequest request
  ) {
    String normalizedStatus = request.status().trim().toUpperCase();
    if ("DELIVERED".equals(normalizedStatus)) {
      DeliveryCompletedEvent event = new DeliveryCompletedEvent(
          deliveryId,
          request.orderId(),
          request.riderId(),
          OffsetDateTime.now()
      );
      publishDeliveryCompleted(event);
    } else {
      log.info("Received delivery status update: deliveryId={}, orderId={}, status={}",
          deliveryId, request.orderId(), normalizedStatus);
    }

    return ResponseEntity.ok(Map.of("status", "accepted"));
  }

  @PostMapping("/{deliveryId}/location")
  public ResponseEntity<Map<String, String>> updateLocation(
      @PathVariable UUID deliveryId,
      @Valid @RequestBody UpdateDeliveryLocationRequest request
  ) {
    log.info("Received delivery location update: deliveryId={}, lat={}, lon={}, recordedAt={}",
        deliveryId, request.latitude(), request.longitude(), request.recordedAt());
    return ResponseEntity.accepted().body(Map.of("status", "accepted"));
  }

  @GetMapping("/orders/{orderId}/tracking")
  public ResponseEntity<Map<String, Object>> getTracking(@PathVariable UUID orderId) {
    UUID deliveryId = UUID.nameUUIDFromBytes(("delivery-" + orderId).getBytes(StandardCharsets.UTF_8));
    UUID riderId = UUID.nameUUIDFromBytes(("rider-" + orderId).getBytes(StandardCharsets.UTF_8));

    Map<String, Object> response = new LinkedHashMap<>();
    response.put("orderId", orderId);
    response.put("deliveryId", deliveryId);
    response.put("riderId", riderId);
    response.put("status", "OUT_FOR_DELIVERY");
    response.put("lastUpdatedAt", OffsetDateTime.now());
    return ResponseEntity.ok(response);
  }

  private void publishDeliveryCompleted(DeliveryCompletedEvent event) {
    try {
      String payload = objectMapper.writeValueAsString(event);
      kafkaTemplate.send(Topics.DELIVERY_COMPLETED, event.orderId().toString(), payload).join();
      log.info("Published delivery.completed: orderId={}, deliveryId={}, riderId={}",
          event.orderId(), event.deliveryId(), event.riderId());
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize delivery.completed event", e);
    }
  }
}
