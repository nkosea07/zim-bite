package com.zimbite.analytics.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.analytics.service.AnalyticsQueryService;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.PaymentRefundedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class AnalyticsEventConsumer {

  private static final Logger log = LoggerFactory.getLogger(AnalyticsEventConsumer.class);

  private final ObjectMapper objectMapper;
  private final AnalyticsQueryService analyticsQueryService;

  public AnalyticsEventConsumer(ObjectMapper objectMapper, AnalyticsQueryService analyticsQueryService) {
    this.objectMapper = objectMapper;
    this.analyticsQueryService = analyticsQueryService;
  }

  @KafkaListener(topics = Topics.ORDER_CREATED, groupId = "analytics-service")
  public void onOrderCreated(String payload) {
    try {
      analyticsQueryService.recordOrderCreated(objectMapper.readValue(payload, OrderCreatedEvent.class));
    } catch (JsonProcessingException e) {
      log.error("Failed to deserialize order.created event", e);
    }
  }

  @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "analytics-service")
  public void onPaymentSucceeded(String payload) {
    try {
      analyticsQueryService.recordPaymentSucceeded(objectMapper.readValue(payload, PaymentSucceededEvent.class));
    } catch (JsonProcessingException e) {
      log.error("Failed to deserialize payment.succeeded event", e);
    }
  }

  @KafkaListener(topics = Topics.PAYMENT_REFUNDED, groupId = "analytics-service")
  public void onPaymentRefunded(String payload) {
    try {
      analyticsQueryService.recordPaymentRefunded(objectMapper.readValue(payload, PaymentRefundedEvent.class));
    } catch (JsonProcessingException e) {
      log.error("Failed to deserialize payment.refunded event", e);
    }
  }

  @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "analytics-service")
  public void onDeliveryAssigned(String payload) {
    try {
      analyticsQueryService.recordDeliveryAssigned(objectMapper.readValue(payload, DeliveryAssignedEvent.class));
    } catch (JsonProcessingException e) {
      log.error("Failed to deserialize delivery.assigned event", e);
    }
  }

  @KafkaListener(topics = Topics.DELIVERY_COMPLETED, groupId = "analytics-service")
  public void onDeliveryCompleted(String payload) {
    try {
      analyticsQueryService.recordDeliveryCompleted(objectMapper.readValue(payload, DeliveryCompletedEvent.class));
    } catch (JsonProcessingException e) {
      log.error("Failed to deserialize delivery.completed event", e);
    }
  }
}
