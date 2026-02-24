package com.zimbite.order.service;

import com.zimbite.order.model.dto.OrderItemRequest;
import com.zimbite.order.model.entity.InventoryReservationEntity;
import com.zimbite.order.repository.InventoryRepository;
import com.zimbite.order.repository.InventoryReservationRepository;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class OrderInventoryService {

  private static final String RESERVED = "RESERVED";
  private static final String RELEASED = "RELEASED";
  private static final String COMMITTED = "COMMITTED";

  private final InventoryRepository inventoryRepository;
  private final InventoryReservationRepository reservationRepository;

  public OrderInventoryService(
      InventoryRepository inventoryRepository,
      InventoryReservationRepository reservationRepository
  ) {
    this.inventoryRepository = inventoryRepository;
    this.reservationRepository = reservationRepository;
  }

  @Transactional
  public void reserveForOrder(UUID orderId, UUID vendorId, List<OrderItemRequest> items) {
    OffsetDateTime now = OffsetDateTime.now();
    quantitiesByMenuItem(items).forEach((menuItemId, quantity) -> {
      int updated = inventoryRepository.reserve(vendorId, menuItemId, quantity);
      if (updated == 0) {
        throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "Insufficient inventory for menu item " + menuItemId
        );
      }

      InventoryReservationEntity reservation = new InventoryReservationEntity();
      reservation.setId(UUID.randomUUID());
      reservation.setOrderId(orderId);
      reservation.setVendorId(vendorId);
      reservation.setMenuItemId(menuItemId);
      reservation.setQuantity(quantity);
      reservation.setStatus(RESERVED);
      reservation.setReason("ORDER_PLACED");
      reservation.setCreatedAt(now);
      reservation.setUpdatedAt(now);
      reservationRepository.save(reservation);
    });
  }

  @Transactional
  public void releaseReserved(UUID orderId, String reason) {
    OffsetDateTime now = OffsetDateTime.now();
    reservationRepository.findByOrderIdAndStatus(orderId, RESERVED).forEach(reservation -> {
      inventoryRepository.release(
          reservation.getVendorId(),
          reservation.getMenuItemId(),
          reservation.getQuantity()
      );
      reservation.setStatus(RELEASED);
      reservation.setReason(reason);
      reservation.setUpdatedAt(now);
      reservationRepository.save(reservation);
    });
  }

  @Transactional
  public void commitReserved(UUID orderId, String reason) {
    OffsetDateTime now = OffsetDateTime.now();
    reservationRepository.findByOrderIdAndStatus(orderId, RESERVED).forEach(reservation -> {
      reservation.setStatus(COMMITTED);
      reservation.setReason(reason);
      reservation.setUpdatedAt(now);
      reservationRepository.save(reservation);
    });
  }

  private Map<UUID, Integer> quantitiesByMenuItem(List<OrderItemRequest> items) {
    Map<UUID, Integer> quantities = new LinkedHashMap<>();
    items.forEach(item -> quantities.merge(item.menuItemId(), item.quantity(), Integer::sum));
    return quantities;
  }
}
