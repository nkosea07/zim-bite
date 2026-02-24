package com.zimbite.delivery.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventConsumer.class);

    private final ObjectMapper objectMapper;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final Set<UUID> assignedOrders = ConcurrentHashMap.newKeySet();

    public PaymentEventConsumer(ObjectMapper objectMapper, KafkaTemplate<String, String> kafkaTemplate) {
        this.objectMapper = objectMapper;
        this.kafkaTemplate = kafkaTemplate;
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "delivery-service")
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            if (!assignedOrders.add(event.orderId())) {
                log.info("Ignoring duplicate payment.succeeded for orderId={} in delivery assignment", event.orderId());
                return;
            }
            log.info("Received payment.succeeded: orderId={}, triggering delivery assignment", event.orderId());
            DeliveryAssignedEvent assignedEvent = new DeliveryAssignedEvent(
                UUID.nameUUIDFromBytes(("delivery-" + event.orderId()).getBytes(StandardCharsets.UTF_8)),
                event.orderId(),
                UUID.nameUUIDFromBytes(("rider-" + event.orderId()).getBytes(StandardCharsets.UTF_8)),
                OffsetDateTime.now()
            );
            String assignedPayload = objectMapper.writeValueAsString(assignedEvent);
            kafkaTemplate.send(Topics.DELIVERY_ASSIGNED, event.orderId().toString(), assignedPayload).join();
            log.info("Published delivery.assigned: orderId={}, deliveryId={}, riderId={}",
                assignedEvent.orderId(), assignedEvent.deliveryId(), assignedEvent.riderId());
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        } catch (RuntimeException e) {
            log.error("Failed to assign delivery for payment.succeeded event", e);
        }
    }
}
