package com.zimbite.order.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.OrderStatusResponse;
import com.zimbite.order.model.dto.OrderStatusTimelineItemResponse;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.order.model.entity.OrderEntity;
import com.zimbite.order.model.entity.OrderItemEntity;
import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.model.entity.OrderStatusHistoryEntity;
import com.zimbite.order.repository.OrderItemRepository;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import com.zimbite.order.repository.OrderRepository;
import com.zimbite.order.repository.OrderStatusHistoryRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.OrderStatusChangedEvent;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

  private static final BigDecimal BASE_UNIT_PRICE = BigDecimal.valueOf(5);

  private final OrderRepository orderRepository;
  private final OrderItemRepository orderItemRepository;
  private final OrderOutboxEventRepository outboxEventRepository;
  private final OrderStatusHistoryRepository orderStatusHistoryRepository;
  private final ObjectMapper objectMapper;

  public OrderService(
      OrderRepository orderRepository,
      OrderItemRepository orderItemRepository,
      OrderOutboxEventRepository outboxEventRepository,
      OrderStatusHistoryRepository orderStatusHistoryRepository,
      ObjectMapper objectMapper
  ) {
    this.orderRepository = orderRepository;
    this.orderItemRepository = orderItemRepository;
    this.outboxEventRepository = outboxEventRepository;
    this.orderStatusHistoryRepository = orderStatusHistoryRepository;
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
    recordStatusHistory(orderId, "PENDING_PAYMENT", "SYSTEM", "Order created");

    return toOrderResponse(order);
  }

  @Transactional
  public List<OrderResponse> listOrders(UUID userId) {
    List<OrderEntity> orders = userId == null
        ? orderRepository.findAllByOrderByCreatedAtDesc()
        : orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    return orders.stream().map(this::toOrderResponse).toList();
  }

  @Transactional
  public OrderResponse getOrder(UUID orderId) {
    return orderRepository.findById(orderId)
        .map(this::toOrderResponse)
        .orElse(null);
  }

  @Transactional
  public OrderResponse cancelOrder(UUID orderId) {
    OrderEntity order = orderRepository.findById(orderId).orElse(null);
    if (order == null) {
      return null;
    }

    if ("CANCELLED".equals(order.getStatus()) || "DELIVERED".equals(order.getStatus())) {
      return toOrderResponse(order);
    }

    String previousStatus = order.getStatus();
    order.setStatus("CANCELLED");
    OrderEntity saved = orderRepository.save(order);

    OrderStatusChangedEvent event = new OrderStatusChangedEvent(
        saved.getId(),
        saved.getUserId(),
        previousStatus,
        saved.getStatus(),
        OffsetDateTime.now()
    );
    saveOutbox(saved.getId(), Topics.ORDER_STATUS_CHANGED, event);
    recordStatusHistory(saved.getId(), saved.getStatus(), "CUSTOMER", "Order cancelled by customer");

    return toOrderResponse(saved);
  }

  @Transactional
  public OrderStatusResponse getOrderStatus(UUID orderId) {
    return orderRepository.findById(orderId).map(order -> {
      List<OrderStatusTimelineItemResponse> timeline = orderStatusHistoryRepository
          .findByOrderIdOrderByCreatedAtDesc(orderId)
          .stream()
          .map(history -> new OrderStatusTimelineItemResponse(
              history.getStatus(),
              history.getSource(),
              history.getNote(),
              history.getCreatedAt()
          ))
          .toList();

      OffsetDateTime lastTransitionAt = timeline.isEmpty() ? order.getCreatedAt() : timeline.get(0).createdAt();
      return new OrderStatusResponse(order.getId(), order.getStatus(), lastTransitionAt, timeline);
    }).orElse(null);
  }

  private OrderResponse toOrderResponse(OrderEntity order) {
    return new OrderResponse(order.getId(), order.getStatus(), order.getTotalAmount(), order.getCurrency());
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

  private String serialize(Object payload) {
    try {
      return objectMapper.writeValueAsString(payload);
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize order event payload", e);
    }
  }
}
