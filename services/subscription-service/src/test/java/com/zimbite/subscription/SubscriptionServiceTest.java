package com.zimbite.subscription;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.subscription.model.dto.CreateSubscriptionRequest;
import com.zimbite.subscription.model.dto.SubscriptionResponse;
import com.zimbite.subscription.model.entity.SubscriptionDeliveryEntity;
import com.zimbite.subscription.model.entity.SubscriptionEntity;
import com.zimbite.subscription.model.entity.SubscriptionItemEntity;
import com.zimbite.subscription.repository.SubscriptionDeliveryRepository;
import com.zimbite.subscription.repository.SubscriptionItemRepository;
import com.zimbite.subscription.repository.SubscriptionRepository;
import com.zimbite.subscription.service.SubscriptionService;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.server.ResponseStatusException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SubscriptionServiceTest {

  @Mock SubscriptionRepository subscriptionRepository;
  @Mock SubscriptionItemRepository subscriptionItemRepository;
  @Mock SubscriptionDeliveryRepository subscriptionDeliveryRepository;
  @Mock KafkaTemplate<String, String> kafkaTemplate;

  private SubscriptionService service;

  @BeforeEach
  void setUp() {
    service = new SubscriptionService(
        subscriptionRepository, subscriptionItemRepository,
        subscriptionDeliveryRepository, kafkaTemplate, new ObjectMapper()
    );
  }

  @Test
  void createSubscription_persistsAndReturnsResponse() {
    UUID userId = UUID.randomUUID();
    UUID vendorId = UUID.randomUUID();
    UUID addressId = UUID.randomUUID();
    UUID itemId = UUID.randomUUID();

    CreateSubscriptionRequest request = new CreateSubscriptionRequest(
        vendorId, addressId, "DAILY", "USD",
        List.of(new CreateSubscriptionRequest.SubscriptionItemRequest(itemId, 2)),
        "Morning Combo", null
    );

    ArgumentCaptor<SubscriptionEntity> subCaptor = ArgumentCaptor.forClass(SubscriptionEntity.class);
    when(subscriptionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    when(subscriptionItemRepository.saveAll(anyList())).thenAnswer(inv -> inv.getArgument(0));

    SubscriptionResponse response = service.createSubscription(userId, request);

    verify(subscriptionRepository).save(subCaptor.capture());
    SubscriptionEntity saved = subCaptor.getValue();

    assertThat(saved.getUserId()).isEqualTo(userId);
    assertThat(saved.getVendorId()).isEqualTo(vendorId);
    assertThat(saved.getStatus()).isEqualTo("ACTIVE");
    assertThat(saved.getPlanType()).isEqualTo("DAILY");
    assertThat(response.status()).isEqualTo("ACTIVE");
    assertThat(response.items()).hasSize(1);
    assertThat(response.items().get(0).menuItemId()).isEqualTo(itemId);
  }

  @Test
  void pauseSubscription_onlyAllowedWhenActive() {
    UUID subscriptionId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();

    SubscriptionEntity subscription = activeSubscription(subscriptionId, userId);
    subscription.setStatus("PAUSED");
    when(subscriptionRepository.findById(subscriptionId)).thenReturn(Optional.of(subscription));

    assertThatThrownBy(() -> service.pauseSubscription(subscriptionId, userId))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("ACTIVE");
  }

  @Test
  void pauseSubscription_updatesStatusAndPublishesEvent() {
    UUID subscriptionId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();

    SubscriptionEntity subscription = activeSubscription(subscriptionId, userId);
    when(subscriptionRepository.findById(subscriptionId)).thenReturn(Optional.of(subscription));
    when(subscriptionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    when(subscriptionItemRepository.findBySubscriptionId(subscriptionId)).thenReturn(List.of());

    SubscriptionResponse response = service.pauseSubscription(subscriptionId, userId);

    assertThat(response.status()).isEqualTo("PAUSED");
    verify(kafkaTemplate).send(any(), any(), any());
  }

  @Test
  void cancelSubscription_idempotentWhenAlreadyCancelled() {
    UUID subscriptionId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();

    SubscriptionEntity subscription = activeSubscription(subscriptionId, userId);
    subscription.setStatus("CANCELLED");
    subscription.setCancelledAt(OffsetDateTime.now());
    when(subscriptionRepository.findById(subscriptionId)).thenReturn(Optional.of(subscription));
    when(subscriptionItemRepository.findBySubscriptionId(subscriptionId)).thenReturn(List.of());

    SubscriptionResponse response = service.cancelSubscription(subscriptionId, userId);
    assertThat(response.status()).isEqualTo("CANCELLED");
  }

  @Test
  void cancelSubscription_forbidsWrongOwner() {
    UUID subscriptionId = UUID.randomUUID();
    UUID ownerId = UUID.randomUUID();
    UUID otherId = UUID.randomUUID();

    SubscriptionEntity subscription = activeSubscription(subscriptionId, ownerId);
    when(subscriptionRepository.findById(subscriptionId)).thenReturn(Optional.of(subscription));

    assertThatThrownBy(() -> service.cancelSubscription(subscriptionId, otherId))
        .isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("Access denied");
  }

  @Test
  void dispatchDueDeliveries_skipsWhenNoneAreDue() {
    when(subscriptionRepository.findByStatusAndNextDeliveryAtBefore(any(), any())).thenReturn(List.of());
    service.dispatchDueDeliveries();
  }

  @Test
  void dispatchDueDeliveries_createsDeliveryRecordAndAdvancesNextDelivery() {
    UUID subscriptionId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();

    SubscriptionEntity subscription = activeSubscription(subscriptionId, userId);
    subscription.setNextDeliveryAt(OffsetDateTime.now().minusMinutes(5));

    when(subscriptionRepository.findByStatusAndNextDeliveryAtBefore(any(), any()))
        .thenReturn(List.of(subscription));
    when(subscriptionDeliveryRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    when(subscriptionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

    service.dispatchDueDeliveries();

    ArgumentCaptor<SubscriptionDeliveryEntity> deliveryCaptor =
        ArgumentCaptor.forClass(SubscriptionDeliveryEntity.class);
    verify(subscriptionDeliveryRepository).save(deliveryCaptor.capture());
    assertThat(deliveryCaptor.getValue().getStatus()).isEqualTo("PENDING");
    assertThat(deliveryCaptor.getValue().getSubscriptionId()).isEqualTo(subscriptionId);
  }

  private SubscriptionEntity activeSubscription(UUID id, UUID userId) {
    SubscriptionEntity s = new SubscriptionEntity();
    s.setId(id);
    s.setUserId(userId);
    s.setVendorId(UUID.randomUUID());
    s.setPlanType("DAILY");
    s.setStatus("ACTIVE");
    s.setDeliveryAddressId(UUID.randomUUID());
    s.setCurrency("USD");
    s.setNextDeliveryAt(OffsetDateTime.now().plusDays(1));
    s.setCreatedAt(OffsetDateTime.now());
    s.setUpdatedAt(OffsetDateTime.now());
    return s;
  }
}
