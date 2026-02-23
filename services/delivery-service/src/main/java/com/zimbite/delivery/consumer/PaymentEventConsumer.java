package com.zimbite.delivery.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventConsumer.class);

    private final ObjectMapper objectMapper;

    public PaymentEventConsumer(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "delivery-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Received payment.succeeded: orderId={}, triggering delivery assignment", event.orderId());
            // TODO: Assign a rider and publish delivery.assigned event
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }
}
