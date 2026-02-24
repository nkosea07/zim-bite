package com.zimbite.notification.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.notification.model.entity.OrderRecipientEntity;
import com.zimbite.notification.repository.OrderRecipientRepository;
import com.zimbite.notification.service.NotificationQueryService;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.OrderStatusChangedEvent;
import com.zimbite.shared.messaging.contract.PaymentFailedEvent;
import com.zimbite.shared.messaging.contract.PaymentRefundedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrderEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrderEventConsumer.class);

    private final ObjectMapper objectMapper;
    private final NotificationQueryService notificationService;
    private final OrderRecipientRepository orderRecipientRepository;

    public OrderEventConsumer(
            ObjectMapper objectMapper,
            NotificationQueryService notificationService,
            OrderRecipientRepository orderRecipientRepository
    ) {
        this.objectMapper = objectMapper;
        this.notificationService = notificationService;
        this.orderRecipientRepository = orderRecipientRepository;
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
            createOrderScopedNotification(
                    event.orderId(),
                    "PAYMENT_SUCCESS",
                    String.format(
                            "Payment confirmed for order %s (%s %s) via %s.",
                            event.orderId(),
                            event.amount(),
                            event.currency(),
                            event.provider()
                    )
            );
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "notification-service")
    public void onDeliveryAssigned(String payload) {
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);
            log.info("Delivery assigned for order {}, rider {}", event.orderId(), event.riderId());
            createOrderScopedNotification(
                    event.orderId(),
                    "DELIVERY_ASSIGNED",
                    String.format(
                            "Delivery assigned for order %s. Rider %s is on the way.",
                            event.orderId(),
                            event.riderId()
                    )
            );
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.assigned event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_COMPLETED, groupId = "notification-service")
    public void onDeliveryCompleted(String payload) {
        try {
            DeliveryCompletedEvent event = objectMapper.readValue(payload, DeliveryCompletedEvent.class);
            log.info("Delivery completed for order {}, rider {}", event.orderId(), event.riderId());
            createOrderScopedNotification(
                    event.orderId(),
                    "DELIVERY_COMPLETED",
                    String.format("Order %s has been delivered successfully.", event.orderId())
            );
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.completed event", e);
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
            createOrderScopedNotification(
                    event.orderId(),
                    "PAYMENT_FAILED",
                    String.format(
                            "Payment failed for order %s. Reason: %s.",
                            event.orderId(),
                            event.reason()
                    )
            );
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.failed event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_REFUNDED, groupId = "notification-service")
    public void onPaymentRefunded(String payload) {
        try {
            PaymentRefundedEvent event = objectMapper.readValue(payload, PaymentRefundedEvent.class);
            log.info("Payment refunded for order {} with reason={}", event.orderId(), event.reason());
            createOrderScopedNotification(
                    event.orderId(),
                    "PAYMENT_REFUNDED",
                    String.format(
                            "Payment refunded for order %s (%s %s).",
                            event.orderId(),
                            event.amount(),
                            event.currency()
                    )
            );
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.refunded event", e);
        }
    }

    private void createOrderScopedNotification(UUID orderId, String type, String message) {
        OrderRecipientEntity recipient = orderRecipientRepository.findById(orderId).orElse(null);
        if (recipient == null) {
            log.warn("Skipping notification type={} because order {} was not found", type, orderId);
            return;
        }
        notificationService.createNotification(recipient.getUserId(), type, message);
    }
}
