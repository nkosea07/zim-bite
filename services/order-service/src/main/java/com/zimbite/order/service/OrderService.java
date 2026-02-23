package com.zimbite.order.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.order.model.entity.OrderEntity;
import com.zimbite.order.model.entity.OrderItemEntity;
import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.repository.OrderItemRepository;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import com.zimbite.order.repository.OrderRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

  private static final BigDecimal BASE_UNIT_PRICE = BigDecimal.valueOf(5);

  private final OrderRepository orderRepository;
  private final OrderItemRepository orderItemRepository;
  private final OrderOutboxEventRepository outboxEventRepository;
  private final ObjectMapper objectMapper;

  public OrderService(
      OrderRepository orderRepository,
      OrderItemRepository orderItemRepository,
      OrderOutboxEventRepository outboxEventRepository,
      ObjectMapper objectMapper
  ) {
    this.orderRepository = orderRepository;
    this.orderItemRepository = orderItemRepository;
    this.outboxEventRepository = outboxEventRepository;
    this.objectMapper = objectMapper;
  }

  @Transactional
  public OrderResponse placeOrder(PlaceOrderRequest request) {
    UUID orderId = UUID.randomUUID();
    BigDecimal total = BASE_UNIT_PRICE.multiply(BigDecimal.valueOf(request.items().stream().mapToInt(i -> i.quantity()).sum()));

    OrderEntity order = new OrderEntity();
    order.setId(orderId);
    order.setUserId(request.userId());
    order.setVendorId(request.vendorId());
    order.setStatus("PENDING_PAYMENT");
    order.setTotalAmount(total);
    order.setCurrency(request.currency());
    order.setCreatedAt(OffsetDateTime.now());
    orderRepository.save(order);

    request.items().forEach(i -> {
      OrderItemEntity item = new OrderItemEntity();
      item.setId(UUID.randomUUID());
      item.setOrderId(orderId);
      item.setMenuItemId(i.menuItemId());
      item.setQuantity(i.quantity());
      item.setUnitPrice(BASE_UNIT_PRICE);
      item.setCreatedAt(OffsetDateTime.now());
      orderItemRepository.save(item);
    });

    OrderCreatedEvent event = new OrderCreatedEvent(
        orderId,
        request.userId(),
        request.vendorId(),
        total,
        request.currency(),
        OffsetDateTime.now()
    );
    saveOutbox(orderId, Topics.ORDER_CREATED, event);

    return new OrderResponse(order.getId(), order.getStatus(), order.getTotalAmount(), order.getCurrency());
  }

  @Transactional
  public OrderResponse getOrder(UUID orderId) {
    return orderRepository.findById(orderId)
        .map(o -> new OrderResponse(o.getId(), o.getStatus(), o.getTotalAmount(), o.getCurrency()))
        .orElse(null);
  }

  private void saveOutbox(UUID aggregateId, String eventType, Object payload) {
    OrderOutboxEventEntity outbox = new OrderOutboxEventEntity();
    outbox.setId(UUID.randomUUID());
    outbox.setAggregateId(aggregateId);
    outbox.setEventType(eventType);
    outbox.setPayload(serialize(payload));
    outbox.setPublished(false);
    outbox.setCreatedAt(OffsetDateTime.now());
    outboxEventRepository.save(outbox);
  }

  private String serialize(Object payload) {
    try {
      return objectMapper.writeValueAsString(payload);
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize order event payload", e);
    }
  }
}
