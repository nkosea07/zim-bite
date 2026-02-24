package com.zimbite.notification.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.notification.service.NotificationQueryService;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.OrderStatusChangedEvent;
import com.zimbite.shared.messaging.contract.PaymentFailedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrderEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrderEventConsumer.class);

    private final ObjectMapper objectMapper;
    private final NotificationQueryService notificationService;

    public OrderEventConsumer(ObjectMapper objectMapper, NotificationQueryService notificationService) {
        this.objectMapper = objectMapper;
        this.notificationService = notificationService;
    }

    @KafkaListener(topics = Topics.ORDER_CREATED, groupId = "notification-service")
    public void onOrderCreated(String payload) {
        try {
            OrderCreatedEvent event = objectMapper.readValue(payload, OrderCreatedEvent.class);
            log.info("Notifying user {} of new order {}", event.userId(), event.orderId());
            notificationService.createNotification(
                    event.userId(),
                    "ORDER_CONFIRMATION",
                    String.format("Your order %s has been placed. Total: %s %s",
                            event.orderId(), event.totalAmount(), event.currency()));
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.created event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "notification-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Notifying payment success for order {}", event.orderId());
            // PaymentSucceededEvent does not carry userId; notification will be linked when userId is available via order lookup
            log.info("Dispatching PAYMENT_SUCCESS notification: orderId={}, paymentId={}", event.orderId(), event.paymentId());
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "notification-service")
    public void onDeliveryAssigned(String payload) {
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);
            log.info("Delivery assigned for order {}, rider {}", event.orderId(), event.riderId());
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.assigned event", e);
        }
    }

    @KafkaListener(topics = Topics.ORDER_STATUS_CHANGED, groupId = "notification-service")
    public void onOrderStatusChanged(String payload) {
        try {
            OrderStatusChangedEvent event = objectMapper.readValue(payload, OrderStatusChangedEvent.class);
            log.info("Notifying status transition for order {}: {} -> {}",
                    event.orderId(), event.previousStatus(), event.newStatus());
            notificationService.createNotification(
                    event.userId(),
                    "ORDER_STATUS_CHANGED",
                    String.format("Your order status changed from %s to %s.",
                            event.previousStatus(), event.newStatus()));
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.status.changed event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_FAILED, groupId = "notification-service")
    public void onPaymentFailed(String payload) {
        try {
            PaymentFailedEvent event = objectMapper.readValue(payload, PaymentFailedEvent.class);
            log.info("Payment failure for order {} with reason={}", event.orderId(), event.reason());
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.failed event", e);
        }
    }
}
