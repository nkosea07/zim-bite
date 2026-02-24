package com.zimbite.payment.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.service.PaymentService;

@Component
public class OrderEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrderEventConsumer.class);

    private final ObjectMapper objectMapper;
    private final PaymentService paymentService;
    private final String defaultProvider;

    public OrderEventConsumer(
        ObjectMapper objectMapper,
        PaymentService paymentService,
        @Value("${payment.auto-initiation.default-provider:ECOCASH}") String defaultProvider
    ) {
        this.objectMapper = objectMapper;
        this.paymentService = paymentService;
        this.defaultProvider = defaultProvider;
    }

    @KafkaListener(topics = Topics.ORDER_CREATED, groupId = "payment-service")
    public void onOrderCreated(String payload) {
        try {
            OrderCreatedEvent event = objectMapper.readValue(payload, OrderCreatedEvent.class);
            log.info("Received order.created: orderId={}, amount={} {}", event.orderId(), event.totalAmount(), event.currency());
            paymentService.initiate(
                new InitiatePaymentRequest(
                    event.orderId(),
                    defaultProvider,
                    event.totalAmount(),
                    event.currency()
                ),
                "order-created:" + event.orderId()
            );
            log.info("Auto-initiated payment for orderId={} via provider={}", event.orderId(), defaultProvider);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize order.created event", e);
        } catch (RuntimeException e) {
            log.error("Failed to auto-initiate payment from order.created event", e);
        }
    }
}
