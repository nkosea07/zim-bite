package com.zimbite.order.controller;

import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.OrderStatusResponse;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.order.service.OrderService;
import com.zimbite.shared.security.Role;
import com.zimbite.shared.security.SecurityHeaders;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
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
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

  private final OrderService orderService;

  public OrderController(OrderService orderService) {
    this.orderService = orderService;
  }

  @PostMapping
  public ResponseEntity<OrderResponse> placeOrder(
      HttpServletRequest servletRequest,
      @Valid @RequestBody PlaceOrderRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(orderService.placeOrder(sanitizeOrderRequest(currentUserId(servletRequest), request)));
  }

  @PostMapping("/corporate")
  public ResponseEntity<OrderResponse> placeCorporateOrder(
      HttpServletRequest servletRequest,
      @Valid @RequestBody PlaceOrderRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(orderService.placeOrder(sanitizeOrderRequest(currentUserId(servletRequest), request)));
  }

  @GetMapping
  public ResponseEntity<List<OrderResponse>> listOrders(
      HttpServletRequest servletRequest,
      @RequestParam(required = false) UUID userId
  ) {
    UUID currentUserId = currentUserId(servletRequest);
    boolean isSystemAdmin = Role.SYSTEM_ADMIN.name().equals(servletRequest.getHeader(SecurityHeaders.USER_ROLE));
    UUID effectiveUserId = resolveListUserId(currentUserId, userId, isSystemAdmin);
    return ResponseEntity.ok(orderService.listOrders(effectiveUserId));
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

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }

  private UUID resolveListUserId(UUID currentUserId, UUID requestedUserId, boolean isSystemAdmin) {
    if (requestedUserId == null) {
      return isSystemAdmin ? null : currentUserId;
    }
    if (!isSystemAdmin && !requestedUserId.equals(currentUserId)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cannot query orders for another user");
    }
    return requestedUserId;
  }

  private PlaceOrderRequest sanitizeOrderRequest(UUID userId, PlaceOrderRequest request) {
    return new PlaceOrderRequest(
        userId,
        request.vendorId(),
        request.deliveryAddressId(),
        request.currency(),
        request.items(),
        request.scheduledFor()
    );
  }
}
