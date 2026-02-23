package com.zimbite.payment.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
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

    @KafkaListener(topics = Topics.ORDER_CREATED, groupId = "payment-service")
    public void onOrderCreated(String payload) {
        try {
            OrderCreatedEvent event = objectMapper.readValue(payload, OrderCreatedEvent.class);
            log.info("Received order.created: orderId={}, amount={} {}", event.orderId(), event.totalAmount(), event.currency());
            // TODO: Auto-initiate payment for the order
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.created event", e);
        }
    }
}
