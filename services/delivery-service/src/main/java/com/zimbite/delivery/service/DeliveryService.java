package com.zimbite.delivery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.dto.UpdateDeliveryStatusRequest;
import com.zimbite.delivery.model.entity.DeliveryEntity;
import com.zimbite.delivery.model.entity.DeliveryLocationEntity;
import com.zimbite.delivery.repository.DeliveryLocationRepository;
import com.zimbite.delivery.repository.DeliveryRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class DeliveryService {

    private static final Logger log = LoggerFactory.getLogger(DeliveryService.class);

    private final DeliveryRepository deliveryRepository;
    private final DeliveryLocationRepository locationRepository;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public DeliveryService(DeliveryRepository deliveryRepository,
                           DeliveryLocationRepository locationRepository,
                           KafkaTemplate<String, String> kafkaTemplate,
                           ObjectMapper objectMapper) {
        this.deliveryRepository = deliveryRepository;
        this.locationRepository = locationRepository;
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public DeliveryEntity assignDelivery(UUID orderId) {
        if (deliveryRepository.findByOrderId(orderId).isPresent()) {
            log.info("Delivery already exists for orderId={}, skipping", orderId);
            return deliveryRepository.findByOrderId(orderId).get();
        }

        OffsetDateTime now = OffsetDateTime.now();
        UUID deliveryId = UUID.randomUUID();
        UUID riderId = UUID.randomUUID();

        DeliveryEntity delivery = new DeliveryEntity();
        delivery.setId(deliveryId);
        delivery.setOrderId(orderId);
        delivery.setRiderId(riderId);
        delivery.setStatus("ASSIGNED");
        delivery.setAssignedAt(now);
        delivery.setCreatedAt(now);
        delivery.setUpdatedAt(now);

        delivery = deliveryRepository.save(delivery);

        DeliveryAssignedEvent event = new DeliveryAssignedEvent(
                deliveryId, orderId, riderId, now);
        publishEvent(Topics.DELIVERY_ASSIGNED, orderId.toString(), event);
        log.info("Delivery assigned: deliveryId={}, orderId={}, riderId={}", deliveryId, orderId, riderId);

        return delivery;
    }

    @Transactional
    public void updateStatus(UUID deliveryId, UpdateDeliveryStatusRequest request) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Delivery not found"));

        String normalizedStatus = request.status().trim().toUpperCase();
        delivery.setStatus(normalizedStatus);
        delivery.setUpdatedAt(OffsetDateTime.now());

        if ("PICKED_UP".equals(normalizedStatus)) {
            delivery.setPickedUpAt(OffsetDateTime.now());
        } else if ("DELIVERED".equals(normalizedStatus)) {
            delivery.setDeliveredAt(OffsetDateTime.now());
            DeliveryCompletedEvent event = new DeliveryCompletedEvent(
                    deliveryId, delivery.getOrderId(), delivery.getRiderId(), OffsetDateTime.now());
            publishEvent(Topics.DELIVERY_COMPLETED, delivery.getOrderId().toString(), event);
        }

        deliveryRepository.save(delivery);
        log.info("Delivery status updated: deliveryId={}, status={}", deliveryId, normalizedStatus);
    }

    @Transactional
    public void recordLocation(UUID deliveryId, UpdateDeliveryLocationRequest request) {
        if (!deliveryRepository.existsById(deliveryId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Delivery not found");
        }

        DeliveryLocationEntity location = new DeliveryLocationEntity();
        location.setId(UUID.randomUUID());
        location.setDeliveryId(deliveryId);
        location.setLatitude(BigDecimal.valueOf(request.latitude()));
        location.setLongitude(BigDecimal.valueOf(request.longitude()));
        location.setRecordedAt(request.recordedAt());
        location.setCreatedAt(OffsetDateTime.now());

        locationRepository.save(location);
    }

    public DeliveryTrackingResponse getTracking(UUID orderId) {
        DeliveryEntity delivery = deliveryRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No delivery found for order"));

        BigDecimal lastLat = null;
        BigDecimal lastLng = null;
        OffsetDateTime lastUpdated = delivery.getUpdatedAt();

        var lastLocation = locationRepository.findFirstByDeliveryIdOrderByRecordedAtDesc(delivery.getId());
        if (lastLocation.isPresent()) {
            lastLat = lastLocation.get().getLatitude();
            lastLng = lastLocation.get().getLongitude();
            lastUpdated = lastLocation.get().getRecordedAt();
        }

        return new DeliveryTrackingResponse(
                orderId, delivery.getId(), delivery.getRiderId(),
                delivery.getStatus(), lastLat, lastLng, lastUpdated);
    }

    private <T> void publishEvent(String topic, String key, T event) {
        try {
            String payload = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(topic, key, payload).join();
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize event for topic " + topic, e);
        }
    }
}
