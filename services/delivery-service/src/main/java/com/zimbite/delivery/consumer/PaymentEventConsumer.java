package com.zimbite.delivery.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.service.DeliveryService;
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
    private final DeliveryService deliveryService;

    public PaymentEventConsumer(ObjectMapper objectMapper, DeliveryService deliveryService) {
        this.objectMapper = objectMapper;
        this.deliveryService = deliveryService;
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "delivery-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Received payment.succeeded: orderId={}, assigning delivery", event.orderId());
            deliveryService.assignDelivery(event.orderId());
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        } catch (RuntimeException e) {
            log.error("Failed to assign delivery for payment.succeeded event", e);
        }
    }
}
