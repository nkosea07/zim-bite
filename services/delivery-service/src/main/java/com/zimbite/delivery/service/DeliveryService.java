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
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
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
    private static final List<String> ACTIVE_STATUSES = List.of("ASSIGNED", "PICKED_UP");
    private static final int BATCH_WINDOW_MINUTES = 12;
    private static final int MAX_ACTIVE_BATCH_PER_RIDER = 2;
    private static final int DEFAULT_ETA_MINUTES = 18;
    private static final List<UUID> RIDER_POOL = List.of(
            UUID.nameUUIDFromBytes("rider-alpha".getBytes(StandardCharsets.UTF_8)),
            UUID.nameUUIDFromBytes("rider-bravo".getBytes(StandardCharsets.UTF_8)),
            UUID.nameUUIDFromBytes("rider-charlie".getBytes(StandardCharsets.UTF_8)),
            UUID.nameUUIDFromBytes("rider-delta".getBytes(StandardCharsets.UTF_8)),
            UUID.nameUUIDFromBytes("rider-echo".getBytes(StandardCharsets.UTF_8)),
            UUID.nameUUIDFromBytes("rider-foxtrot".getBytes(StandardCharsets.UTF_8))
    );

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
        var existingDelivery = deliveryRepository.findByOrderId(orderId);
        if (existingDelivery.isPresent()) {
            log.info("Delivery already exists for orderId={}, skipping", orderId);
            return existingDelivery.get();
        }

        OffsetDateTime now = OffsetDateTime.now();
        UUID deliveryId = UUID.randomUUID();
        RoutePoint pickup = routePoint(orderId, true);
        RoutePoint dropoff = routePoint(orderId, false);
        AssignmentPlan assignmentPlan = resolveAssignmentPlan(now, pickup);

        DeliveryEntity delivery = new DeliveryEntity();
        delivery.setId(deliveryId);
        delivery.setOrderId(orderId);
        delivery.setRiderId(assignmentPlan.riderId());
        delivery.setStatus("ASSIGNED");
        delivery.setPickupLat(pickup.latitude());
        delivery.setPickupLng(pickup.longitude());
        delivery.setDropoffLat(dropoff.latitude());
        delivery.setDropoffLng(dropoff.longitude());
        delivery.setAssignedAt(now);
        delivery.setCreatedAt(now);
        delivery.setUpdatedAt(now);

        delivery = deliveryRepository.save(delivery);

        DeliveryAssignedEvent event = new DeliveryAssignedEvent(
                deliveryId, orderId, assignmentPlan.riderId(), now);
        publishEvent(Topics.DELIVERY_ASSIGNED, orderId.toString(), event);
        if (assignmentPlan.batched()) {
            log.info("Delivery batched: deliveryId={}, orderId={}, riderId={}, batchAnchorOrderId={}, routeExtensionKm={}",
                    deliveryId, orderId, assignmentPlan.riderId(), assignmentPlan.anchorOrderId(), assignmentPlan.routeExtensionKm());
        } else {
            log.info("Delivery assigned: deliveryId={}, orderId={}, riderId={}",
                    deliveryId, orderId, assignmentPlan.riderId());
        }

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

        BigDecimal lastLat = delivery.getPickupLat();
        BigDecimal lastLng = delivery.getPickupLng();
        OffsetDateTime lastUpdated = delivery.getUpdatedAt();

        var lastLocation = locationRepository.findFirstByDeliveryIdOrderByRecordedAtDesc(delivery.getId());
        if (lastLocation.isPresent()) {
            lastLat = lastLocation.get().getLatitude();
            lastLng = lastLocation.get().getLongitude();
            lastUpdated = lastLocation.get().getRecordedAt();
        }

        OffsetDateTime eta = estimateArrival(delivery, lastLat, lastLng, lastUpdated);

        return new DeliveryTrackingResponse(
                orderId, delivery.getId(), delivery.getRiderId(),
                delivery.getStatus(), lastLat, lastLng, lastUpdated, eta);
    }

    private <T> void publishEvent(String topic, String key, T event) {
        try {
            String payload = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(topic, key, payload).join();
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize event for topic " + topic, e);
        }
    }

    private AssignmentPlan resolveAssignmentPlan(OffsetDateTime now, RoutePoint pickup) {
        OffsetDateTime windowStart = now.minusMinutes(BATCH_WINDOW_MINUTES);
        List<DeliveryEntity> recentActive = deliveryRepository.findByStatusInAndAssignedAtAfter(ACTIVE_STATUSES, windowStart);

        var candidate = recentActive.stream()
                .filter(delivery -> delivery.getRiderId() != null)
                .filter(delivery -> delivery.getDropoffLat() != null && delivery.getDropoffLng() != null)
                .filter(delivery -> activeDeliveriesFor(delivery.getRiderId()) < MAX_ACTIVE_BATCH_PER_RIDER)
                .map(delivery -> new AssignmentCandidate(
                        delivery,
                        distanceKm(delivery.getDropoffLat(), delivery.getDropoffLng(), pickup.latitude(), pickup.longitude())))
                .min(Comparator.comparingDouble(AssignmentCandidate::routeExtensionKm));

        if (candidate.isPresent()) {
            DeliveryEntity anchor = candidate.get().anchorDelivery();
            return new AssignmentPlan(
                    anchor.getRiderId(),
                    true,
                    anchor.getOrderId(),
                    roundKm(candidate.get().routeExtensionKm())
            );
        }

        UUID riderId = RIDER_POOL.stream()
                .min(Comparator.comparingLong(this::activeDeliveriesFor))
                .orElse(UUID.nameUUIDFromBytes(("fallback-rider-" + pickup.latitude() + pickup.longitude())
                        .getBytes(StandardCharsets.UTF_8)));

        return new AssignmentPlan(riderId, false, null, 0.0);
    }

    private long activeDeliveriesFor(UUID riderId) {
        return deliveryRepository.countByRiderIdAndStatusIn(riderId, ACTIVE_STATUSES);
    }

    private RoutePoint routePoint(UUID orderId, boolean pickup) {
        String token = (pickup ? "pickup-" : "dropoff-") + orderId;
        UUID seed = UUID.nameUUIDFromBytes(token.getBytes(StandardCharsets.UTF_8));
        BigDecimal latitude = coordinate(seed.getMostSignificantBits(), -17.8292, pickup ? 0.06 : 0.10);
        BigDecimal longitude = coordinate(seed.getLeastSignificantBits(), 31.0522, pickup ? 0.06 : 0.10);
        return new RoutePoint(latitude, longitude);
    }

    private BigDecimal coordinate(long seed, double center, double spread) {
        long positiveSeed = seed == Long.MIN_VALUE ? Long.MAX_VALUE : Math.abs(seed);
        double normalized = (positiveSeed % 10000) / 10000.0;
        double value = center + ((normalized - 0.5) * spread);
        return BigDecimal.valueOf(value).setScale(6, RoundingMode.HALF_UP);
    }

    private OffsetDateTime estimateArrival(
            DeliveryEntity delivery,
            BigDecimal lastLat,
            BigDecimal lastLng,
            OffsetDateTime lastUpdated
    ) {
        if ("DELIVERED".equalsIgnoreCase(delivery.getStatus())) {
            return delivery.getDeliveredAt() == null ? lastUpdated : delivery.getDeliveredAt();
        }

        if (delivery.getDropoffLat() == null || delivery.getDropoffLng() == null) {
            return lastUpdated.plusMinutes(DEFAULT_ETA_MINUTES);
        }

        BigDecimal sourceLat = lastLat != null ? lastLat : delivery.getPickupLat();
        BigDecimal sourceLng = lastLng != null ? lastLng : delivery.getPickupLng();
        if (sourceLat == null || sourceLng == null) {
            return lastUpdated.plusMinutes(DEFAULT_ETA_MINUTES);
        }

        double distanceKm = distanceKm(sourceLat, sourceLng, delivery.getDropoffLat(), delivery.getDropoffLng());
        double speedKmh = "PICKED_UP".equalsIgnoreCase(delivery.getStatus()) ? 28.0 : 18.0;
        long baseMinutes = (long) Math.ceil((distanceKm / speedKmh) * 60.0);
        long bufferMinutes = "PICKED_UP".equalsIgnoreCase(delivery.getStatus()) ? 4L : 8L;
        long etaMinutes = Math.max(5L, Math.min(45L, baseMinutes + bufferMinutes));
        return lastUpdated.plusMinutes(etaMinutes);
    }

    private double distanceKm(BigDecimal lat1, BigDecimal lng1, BigDecimal lat2, BigDecimal lng2) {
        return distanceKm(lat1.doubleValue(), lng1.doubleValue(), lat2.doubleValue(), lng2.doubleValue());
    }

    private double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        final double earthRadiusKm = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadiusKm * c;
    }

    private double roundKm(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private record RoutePoint(BigDecimal latitude, BigDecimal longitude) {
    }

    private record AssignmentCandidate(DeliveryEntity anchorDelivery, double routeExtensionKm) {
    }

    private record AssignmentPlan(UUID riderId, boolean batched, UUID anchorOrderId, double routeExtensionKm) {
    }
}
