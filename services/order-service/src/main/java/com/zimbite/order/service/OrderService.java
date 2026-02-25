package com.zimbite.order.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.dto.OrderResponse;
import com.zimbite.order.model.dto.OrderStatusResponse;
import com.zimbite.order.model.dto.OrderStatusTimelineItemResponse;
import com.zimbite.order.model.dto.OrderItemRequest;
import com.zimbite.order.model.dto.PlaceOrderRequest;
import com.zimbite.order.model.entity.MenuItemPricingEntity;
import com.zimbite.order.model.entity.OrderEntity;
import com.zimbite.order.model.entity.OrderItemEntity;
import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.model.entity.OrderStatusHistoryEntity;
import com.zimbite.order.model.entity.UserAddressCoordinatesEntity;
import com.zimbite.order.model.entity.VendorCoordinatesEntity;
import com.zimbite.order.repository.MenuItemPricingRepository;
import com.zimbite.order.repository.OrderItemRepository;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import com.zimbite.order.repository.OrderRepository;
import com.zimbite.order.repository.OrderStatusHistoryRepository;
import com.zimbite.order.repository.UserAddressCoordinatesRepository;
import com.zimbite.order.repository.VendorCoordinatesRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.OrderStatusChangedEvent;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class OrderService {

  private final OrderRepository orderRepository;
  private final OrderItemRepository orderItemRepository;
  private final OrderOutboxEventRepository outboxEventRepository;
  private final OrderStatusHistoryRepository orderStatusHistoryRepository;
  private final MenuItemPricingRepository menuItemPricingRepository;
  private final VendorCoordinatesRepository vendorCoordinatesRepository;
  private final UserAddressCoordinatesRepository userAddressCoordinatesRepository;
  private final OrderInventoryService orderInventoryService;
  private final ObjectMapper objectMapper;
  private final ZoneId deliveryZone;
  private final int deliveryWindowOpenHour;
  private final int deliveryWindowCloseHour;

  public OrderService(
      OrderRepository orderRepository,
      OrderItemRepository orderItemRepository,
      OrderOutboxEventRepository outboxEventRepository,
      OrderStatusHistoryRepository orderStatusHistoryRepository,
      MenuItemPricingRepository menuItemPricingRepository,
      VendorCoordinatesRepository vendorCoordinatesRepository,
      UserAddressCoordinatesRepository userAddressCoordinatesRepository,
      OrderInventoryService orderInventoryService,
      ObjectMapper objectMapper,
      @Value("${order.delivery.timezone:Africa/Harare}") String deliveryTimezone,
      @Value("${order.delivery.window-open-hour:5}") int deliveryWindowOpenHour,
      @Value("${order.delivery.window-close-hour:10}") int deliveryWindowCloseHour
  ) {
    this.orderRepository = orderRepository;
    this.orderItemRepository = orderItemRepository;
    this.outboxEventRepository = outboxEventRepository;
    this.orderStatusHistoryRepository = orderStatusHistoryRepository;
    this.menuItemPricingRepository = menuItemPricingRepository;
    this.vendorCoordinatesRepository = vendorCoordinatesRepository;
    this.userAddressCoordinatesRepository = userAddressCoordinatesRepository;
    this.orderInventoryService = orderInventoryService;
    this.objectMapper = objectMapper;
    this.deliveryZone = ZoneId.of(deliveryTimezone);
    this.deliveryWindowOpenHour = deliveryWindowOpenHour;
    this.deliveryWindowCloseHour = deliveryWindowCloseHour;
  }

  @Transactional
  public OrderResponse placeOrder(PlaceOrderRequest request) {
    UUID orderId = UUID.randomUUID();
    String currency = normalizeCurrency(request.currency());
    OffsetDateTime scheduledFor = validateScheduledFor(request.scheduledFor());
    RouteCoordinates route = resolveRouteCoordinates(
        request.userId(),
        request.vendorId(),
        request.deliveryAddressId()
    );
    Map<UUID, MenuItemPricingEntity> pricingByItemId = loadMenuPricing(
        request.vendorId(),
        request.items(),
        currency
    );
    BigDecimal total = request.items().stream()
        .map(item -> pricingByItemId.get(item.menuItemId()).getBasePrice()
            .multiply(BigDecimal.valueOf(item.quantity())))
        .reduce(BigDecimal.ZERO, BigDecimal::add)
        .setScale(2, RoundingMode.HALF_UP);

    orderInventoryService.reserveForOrder(orderId, request.vendorId(), request.items());

    OrderEntity order = new OrderEntity();
    order.setId(orderId);
    order.setUserId(request.userId());
    order.setVendorId(request.vendorId());
    order.setDeliveryAddressId(request.deliveryAddressId());
    order.setStatus("PENDING_PAYMENT");
    order.setTotalAmount(total);
    order.setCurrency(currency);
    order.setPickupLat(route.pickupLat());
    order.setPickupLng(route.pickupLng());
    order.setDropoffLat(route.dropoffLat());
    order.setDropoffLng(route.dropoffLng());
    order.setScheduledFor(scheduledFor);
    order.setCreatedAt(OffsetDateTime.now());
    orderRepository.save(order);

    request.items().forEach(i -> {
      OrderItemEntity item = new OrderItemEntity();
      item.setId(UUID.randomUUID());
      item.setOrderId(orderId);
      item.setMenuItemId(i.menuItemId());
      item.setQuantity(i.quantity());
      item.setUnitPrice(pricingByItemId.get(i.menuItemId()).getBasePrice());
      item.setCreatedAt(OffsetDateTime.now());
      orderItemRepository.save(item);
    });

    OrderCreatedEvent event = new OrderCreatedEvent(
        orderId,
        request.userId(),
        request.vendorId(),
        total,
        currency,
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
    orderInventoryService.releaseReserved(saved.getId(), "ORDER_CANCELLED");

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
    return new OrderResponse(order.getId(), order.getStatus(), order.getTotalAmount(), order.getCurrency(), order.getScheduledFor());
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

  private String normalizeCurrency(String currency) {
    if (currency == null || currency.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "currency is required");
    }
    String normalized = currency.trim().toUpperCase(Locale.ROOT);
    if (!"USD".equals(normalized) && !"ZWL".equals(normalized)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported currency");
    }
    return normalized;
  }

  private Map<UUID, MenuItemPricingEntity> loadMenuPricing(
      UUID vendorId,
      List<OrderItemRequest> items,
      String currency
  ) {
    Collection<UUID> itemIds = items.stream().map(OrderItemRequest::menuItemId).distinct().toList();
    List<MenuItemPricingEntity> menuItems = menuItemPricingRepository.findByIdInAndVendorId(itemIds, vendorId);
    if (menuItems.size() != itemIds.size()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "One or more menu items are invalid for vendor");
    }

    for (MenuItemPricingEntity item : menuItems) {
      if (!item.isAvailable()) {
        throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "Menu item is unavailable: " + item.getId()
        );
      }
      if (!currency.equals(item.getCurrency().toUpperCase(Locale.ROOT))) {
        throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Currency mismatch for menu item: " + item.getId()
        );
      }
    }

    return menuItems.stream().collect(Collectors.toMap(MenuItemPricingEntity::getId, Function.identity()));
  }

  private RouteCoordinates resolveRouteCoordinates(UUID userId, UUID vendorId, UUID deliveryAddressId) {
    VendorCoordinatesEntity vendor = vendorCoordinatesRepository.findById(vendorId).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Vendor not found")
    );
    if (!vendor.isActive()) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Vendor is inactive");
    }
    if (vendor.getLatitude() == null || vendor.getLongitude() == null) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Vendor coordinates are missing");
    }

    UserAddressCoordinatesEntity address = userAddressCoordinatesRepository
        .findByIdAndUserId(deliveryAddressId, userId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Delivery address is invalid"));
    if (address.getLatitude() == null || address.getLongitude() == null) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Delivery address coordinates are missing");
    }

    return new RouteCoordinates(
        scaleCoordinate(vendor.getLatitude()),
        scaleCoordinate(vendor.getLongitude()),
        scaleCoordinate(BigDecimal.valueOf(address.getLatitude())),
        scaleCoordinate(BigDecimal.valueOf(address.getLongitude()))
    );
  }

  private BigDecimal scaleCoordinate(BigDecimal value) {
    return value.setScale(6, RoundingMode.HALF_UP);
  }

  private OffsetDateTime validateScheduledFor(OffsetDateTime scheduledFor) {
    if (scheduledFor == null) {
      return null;
    }
    OffsetDateTime now = OffsetDateTime.now();
    if (!scheduledFor.isAfter(now)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "scheduledFor must be in the future");
    }
    ZonedDateTime local = scheduledFor.atZoneSameInstant(deliveryZone);
    int hour = local.getHour();
    if (hour < deliveryWindowOpenHour || hour >= deliveryWindowCloseHour) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          String.format("scheduledFor must be within the %02d:00–%02d:00 %s delivery window",
              deliveryWindowOpenHour, deliveryWindowCloseHour, deliveryZone.getId())
      );
    }
    return scheduledFor;
  }

  private record RouteCoordinates(
      BigDecimal pickupLat,
      BigDecimal pickupLng,
      BigDecimal dropoffLat,
      BigDecimal dropoffLng
  ) {
  }
}
