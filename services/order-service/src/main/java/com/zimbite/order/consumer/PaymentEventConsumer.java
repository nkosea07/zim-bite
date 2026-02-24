package com.zimbite.order.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.model.entity.OrderStatusHistoryEntity;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import com.zimbite.order.repository.OrderRepository;
import com.zimbite.order.repository.OrderStatusHistoryRepository;
import com.zimbite.order.service.OrderInventoryService;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import com.zimbite.shared.messaging.contract.OrderStatusChangedEvent;
import com.zimbite.shared.messaging.contract.PaymentFailedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class PaymentEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventConsumer.class);

    private final OrderRepository orderRepository;
    private final OrderOutboxEventRepository outboxEventRepository;
    private final OrderStatusHistoryRepository orderStatusHistoryRepository;
    private final OrderInventoryService orderInventoryService;
    private final ObjectMapper objectMapper;

    public PaymentEventConsumer(OrderRepository orderRepository,
                                OrderOutboxEventRepository outboxEventRepository,
                                OrderStatusHistoryRepository orderStatusHistoryRepository,
                                OrderInventoryService orderInventoryService,
                                ObjectMapper objectMapper) {
        this.orderRepository = orderRepository;
        this.outboxEventRepository = outboxEventRepository;
        this.orderStatusHistoryRepository = orderStatusHistoryRepository;
        this.orderInventoryService = orderInventoryService;
        this.objectMapper = objectMapper;
    }

    @KafkaListener(topics = Topics.PAYMENT_SUCCEEDED, groupId = "order-service")
    @Transactional
    public void onPaymentSucceeded(String payload) {
        try {
            PaymentSucceededEvent event = objectMapper.readValue(payload, PaymentSucceededEvent.class);
            log.info("Received payment.succeeded: orderId={}", event.orderId());
            updateOrderStatus(event.orderId(), "PAID");
            orderInventoryService.commitReserved(event.orderId(), "PAYMENT_SUCCEEDED");
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.succeeded event", e);
        }
    }

    @KafkaListener(topics = Topics.PAYMENT_FAILED, groupId = "order-service")
    @Transactional
    public void onPaymentFailed(String payload) {
        try {
            PaymentFailedEvent event = objectMapper.readValue(payload, PaymentFailedEvent.class);
            log.info("Received payment.failed: orderId={}, reason={}", event.orderId(), event.reason());
            updateOrderStatus(event.orderId(), "PAYMENT_FAILED");
            orderInventoryService.releaseReserved(event.orderId(), "PAYMENT_FAILED");
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize payment.failed event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_ASSIGNED, groupId = "order-service")
    @Transactional
    public void onDeliveryAssigned(String payload) {
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);
            log.info("Received delivery.assigned: orderId={}, riderId={}", event.orderId(), event.riderId());
            updateOrderStatus(event.orderId(), "OUT_FOR_DELIVERY");
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.assigned event", e);
        }
    }

    @KafkaListener(topics = Topics.DELIVERY_COMPLETED, groupId = "order-service")
    @Transactional
    public void onDeliveryCompleted(String payload) {
        try {
            DeliveryCompletedEvent event = objectMapper.readValue(payload, DeliveryCompletedEvent.class);
            log.info("Received delivery.completed: orderId={}, deliveryId={}", event.orderId(), event.deliveryId());
            updateOrderStatus(event.orderId(), "DELIVERED");
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize delivery.completed event", e);
        }
    }

    private void updateOrderStatus(UUID orderId, String newStatus) {
        orderRepository.findById(orderId).ifPresent(order -> {
            String previousStatus = order.getStatus();
            if (newStatus.equals(previousStatus)) {
                log.info("Order {} already in status {}, skipping duplicate transition", orderId, newStatus);
                return;
            }

            order.setStatus(newStatus);
            orderRepository.save(order);

            OrderStatusChangedEvent statusEvent = new OrderStatusChangedEvent(
                    orderId, order.getUserId(), previousStatus, newStatus, OffsetDateTime.now());
            saveOutbox(orderId, Topics.ORDER_STATUS_CHANGED, statusEvent);
            recordStatusHistory(orderId, newStatus, "SYSTEM", "Asynchronous status transition");
            log.info("Order {} status updated: {} -> {}", orderId, previousStatus, newStatus);
        });
    }

    private void saveOutbox(UUID aggregateId, String eventType, Object event) {
        OrderOutboxEventEntity outbox = new OrderOutboxEventEntity();
        outbox.setId(UUID.randomUUID());
        outbox.setAggregateId(aggregateId);
        outbox.setEventType(eventType);
        outbox.setPayload(serialize(event));
        outbox.setPublished(false);
        outbox.setCreatedAt(OffsetDateTime.now());
        outboxEventRepository.save(outbox);
    }

    private String serialize(Object payload) {
        try {
            return objectMapper.writeValueAsString(payload);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize event payload", e);
        }
    }

    private void recordStatusHistory(UUID orderId, String status, String source, String note) {
        OrderStatusHistoryEntity history = new OrderStatusHistoryEntity();
        history.setId(UUID.randomUUID());
        history.setOrderId(orderId);
        history.setStatus(status);
        history.setSource(source);
        history.setNote(note);
        history.setCreatedAt(OffsetDateTime.now());
        orderStatusHistoryRepository.save(history);
    }
}
