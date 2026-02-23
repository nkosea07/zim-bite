package com.zimbite.notification.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
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
            // TODO: Send order confirmation notification (push/SMS)
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.created event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "notification-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Notifying payment success for order {}", event.orderId());
            // TODO: Send payment confirmation notification
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "notification-service")
    public void onDeliveryAssigned(String payload) {
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);
            log.info("Notifying delivery assigned for order {}, rider {}", event.orderId(), event.riderId());
            // TODO: Send rider assignment notification to customer
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.assigned event", e);
        }
    }
}
