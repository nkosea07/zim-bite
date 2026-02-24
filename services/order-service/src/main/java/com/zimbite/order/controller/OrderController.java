package com.zimbite.order.controller;

import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.OrderStatusResponse;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.order.service.OrderService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

  private final OrderService orderService;

  public OrderController(OrderService orderService) {
    this.orderService = orderService;
  }

  @PostMapping
  public ResponseEntity<OrderResponse> placeOrder(@Valid @RequestBody PlaceOrderRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(orderService.placeOrder(request));
  }

  @PostMapping("/corporate")
  public ResponseEntity<OrderResponse> placeCorporateOrder(@Valid @RequestBody PlaceOrderRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(orderService.placeOrder(request));
  }

  @GetMapping
  public ResponseEntity<List<OrderResponse>> listOrders(@RequestParam(required = false) UUID userId) {
    return ResponseEntity.ok(orderService.listOrders(userId));
  }

  @GetMapping("/{orderId}")
  public ResponseEntity<OrderResponse> getOrder(@PathVariable UUID orderId) {
    OrderResponse response = orderService.getOrder(orderId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PostMapping("/{orderId}/cancel")
  public ResponseEntity<OrderResponse> cancelOrder(@PathVariable UUID orderId) {
    OrderResponse response = orderService.cancelOrder(orderId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @GetMapping("/{orderId}/status")
  public ResponseEntity<OrderStatusResponse> getOrderStatus(@PathVariable UUID orderId) {
    OrderStatusResponse response = orderService.getOrderStatus(orderId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }
}
