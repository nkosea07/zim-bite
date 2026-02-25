package com.zimbite.subscription.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.subscription.model.dto.CreateSubscriptionRequest;
import com.zimbite.subscription.model.dto.SubscriptionDeliveryResponse;
import com.zimbite.subscription.model.dto.SubscriptionResponse;
import com.zimbite.subscription.model.entity.SubscriptionDeliveryEntity;
import com.zimbite.subscription.model.entity.SubscriptionEntity;
import com.zimbite.subscription.model.entity.SubscriptionItemEntity;
import com.zimbite.subscription.repository.SubscriptionDeliveryRepository;
import com.zimbite.subscription.repository.SubscriptionItemRepository;
import com.zimbite.subscription.repository.SubscriptionRepository;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SubscriptionService {

  private static final Logger log = LoggerFactory.getLogger(SubscriptionService.class);

  private final SubscriptionRepository subscriptionRepository;
  private final SubscriptionItemRepository subscriptionItemRepository;
  private final SubscriptionDeliveryRepository subscriptionDeliveryRepository;
  private final KafkaTemplate<String, String> kafkaTemplate;
  private final ObjectMapper objectMapper;

  public SubscriptionService(
      SubscriptionRepository subscriptionRepository,
      SubscriptionItemRepository subscriptionItemRepository,
      SubscriptionDeliveryRepository subscriptionDeliveryRepository,
      KafkaTemplate<String, String> kafkaTemplate,
      ObjectMapper objectMapper
  ) {
    this.subscriptionRepository = subscriptionRepository;
    this.subscriptionItemRepository = subscriptionItemRepository;
    this.subscriptionDeliveryRepository = subscriptionDeliveryRepository;
    this.kafkaTemplate = kafkaTemplate;
    this.objectMapper = objectMapper;
  }

  @Transactional
  public SubscriptionResponse createSubscription(UUID userId, CreateSubscriptionRequest request) {
    OffsetDateTime now = OffsetDateTime.now();
    UUID subscriptionId = UUID.randomUUID();

    SubscriptionEntity subscription = new SubscriptionEntity();
    subscription.setId(subscriptionId);
    subscription.setUserId(userId);
    subscription.setVendorId(request.vendorId());
    subscription.setPlanType(request.planType().toUpperCase(Locale.ROOT));
    subscription.setStatus("ACTIVE");
    subscription.setDeliveryAddressId(request.deliveryAddressId());
    subscription.setCurrency(request.currency().toUpperCase(Locale.ROOT));
    subscription.setPresetName(request.presetName());
    subscription.setNotes(request.notes());
    subscription.setNextDeliveryAt(nextDeliveryTime(request.planType(), now));
    subscription.setCreatedAt(now);
    subscription.setUpdatedAt(now);
    subscriptionRepository.save(subscription);

    List<SubscriptionItemEntity> items = request.items().stream().map(i -> {
      SubscriptionItemEntity item = new SubscriptionItemEntity();
      item.setId(UUID.randomUUID());
      item.setSubscriptionId(subscriptionId);
      item.setMenuItemId(i.menuItemId());
      item.setQuantity((short) i.quantity().intValue());
      item.setCreatedAt(now);
      return item;
    }).toList();
    subscriptionItemRepository.saveAll(items);

    publishEvent(Topics.SUBSCRIPTION_CREATED, subscriptionId.toString(),
        Map.of("subscriptionId", subscriptionId, "userId", userId, "planType", subscription.getPlanType()));

    log.info("Subscription created: subscriptionId={}, userId={}, plan={}", subscriptionId, userId, subscription.getPlanType());
    return toResponse(subscription, items);
  }

  public List<SubscriptionResponse> listSubscriptions(UUID userId) {
    return subscriptionRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(s -> toResponse(s, subscriptionItemRepository.findBySubscriptionId(s.getId())))
        .toList();
  }

  public SubscriptionResponse getSubscription(UUID subscriptionId, UUID userId) {
    SubscriptionEntity subscription = findAndVerifyOwner(subscriptionId, userId);
    return toResponse(subscription, subscriptionItemRepository.findBySubscriptionId(subscriptionId));
  }

  @Transactional
  public SubscriptionResponse pauseSubscription(UUID subscriptionId, UUID userId) {
    SubscriptionEntity subscription = findAndVerifyOwner(subscriptionId, userId);
    if (!"ACTIVE".equals(subscription.getStatus())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Only ACTIVE subscriptions can be paused");
    }
    OffsetDateTime now = OffsetDateTime.now();
    subscription.setStatus("PAUSED");
    subscription.setPausedAt(now);
    subscription.setUpdatedAt(now);
    subscriptionRepository.save(subscription);

    publishEvent(Topics.SUBSCRIPTION_PAUSED, subscriptionId.toString(),
        Map.of("subscriptionId", subscriptionId, "userId", userId));

    log.info("Subscription paused: subscriptionId={}", subscriptionId);
    return toResponse(subscription, subscriptionItemRepository.findBySubscriptionId(subscriptionId));
  }

  @Transactional
  public SubscriptionResponse resumeSubscription(UUID subscriptionId, UUID userId) {
    SubscriptionEntity subscription = findAndVerifyOwner(subscriptionId, userId);
    if (!"PAUSED".equals(subscription.getStatus())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Only PAUSED subscriptions can be resumed");
    }
    OffsetDateTime now = OffsetDateTime.now();
    subscription.setStatus("ACTIVE");
    subscription.setPausedAt(null);
    subscription.setNextDeliveryAt(nextDeliveryTime(subscription.getPlanType(), now));
    subscription.setUpdatedAt(now);
    subscriptionRepository.save(subscription);

    log.info("Subscription resumed: subscriptionId={}", subscriptionId);
    return toResponse(subscription, subscriptionItemRepository.findBySubscriptionId(subscriptionId));
  }

  @Transactional
  public SubscriptionResponse cancelSubscription(UUID subscriptionId, UUID userId) {
    SubscriptionEntity subscription = findAndVerifyOwner(subscriptionId, userId);
    if ("CANCELLED".equals(subscription.getStatus())) {
      return toResponse(subscription, subscriptionItemRepository.findBySubscriptionId(subscriptionId));
    }
    OffsetDateTime now = OffsetDateTime.now();
    subscription.setStatus("CANCELLED");
    subscription.setCancelledAt(now);
    subscription.setUpdatedAt(now);
    subscriptionRepository.save(subscription);

    publishEvent(Topics.SUBSCRIPTION_CANCELLED, subscriptionId.toString(),
        Map.of("subscriptionId", subscriptionId, "userId", userId));

    log.info("Subscription cancelled: subscriptionId={}", subscriptionId);
    return toResponse(subscription, subscriptionItemRepository.findBySubscriptionId(subscriptionId));
  }

  public List<SubscriptionDeliveryResponse> listDeliveries(UUID subscriptionId, UUID userId) {
    findAndVerifyOwner(subscriptionId, userId);
    return subscriptionDeliveryRepository.findBySubscriptionIdOrderByScheduledForDesc(subscriptionId)
        .stream().map(this::toDeliveryResponse).toList();
  }

  @Scheduled(fixedDelayString = "${subscription.scheduler.interval-ms:60000}")
  @Transactional
  public void dispatchDueDeliveries() {
    OffsetDateTime now = OffsetDateTime.now();
    List<SubscriptionEntity> due = subscriptionRepository.findByStatusAndNextDeliveryAtBefore("ACTIVE", now);
    if (due.isEmpty()) {
      return;
    }
    log.info("Dispatching {} due subscription deliveries", due.size());
    for (SubscriptionEntity subscription : due) {
      try {
        scheduleDelivery(subscription, now);
        subscription.setNextDeliveryAt(nextDeliveryTime(subscription.getPlanType(), now));
        subscription.setUpdatedAt(now);
        subscriptionRepository.save(subscription);
      } catch (Exception e) {
        log.error("Failed to dispatch delivery for subscriptionId={}: {}", subscription.getId(), e.getMessage());
        recordFailedDelivery(subscription.getId(), subscription.getNextDeliveryAt(), e.getMessage());
      }
    }
  }

  private void scheduleDelivery(SubscriptionEntity subscription, OffsetDateTime now) {
    SubscriptionDeliveryEntity delivery = new SubscriptionDeliveryEntity();
    delivery.setId(UUID.randomUUID());
    delivery.setSubscriptionId(subscription.getId());
    delivery.setScheduledFor(subscription.getNextDeliveryAt());
    delivery.setStatus("PENDING");
    delivery.setCreatedAt(now);
    subscriptionDeliveryRepository.save(delivery);

    publishEvent(Topics.SUBSCRIPTION_DELIVERY_DUE, subscription.getId().toString(),
        Map.of(
            "subscriptionId", subscription.getId(),
            "deliveryId", delivery.getId(),
            "userId", subscription.getUserId(),
            "vendorId", subscription.getVendorId(),
            "deliveryAddressId", subscription.getDeliveryAddressId(),
            "currency", subscription.getCurrency()
        ));
    log.info("Subscription delivery dispatched: subscriptionId={}, deliveryId={}", subscription.getId(), delivery.getId());
  }

  private void recordFailedDelivery(UUID subscriptionId, OffsetDateTime scheduledFor, String reason) {
    SubscriptionDeliveryEntity delivery = new SubscriptionDeliveryEntity();
    delivery.setId(UUID.randomUUID());
    delivery.setSubscriptionId(subscriptionId);
    delivery.setScheduledFor(scheduledFor);
    delivery.setStatus("FAILED");
    delivery.setFailureReason(reason);
    delivery.setCreatedAt(OffsetDateTime.now());
    subscriptionDeliveryRepository.save(delivery);
  }

  private SubscriptionEntity findAndVerifyOwner(UUID subscriptionId, UUID userId) {
    SubscriptionEntity subscription = subscriptionRepository.findById(subscriptionId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subscription not found"));
    if (!subscription.getUserId().equals(userId)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
    }
    return subscription;
  }

  private OffsetDateTime nextDeliveryTime(String planType, OffsetDateTime from) {
    OffsetDateTime base = from.withHour(7).withMinute(0).withSecond(0).withNano(0);
    if (base.isBefore(from)) {
      base = base.plusDays(1);
    }
    return switch (planType.toUpperCase(Locale.ROOT)) {
      case "WEEKLY" -> base.plusWeeks(1);
      case "MONTHLY" -> base.plusMonths(1);
      default -> base.plusDays(1);
    };
  }

  private void publishEvent(String topic, String key, Object payload) {
    try {
      kafkaTemplate.send(topic, key, objectMapper.writeValueAsString(payload));
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize event for topic " + topic, e);
    }
  }

  private SubscriptionResponse toResponse(SubscriptionEntity s, List<SubscriptionItemEntity> items) {
    return new SubscriptionResponse(
        s.getId(), s.getUserId(), s.getVendorId(), s.getPlanType(), s.getStatus(),
        s.getDeliveryAddressId(), s.getCurrency(), s.getPresetName(), s.getNotes(),
        s.getNextDeliveryAt(),
        items.stream().map(i -> new SubscriptionResponse.SubscriptionItemResponse(i.getMenuItemId(), i.getQuantity())).toList(),
        s.getCreatedAt()
    );
  }

  private SubscriptionDeliveryResponse toDeliveryResponse(SubscriptionDeliveryEntity d) {
    return new SubscriptionDeliveryResponse(
        d.getId(), d.getSubscriptionId(), d.getOrderId(),
        d.getScheduledFor(), d.getStatus(), d.getFailureReason(), d.getCreatedAt()
    );
  }
}
