package com.zimbite.delivery.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.dto.UpdateDeliveryStatusRequest;
import com.zimbite.delivery.model.entity.DeliveryEntity;
import com.zimbite.delivery.model.entity.DeliveryLocationEntity;
import com.zimbite.delivery.model.entity.OrderDeliverySnapshotEntity;
import com.zimbite.delivery.repository.DeliveryLocationRepository;
import com.zimbite.delivery.repository.DeliveryRepository;
import com.zimbite.delivery.repository.OrderDeliverySnapshotRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class DeliveryService {

    private static final Logger log = LoggerFactory.getLogger(DeliveryService.class);
    private static final List<String> ACTIVE_STATUSES = List.of("ASSIGNED", "PICKED_UP");

    private final DeliveryRepository deliveryRepository;
    private final DeliveryLocationRepository locationRepository;
    private final OrderDeliverySnapshotRepository orderDeliverySnapshotRepository;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    // tracking
    private final long maxLocationAgeSeconds;
    private final long maxFutureSkewSeconds;
    private final double maxTrackingSpeedKmh;

    // ETA
    private final double minEtaSpeedKmh;
    private final double maxEtaSpeedKmh;
    private final int defaultEtaMinutes;
    private final long minEtaMinutes;
    private final long maxEtaMinutes;
    private final double pickedUpFallbackSpeedKmh;
    private final double assignedFallbackSpeedKmh;
    private final long pickedUpBufferMinutes;
    private final long assignedBufferMinutes;

    // assignment
    private final int batchWindowMinutes;
    private final int maxActivePerRider;

    // traffic
    private final int morningRushStartHour;
    private final int morningRushEndHour;
    private final double morningRushFactor;
    private final int eveningRushStartHour;
    private final int eveningRushEndHour;
    private final double eveningRushFactor;

    public DeliveryService(
            DeliveryRepository deliveryRepository,
            DeliveryLocationRepository locationRepository,
            OrderDeliverySnapshotRepository orderDeliverySnapshotRepository,
            KafkaTemplate<String, String> kafkaTemplate,
            ObjectMapper objectMapper,
            @Value("${delivery.tracking.max-location-age-seconds:900}") long maxLocationAgeSeconds,
            @Value("${delivery.tracking.max-future-skew-seconds:60}") long maxFutureSkewSeconds,
            @Value("${delivery.tracking.max-speed-kmh:95.0}") double maxTrackingSpeedKmh,
            @Value("${delivery.eta.min-speed-kmh:12.0}") double minEtaSpeedKmh,
            @Value("${delivery.eta.max-speed-kmh:38.0}") double maxEtaSpeedKmh,
            @Value("${delivery.eta.default-minutes:18}") int defaultEtaMinutes,
            @Value("${delivery.eta.min-minutes:3}") long minEtaMinutes,
            @Value("${delivery.eta.max-minutes:75}") long maxEtaMinutes,
            @Value("${delivery.eta.picked-up-fallback-speed-kmh:26.0}") double pickedUpFallbackSpeedKmh,
            @Value("${delivery.eta.assigned-fallback-speed-kmh:18.0}") double assignedFallbackSpeedKmh,
            @Value("${delivery.eta.picked-up-buffer-minutes:2}") long pickedUpBufferMinutes,
            @Value("${delivery.eta.assigned-buffer-minutes:7}") long assignedBufferMinutes,
            @Value("${delivery.assignment.batch-window-minutes:12}") int batchWindowMinutes,
            @Value("${delivery.assignment.max-active-per-rider:2}") int maxActivePerRider,
            @Value("${delivery.traffic.morning-rush-start-hour:6}") int morningRushStartHour,
            @Value("${delivery.traffic.morning-rush-end-hour:9}") int morningRushEndHour,
            @Value("${delivery.traffic.morning-rush-factor:0.82}") double morningRushFactor,
            @Value("${delivery.traffic.evening-rush-start-hour:16}") int eveningRushStartHour,
            @Value("${delivery.traffic.evening-rush-end-hour:18}") int eveningRushEndHour,
            @Value("${delivery.traffic.evening-rush-factor:0.9}") double eveningRushFactor
    ) {
        this.deliveryRepository = deliveryRepository;
        this.locationRepository = locationRepository;
        this.orderDeliverySnapshotRepository = orderDeliverySnapshotRepository;
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
        this.maxLocationAgeSeconds = maxLocationAgeSeconds;
        this.maxFutureSkewSeconds = maxFutureSkewSeconds;
        this.maxTrackingSpeedKmh = maxTrackingSpeedKmh;
        this.minEtaSpeedKmh = minEtaSpeedKmh;
        this.maxEtaSpeedKmh = maxEtaSpeedKmh;
        this.defaultEtaMinutes = defaultEtaMinutes;
        this.minEtaMinutes = minEtaMinutes;
        this.maxEtaMinutes = maxEtaMinutes;
        this.pickedUpFallbackSpeedKmh = pickedUpFallbackSpeedKmh;
        this.assignedFallbackSpeedKmh = assignedFallbackSpeedKmh;
        this.pickedUpBufferMinutes = pickedUpBufferMinutes;
        this.assignedBufferMinutes = assignedBufferMinutes;
        this.batchWindowMinutes = batchWindowMinutes;
        this.maxActivePerRider = maxActivePerRider;
        this.morningRushStartHour = morningRushStartHour;
        this.morningRushEndHour = morningRushEndHour;
        this.morningRushFactor = morningRushFactor;
        this.eveningRushStartHour = eveningRushStartHour;
        this.eveningRushEndHour = eveningRushEndHour;
        this.eveningRushFactor = eveningRushFactor;
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
        RoutePlan route = resolveRoutePlan(orderId);
        AssignmentPlan assignmentPlan = resolveAssignmentPlan(now, new RoutePoint(route.pickupLat(), route.pickupLng()));

        DeliveryEntity delivery = new DeliveryEntity();
        delivery.setId(deliveryId);
        delivery.setOrderId(orderId);
        delivery.setRiderId(assignmentPlan.riderId());
        delivery.setStatus("ASSIGNED");
        delivery.setPickupLat(route.pickupLat());
        delivery.setPickupLng(route.pickupLng());
        delivery.setDropoffLat(route.dropoffLat());
        delivery.setDropoffLng(route.dropoffLng());
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

        String normalizedStatus = request.status().trim().toUpperCase(Locale.ROOT);
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
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Delivery not found"));

        OffsetDateTime now = OffsetDateTime.now();
        OffsetDateTime recordedAt = request.recordedAt();
        validateFreshness(recordedAt, now);

        var lastLocation = locationRepository.findFirstByDeliveryIdOrderByRecordedAtDesc(deliveryId);
        if (lastLocation.isPresent()) {
            DeliveryLocationEntity previous = lastLocation.get();
            if (!recordedAt.isAfter(previous.getRecordedAt())) {
                log.info("Ignoring out-of-order location update: deliveryId={}, recordedAt={}", deliveryId, recordedAt);
                return;
            }
            validateSegmentSpeed(
                    previous.getLatitude(),
                    previous.getLongitude(),
                    previous.getRecordedAt(),
                    BigDecimal.valueOf(request.latitude()),
                    BigDecimal.valueOf(request.longitude()),
                    recordedAt
            );
        } else if (delivery.getPickupLat() != null && delivery.getPickupLng() != null && delivery.getAssignedAt() != null) {
            validateSegmentSpeed(
                    delivery.getPickupLat(),
                    delivery.getPickupLng(),
                    delivery.getAssignedAt(),
                    BigDecimal.valueOf(request.latitude()),
                    BigDecimal.valueOf(request.longitude()),
                    recordedAt
            );
        }

        DeliveryLocationEntity location = new DeliveryLocationEntity();
        location.setId(UUID.randomUUID());
        location.setDeliveryId(deliveryId);
        location.setLatitude(BigDecimal.valueOf(request.latitude()).setScale(6, RoundingMode.HALF_UP));
        location.setLongitude(BigDecimal.valueOf(request.longitude()).setScale(6, RoundingMode.HALF_UP));
        location.setRecordedAt(recordedAt);
        location.setCreatedAt(now);

        locationRepository.save(location);
    }

    public DeliveryTrackingResponse getTracking(UUID orderId) {
        DeliveryEntity delivery = deliveryRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No delivery found for order"));

        List<DeliveryLocationEntity> recentLocations = locationRepository.findTop5ByDeliveryIdOrderByRecordedAtDesc(delivery.getId());

        BigDecimal lastLat = delivery.getPickupLat();
        BigDecimal lastLng = delivery.getPickupLng();
        OffsetDateTime lastUpdated = delivery.getUpdatedAt();

        if (!recentLocations.isEmpty()) {
            DeliveryLocationEntity latest = recentLocations.get(0);
            lastLat = latest.getLatitude();
            lastLng = latest.getLongitude();
            lastUpdated = latest.getRecordedAt();
        }

        OffsetDateTime eta = estimateArrival(delivery, lastLat, lastLng, lastUpdated, recentLocations);

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

    private RoutePlan resolveRoutePlan(UUID orderId) {
        OrderDeliverySnapshotEntity snapshot = orderDeliverySnapshotRepository.findById(orderId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.CONFLICT,
                        "Order delivery coordinates are not available"
                ));

        if (snapshot.getPickupLat() == null
                || snapshot.getPickupLng() == null
                || snapshot.getDropoffLat() == null
                || snapshot.getDropoffLng() == null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Order delivery coordinates are incomplete");
        }

        return new RoutePlan(
                snapshot.getPickupLat(),
                snapshot.getPickupLng(),
                snapshot.getDropoffLat(),
                snapshot.getDropoffLng()
        );
    }

    private AssignmentPlan resolveAssignmentPlan(OffsetDateTime now, RoutePoint pickup) {
        OffsetDateTime windowStart = now.minusMinutes(batchWindowMinutes);
        List<DeliveryEntity> recentActive = deliveryRepository.findByStatusInAndAssignedAtAfter(ACTIVE_STATUSES, windowStart);

        var candidate = recentActive.stream()
                .filter(delivery -> delivery.getRiderId() != null)
                .filter(delivery -> delivery.getDropoffLat() != null && delivery.getDropoffLng() != null)
                .filter(delivery -> activeDeliveriesFor(delivery.getRiderId()) < maxActivePerRider)
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

        UUID riderId = UUID.nameUUIDFromBytes(("fallback-rider-" + pickup.latitude() + pickup.longitude())
                        .getBytes(java.nio.charset.StandardCharsets.UTF_8));

        return new AssignmentPlan(riderId, false, null, 0.0);
    }

    private long activeDeliveriesFor(UUID riderId) {
        return deliveryRepository.countByRiderIdAndStatusIn(riderId, ACTIVE_STATUSES);
    }

    private void validateFreshness(OffsetDateTime recordedAt, OffsetDateTime now) {
        if (recordedAt.isBefore(now.minusSeconds(maxLocationAgeSeconds))) {
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "Location update is too old");
        }
        if (recordedAt.isAfter(now.plusSeconds(maxFutureSkewSeconds))) {
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "Location update timestamp is in the future");
        }
    }

    private void validateSegmentSpeed(
            BigDecimal fromLat,
            BigDecimal fromLng,
            OffsetDateTime fromTime,
            BigDecimal toLat,
            BigDecimal toLng,
            OffsetDateTime toTime
    ) {
        long elapsedSeconds = ChronoUnit.SECONDS.between(fromTime, toTime);
        if (elapsedSeconds <= 0) {
            return;
        }

        double distanceKm = distanceKm(fromLat, fromLng, toLat, toLng);
        double speedKmh = distanceKm / (elapsedSeconds / 3600.0);
        if (speedKmh > maxTrackingSpeedKmh) {
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "Location update rejected as outlier");
        }
    }

    private OffsetDateTime estimateArrival(
            DeliveryEntity delivery,
            BigDecimal lastLat,
            BigDecimal lastLng,
            OffsetDateTime lastUpdated,
            List<DeliveryLocationEntity> recentLocations
    ) {
        if ("DELIVERED".equalsIgnoreCase(delivery.getStatus())) {
            return delivery.getDeliveredAt() == null ? lastUpdated : delivery.getDeliveredAt();
        }

        if (delivery.getDropoffLat() == null || delivery.getDropoffLng() == null) {
            return lastUpdated.plusMinutes(defaultEtaMinutes);
        }

        BigDecimal sourceLat = lastLat != null ? lastLat : delivery.getPickupLat();
        BigDecimal sourceLng = lastLng != null ? lastLng : delivery.getPickupLng();
        if (sourceLat == null || sourceLng == null) {
            return lastUpdated.plusMinutes(defaultEtaMinutes);
        }

        double remainingKm = remainingDistanceKm(delivery, sourceLat, sourceLng);
        if (remainingKm <= 0.05) {
            return lastUpdated.plusMinutes(minEtaMinutes);
        }

        double speedKmh = estimateEffectiveSpeedKmh(delivery, recentLocations, lastUpdated);
        long baseMinutes = (long) Math.ceil((remainingKm / speedKmh) * 60.0);
        long bufferMinutes = "PICKED_UP".equalsIgnoreCase(delivery.getStatus()) ? pickedUpBufferMinutes : assignedBufferMinutes;
        long etaMinutes = clamp(minEtaMinutes, maxEtaMinutes, baseMinutes + bufferMinutes);
        return lastUpdated.plusMinutes(etaMinutes);
    }

    private double remainingDistanceKm(DeliveryEntity delivery, BigDecimal sourceLat, BigDecimal sourceLng) {
        double toDropoff = distanceKm(sourceLat, sourceLng, delivery.getDropoffLat(), delivery.getDropoffLng());
        if ("PICKED_UP".equalsIgnoreCase(delivery.getStatus())) {
            return toDropoff;
        }

        if (delivery.getPickupLat() == null || delivery.getPickupLng() == null) {
            return toDropoff;
        }

        double toPickup = distanceKm(sourceLat, sourceLng, delivery.getPickupLat(), delivery.getPickupLng());
        double pickupToDropoff = distanceKm(
                delivery.getPickupLat(),
                delivery.getPickupLng(),
                delivery.getDropoffLat(),
                delivery.getDropoffLng()
        );
        return toPickup + pickupToDropoff;
    }

    private double estimateEffectiveSpeedKmh(
            DeliveryEntity delivery,
            List<DeliveryLocationEntity> recentLocations,
            OffsetDateTime lastUpdated
    ) {
        double fallback = "PICKED_UP".equalsIgnoreCase(delivery.getStatus()) ? pickedUpFallbackSpeedKmh : assignedFallbackSpeedKmh;

        double total = 0.0;
        int count = 0;
        for (int i = 0; i + 1 < recentLocations.size(); i++) {
            DeliveryLocationEntity newer = recentLocations.get(i);
            DeliveryLocationEntity older = recentLocations.get(i + 1);
            long seconds = ChronoUnit.SECONDS.between(older.getRecordedAt(), newer.getRecordedAt());
            if (seconds <= 0) {
                continue;
            }
            double distanceKm = distanceKm(
                    older.getLatitude(),
                    older.getLongitude(),
                    newer.getLatitude(),
                    newer.getLongitude()
            );
            double speedKmh = distanceKm / (seconds / 3600.0);
            if (speedKmh <= 0.0 || speedKmh > maxTrackingSpeedKmh) {
                continue;
            }
            total += speedKmh;
            count++;
        }

        double observed = count == 0 ? fallback : total / count;
        double trafficAdjusted = observed * trafficFactor(lastUpdated);
        return clamp(minEtaSpeedKmh, maxEtaSpeedKmh, trafficAdjusted);
    }

    private double trafficFactor(OffsetDateTime at) {
        int hour = at.getHour();
        if (hour >= morningRushStartHour && hour <= morningRushEndHour) {
            return morningRushFactor;
        }
        if (hour >= eveningRushStartHour && hour <= eveningRushEndHour) {
            return eveningRushFactor;
        }
        return 1.0;
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

    private long clamp(long min, long max, long value) {
        return Math.max(min, Math.min(max, value));
    }

    private double clamp(double min, double max, double value) {
        return Math.max(min, Math.min(max, value));
    }

    private double roundKm(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private record RoutePlan(BigDecimal pickupLat, BigDecimal pickupLng, BigDecimal dropoffLat, BigDecimal dropoffLng) {
    }

    private record RoutePoint(BigDecimal latitude, BigDecimal longitude) {
    }

    private record AssignmentCandidate(DeliveryEntity anchorDelivery, double routeExtensionKm) {
    }

    private record AssignmentPlan(UUID riderId, boolean batched, UUID anchorOrderId, double routeExtensionKm) {
    }
}
