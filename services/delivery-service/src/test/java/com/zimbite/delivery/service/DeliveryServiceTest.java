package com.zimbite.delivery.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.entity.DeliveryEntity;
import com.zimbite.delivery.model.entity.OrderDeliverySnapshotEntity;
import com.zimbite.delivery.repository.DeliveryLocationRepository;
import com.zimbite.delivery.repository.DeliveryRepository;
import com.zimbite.delivery.repository.OrderDeliverySnapshotRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class DeliveryServiceTest {

  @Mock
  private DeliveryRepository deliveryRepository;

  @Mock
  private DeliveryLocationRepository locationRepository;

  @Mock
  private KafkaTemplate<String, String> kafkaTemplate;

  @Mock
  private OrderDeliverySnapshotRepository orderDeliverySnapshotRepository;

  private DeliveryService deliveryService;

  @BeforeEach
  void setUp() {
    deliveryService = new DeliveryService(
        deliveryRepository,
        locationRepository,
        orderDeliverySnapshotRepository,
        kafkaTemplate,
        new ObjectMapper().findAndRegisterModules(),
        900L,       // maxLocationAgeSeconds
        60L,        // maxFutureSkewSeconds
        95.0,       // maxTrackingSpeedKmh
        12.0,       // minEtaSpeedKmh
        38.0,       // maxEtaSpeedKmh
        18,         // defaultEtaMinutes
        3L,         // minEtaMinutes
        75L,        // maxEtaMinutes
        26.0,       // pickedUpFallbackSpeedKmh
        18.0,       // assignedFallbackSpeedKmh
        2L,         // pickedUpBufferMinutes
        7L,         // assignedBufferMinutes
        12,         // batchWindowMinutes
        2,          // maxActivePerRider
        6,          // morningRushStartHour
        9,          // morningRushEndHour
        0.82,       // morningRushFactor
        16,         // eveningRushStartHour
        18,         // eveningRushEndHour
        0.9         // eveningRushFactor
    );
  }

  @Test
  void assignDeliveryBatchesWithRecentCompatibleRider() {
    UUID orderId = UUID.randomUUID();
    UUID riderId = UUID.randomUUID();
    DeliveryEntity anchor = new DeliveryEntity();
    anchor.setId(UUID.randomUUID());
    anchor.setOrderId(UUID.randomUUID());
    anchor.setRiderId(riderId);
    anchor.setStatus("ASSIGNED");
    anchor.setDropoffLat(new BigDecimal("-17.830000"));
    anchor.setDropoffLng(new BigDecimal("31.050000"));
    anchor.setAssignedAt(OffsetDateTime.now().minusMinutes(3));
    OrderDeliverySnapshotEntity snapshot = new OrderDeliverySnapshotEntity();
    snapshot.setId(orderId);
    snapshot.setPickupLat(new BigDecimal("-17.812500"));
    snapshot.setPickupLng(new BigDecimal("31.045600"));
    snapshot.setDropoffLat(new BigDecimal("-17.890000"));
    snapshot.setDropoffLng(new BigDecimal("31.132000"));

    when(deliveryRepository.findByOrderId(orderId)).thenReturn(Optional.empty());
    when(orderDeliverySnapshotRepository.findById(orderId)).thenReturn(Optional.of(snapshot));
    when(deliveryRepository.findByStatusInAndAssignedAtAfter(anyCollection(), any(OffsetDateTime.class)))
        .thenReturn(List.of(anchor));
    when(deliveryRepository.countByRiderIdAndStatusIn(riderId, List.of("ASSIGNED", "PICKED_UP"))).thenReturn(1L);
    when(deliveryRepository.save(any(DeliveryEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(kafkaTemplate.send(anyString(), anyString(), anyString()))
        .thenReturn(CompletableFuture.completedFuture(null));

    DeliveryEntity created = deliveryService.assignDelivery(orderId);

    assertEquals(riderId, created.getRiderId());
    assertNotNull(created.getPickupLat());
    assertNotNull(created.getDropoffLat());
  }

  @Test
  void assignDeliveryReturnsExistingWithoutPublishing() {
    UUID orderId = UUID.randomUUID();
    DeliveryEntity existing = new DeliveryEntity();
    existing.setId(UUID.randomUUID());
    existing.setOrderId(orderId);

    when(deliveryRepository.findByOrderId(orderId)).thenReturn(Optional.of(existing));

    DeliveryEntity returned = deliveryService.assignDelivery(orderId);

    assertEquals(existing.getId(), returned.getId());
    verify(deliveryRepository, never()).save(any(DeliveryEntity.class));
    verify(kafkaTemplate, never()).send(anyString(), anyString(), anyString());
  }

  @Test
  void getTrackingIncludesEtaForInFlightDelivery() {
    UUID orderId = UUID.randomUUID();
    DeliveryEntity delivery = new DeliveryEntity();
    delivery.setId(UUID.randomUUID());
    delivery.setOrderId(orderId);
    delivery.setRiderId(UUID.randomUUID());
    delivery.setStatus("ASSIGNED");
    delivery.setPickupLat(new BigDecimal("-17.820000"));
    delivery.setPickupLng(new BigDecimal("31.040000"));
    delivery.setDropoffLat(new BigDecimal("-17.900000"));
    delivery.setDropoffLng(new BigDecimal("31.120000"));
    delivery.setUpdatedAt(OffsetDateTime.now());

    when(deliveryRepository.findByOrderId(orderId)).thenReturn(Optional.of(delivery));
    when(locationRepository.findTop5ByDeliveryIdOrderByRecordedAtDesc(delivery.getId())).thenReturn(List.of());

    DeliveryTrackingResponse tracking = deliveryService.getTracking(orderId);

    assertNotNull(tracking.estimatedArrivalAt());
    assertTrue(tracking.estimatedArrivalAt().isAfter(tracking.lastUpdatedAt()));
  }

  @Test
  void recordLocationRejectsOutlierJump() {
    UUID deliveryId = UUID.randomUUID();
    DeliveryEntity delivery = new DeliveryEntity();
    delivery.setId(deliveryId);
    delivery.setPickupLat(new BigDecimal("-17.820000"));
    delivery.setPickupLng(new BigDecimal("31.040000"));
    delivery.setAssignedAt(OffsetDateTime.now().minusMinutes(3));
    delivery.setUpdatedAt(OffsetDateTime.now().minusMinutes(1));

    OffsetDateTime previousTime = OffsetDateTime.now().minusSeconds(70);
    var previous = new com.zimbite.delivery.model.entity.DeliveryLocationEntity();
    previous.setId(UUID.randomUUID());
    previous.setDeliveryId(deliveryId);
    previous.setLatitude(new BigDecimal("-17.820000"));
    previous.setLongitude(new BigDecimal("31.040000"));
    previous.setRecordedAt(previousTime);
    previous.setCreatedAt(previousTime);

    when(deliveryRepository.findById(deliveryId)).thenReturn(Optional.of(delivery));
    when(locationRepository.findFirstByDeliveryIdOrderByRecordedAtDesc(deliveryId)).thenReturn(Optional.of(previous));

    UpdateDeliveryLocationRequest request = new UpdateDeliveryLocationRequest(
        -17.100000,
        32.500000,
        OffsetDateTime.now()
    );

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> deliveryService.recordLocation(deliveryId, request)
    );

    assertEquals(422, error.getStatusCode().value());
    verify(locationRepository, never()).save(any());
  }
}
