package com.zimbite.delivery.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.model.dto.DeliveryTrackingResponse;
import com.zimbite.delivery.model.entity.DeliveryEntity;
import com.zimbite.delivery.repository.DeliveryLocationRepository;
import com.zimbite.delivery.repository.DeliveryRepository;
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

@ExtendWith(MockitoExtension.class)
class DeliveryServiceTest {

  @Mock
  private DeliveryRepository deliveryRepository;

  @Mock
  private DeliveryLocationRepository locationRepository;

  @Mock
  private KafkaTemplate<String, String> kafkaTemplate;

  private DeliveryService deliveryService;

  @BeforeEach
  void setUp() {
    deliveryService = new DeliveryService(
        deliveryRepository,
        locationRepository,
        kafkaTemplate,
        new ObjectMapper().findAndRegisterModules()
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

    when(deliveryRepository.findByOrderId(orderId)).thenReturn(Optional.empty());
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
    when(locationRepository.findFirstByDeliveryIdOrderByRecordedAtDesc(delivery.getId())).thenReturn(Optional.empty());

    DeliveryTrackingResponse tracking = deliveryService.getTracking(orderId);

    assertNotNull(tracking.estimatedArrivalAt());
    assertTrue(tracking.estimatedArrivalAt().isAfter(tracking.lastUpdatedAt()));
  }
}
