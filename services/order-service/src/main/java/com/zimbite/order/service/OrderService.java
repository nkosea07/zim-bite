package com.zimbite.order.service;

import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

  private final Map<UUID, OrderResponse> orders = new ConcurrentHashMap<>();
  private final Map<UUID, OrderCreatedEvent> outbox = new ConcurrentHashMap<>();

  public OrderResponse placeOrder(PlaceOrderRequest request) {
    UUID orderId = UUID.randomUUID();
    BigDecimal total = BigDecimal.valueOf(request.items().stream().mapToInt(i -> i.quantity()).sum()).multiply(BigDecimal.valueOf(5));

    OrderResponse response = new OrderResponse(orderId, "PENDING_PAYMENT", total, request.currency());
    orders.put(orderId, response);

    outbox.put(orderId, new OrderCreatedEvent(
        orderId,
        request.userId(),
        request.vendorId(),
        total,
        request.currency(),
        OffsetDateTime.now()
    ));

    return response;
  }

  public OrderResponse getOrder(UUID orderId) {
    return orders.get(orderId);
  }
}
