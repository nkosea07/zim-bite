package com.zimbite.notification.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
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

    public OrderEventConsumer(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @KafkaListener(topics = Topics.ORDER_CREATED, groupId = "notification-service")
    public void onOrderCreated(String payload) {
        try {
            OrderCreatedEvent event = objectMapper.readValue(payload, OrderCreatedEvent.class);
            log.info("Notifying user {} of new order {}", event.userId(), event.orderId());
            sendOrderConfirmation(event);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.created event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "notification-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Notifying payment success for order {}", event.orderId());
            sendPaymentConfirmation(event);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "notification-service")
    public void onDeliveryAssigned(String payload) {
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);
            log.info("Notifying delivery assigned for order {}, rider {}", event.orderId(), event.riderId());
            sendRiderAssignmentNotification(event);
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
            sendOrderStatusUpdate(event);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.status.changed event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_FAILED, groupId = "notification-service")
    public void onPaymentFailed(String payload) {
        try {
            PaymentFailedEvent event = objectMapper.readValue(payload, PaymentFailedEvent.class);
            log.info("Notifying payment failure for order {} with reason={}", event.orderId(), event.reason());
            sendPaymentFailure(event);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.failed event", e);
        }
    }

    private void sendOrderConfirmation(OrderCreatedEvent event) {
        log.info(
            "Dispatching ORDER_CONFIRMATION notification: userId={}, orderId={}, amount={} {} via channels=[PUSH,SMS]",
            event.userId(),
            event.orderId(),
            event.totalAmount(),
            event.currency()
        );
    }

    private void sendPaymentConfirmation(PaymentSucceededEvent event) {
        log.info(
            "Dispatching PAYMENT_SUCCESS notification: orderId={}, paymentId={}, amount={} {}, provider={} via channels=[PUSH,SMS]",
            event.orderId(),
            event.paymentId(),
            event.amount(),
            event.currency(),
            event.provider()
        );
    }

    private void sendRiderAssignmentNotification(DeliveryAssignedEvent event) {
        log.info(
            "Dispatching DELIVERY_ASSIGNED notification: orderId={}, deliveryId={}, riderId={} via channels=[PUSH,SMS]",
            event.orderId(),
            event.deliveryId(),
            event.riderId()
        );
    }

    private void sendOrderStatusUpdate(OrderStatusChangedEvent event) {
        log.info(
            "Dispatching ORDER_STATUS_CHANGED notification: orderId={}, from={}, to={} via channels=[PUSH,SMS]",
            event.orderId(),
            event.previousStatus(),
            event.newStatus()
        );
    }

    private void sendPaymentFailure(PaymentFailedEvent event) {
        log.info(
            "Dispatching PAYMENT_FAILED notification: orderId={}, paymentId={}, reason={} via channels=[PUSH,SMS]",
            event.orderId(),
            event.paymentId(),
            event.reason()
        );
    }
}
