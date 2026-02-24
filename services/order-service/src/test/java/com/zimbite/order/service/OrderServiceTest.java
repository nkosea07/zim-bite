package com.zimbite.order.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.entity.OrderEntity;
import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.model.entity.OrderStatusHistoryEntity;
import com.zimbite.order.repository.OrderItemRepository;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import com.zimbite.order.repository.OrderRepository;
import com.zimbite.order.repository.OrderStatusHistoryRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

  @Mock
  private OrderRepository orderRepository;

  @Mock
  private OrderItemRepository orderItemRepository;

  @Mock
  private OrderOutboxEventRepository outboxEventRepository;

  @Mock
  private OrderStatusHistoryRepository orderStatusHistoryRepository;

  private OrderService orderService;

  @BeforeEach
  void setUp() {
    orderService = new OrderService(
        orderRepository,
        orderItemRepository,
        outboxEventRepository,
        orderStatusHistoryRepository,
        new ObjectMapper().findAndRegisterModules()
    );
  }

  @Test
  void cancelOrderIsIdempotentForReplay() {
    UUID orderId = UUID.randomUUID();
    OrderEntity order = new OrderEntity();
    order.setId(orderId);
    order.setUserId(UUID.randomUUID());
    order.setVendorId(UUID.randomUUID());
    order.setStatus("PAID");
    order.setTotalAmount(new BigDecimal("15.00"));
    order.setCurrency("USD");
    order.setCreatedAt(OffsetDateTime.now());

    when(orderRepository.findById(orderId)).thenReturn(Optional.of(order));
    when(orderRepository.save(any(OrderEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(outboxEventRepository.save(any(OrderOutboxEventEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(orderStatusHistoryRepository.save(any(OrderStatusHistoryEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));

    OrderResponse first = orderService.cancelOrder(orderId);
    OrderResponse second = orderService.cancelOrder(orderId);

    assertEquals("CANCELLED", first.status());
    assertEquals("CANCELLED", second.status());
    verify(orderRepository, times(1)).save(any(OrderEntity.class));
    verify(outboxEventRepository, times(1)).save(any(OrderOutboxEventEntity.class));
    verify(orderStatusHistoryRepository, times(1)).save(any(OrderStatusHistoryEntity.class));
  }

  @Test
  void cancelOrderReturnsNullWhenMissing() {
    UUID orderId = UUID.randomUUID();
    when(orderRepository.findById(orderId)).thenReturn(Optional.empty());

    OrderResponse response = orderService.cancelOrder(orderId);

    assertNull(response);
    verify(orderRepository, never()).save(any(OrderEntity.class));
  }
}
