package com.zimbite.order.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.anyCollection;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.order.model.dto.OrderItemRequest;
import com.zimbite.order.model.dto.OrderResponse;
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
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.ArgumentCaptor;

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

  @Mock
  private MenuItemPricingRepository menuItemPricingRepository;

  @Mock
  private VendorCoordinatesRepository vendorCoordinatesRepository;

  @Mock
  private UserAddressCoordinatesRepository userAddressCoordinatesRepository;

  @Mock
  private OrderInventoryService orderInventoryService;

  private OrderService orderService;

  @BeforeEach
  void setUp() {
    orderService = new OrderService(
        orderRepository,
        orderItemRepository,
        outboxEventRepository,
        orderStatusHistoryRepository,
        menuItemPricingRepository,
        vendorCoordinatesRepository,
        userAddressCoordinatesRepository,
        orderInventoryService,
        new ObjectMapper().findAndRegisterModules(),
        "Africa/Harare",
        5,
        10
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
    verify(orderInventoryService, times(1)).releaseReserved(orderId, "ORDER_CANCELLED");
  }

  @Test
  void cancelOrderReturnsNullWhenMissing() {
    UUID orderId = UUID.randomUUID();
    when(orderRepository.findById(orderId)).thenReturn(Optional.empty());

    OrderResponse response = orderService.cancelOrder(orderId);

    assertNull(response);
    verify(orderRepository, never()).save(any(OrderEntity.class));
  }

  @Test
  void placeOrderUsesMenuPricingSnapshotAndReservesInventory() {
    UUID userId = UUID.randomUUID();
    UUID vendorId = UUID.randomUUID();
    UUID addressId = UUID.randomUUID();
    UUID itemA = UUID.randomUUID();
    UUID itemB = UUID.randomUUID();
    PlaceOrderRequest request = new PlaceOrderRequest(
        userId,
        vendorId,
        addressId,
        "USD",
        List.of(
            new OrderItemRequest(itemA, 2),
            new OrderItemRequest(itemB, 1)
        ),
        null
    );

    MenuItemPricingEntity menuA = menuItem(itemA, vendorId, "USD", true, new BigDecimal("3.50"));
    MenuItemPricingEntity menuB = menuItem(itemB, vendorId, "USD", true, new BigDecimal("2.00"));
    VendorCoordinatesEntity vendorCoordinates = vendorCoordinates(vendorId, "-17.801234", "31.031234");
    UserAddressCoordinatesEntity addressCoordinates = userAddress(addressId, userId, -17.910987, 31.119876);

    when(vendorCoordinatesRepository.findById(Objects.requireNonNull(vendorId))).thenReturn(Optional.of(vendorCoordinates));
    when(userAddressCoordinatesRepository.findByIdAndUserId(addressId, userId))
        .thenReturn(Optional.of(addressCoordinates));
    when(menuItemPricingRepository.findByIdInAndVendorId(anyCollection(), eq(vendorId)))
        .thenReturn(List.of(menuA, menuB));
    when(orderRepository.save(any(OrderEntity.class))).thenAnswer(invocation -> invocation.<OrderEntity>getArgument(0));
    when(orderItemRepository.save(any(OrderItemEntity.class))).thenAnswer(invocation -> invocation.<OrderItemEntity>getArgument(0));
    when(outboxEventRepository.save(any(OrderOutboxEventEntity.class))).thenAnswer(invocation -> invocation.<OrderOutboxEventEntity>getArgument(0));
    when(orderStatusHistoryRepository.save(any(OrderStatusHistoryEntity.class))).thenAnswer(invocation -> invocation.<OrderStatusHistoryEntity>getArgument(0));

    OrderResponse response = orderService.placeOrder(request);

    assertEquals(new BigDecimal("9.00"), response.totalAmount());
    verify(orderInventoryService).reserveForOrder(response.orderId(), vendorId, request.items());

    ArgumentCaptor<OrderEntity> orderCaptor = ArgumentCaptor.forClass(OrderEntity.class);
    verify(orderRepository).save(orderCaptor.capture()); //NOSONAR: Mockito capture() is a side-effect placeholder
    OrderEntity savedOrder = orderCaptor.getValue();
    assertEquals(addressId, savedOrder.getDeliveryAddressId());
    assertEquals(new BigDecimal("-17.801234"), savedOrder.getPickupLat());
    assertEquals(new BigDecimal("31.031234"), savedOrder.getPickupLng());
    assertEquals(new BigDecimal("-17.910987"), savedOrder.getDropoffLat());
    assertEquals(new BigDecimal("31.119876"), savedOrder.getDropoffLng());

    ArgumentCaptor<OrderItemEntity> itemCaptor = ArgumentCaptor.forClass(OrderItemEntity.class);
    verify(orderItemRepository, times(2)).save(itemCaptor.capture()); //NOSONAR: Mockito capture() is a side-effect placeholder
    List<OrderItemEntity> savedItems = itemCaptor.getAllValues();
    assertEquals(new BigDecimal("3.50"), savedItems.get(0).getUnitPrice());
    assertEquals(new BigDecimal("2.00"), savedItems.get(1).getUnitPrice());
  }

  private MenuItemPricingEntity menuItem(
      UUID itemId,
      UUID vendorId,
      String currency,
      boolean available,
      BigDecimal price
  ) {
    MenuItemPricingEntity item = new MenuItemPricingEntity();
    item.setId(itemId);
    item.setVendorId(vendorId);
    item.setCurrency(currency);
    item.setAvailable(available);
    item.setBasePrice(price);
    return item;
  }

  private VendorCoordinatesEntity vendorCoordinates(UUID vendorId, String latitude, String longitude) {
    VendorCoordinatesEntity vendor = new VendorCoordinatesEntity();
    vendor.setId(vendorId);
    vendor.setLatitude(new BigDecimal(latitude));
    vendor.setLongitude(new BigDecimal(longitude));
    vendor.setActive(true);
    return vendor;
  }

  private UserAddressCoordinatesEntity userAddress(UUID addressId, UUID userId, double latitude, double longitude) {
    UserAddressCoordinatesEntity address = new UserAddressCoordinatesEntity();
    address.setId(addressId);
    address.setUserId(userId);
    address.setLatitude(latitude);
    address.setLongitude(longitude);
    return address;
  }
}
