package com.zimbite.delivery.model.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record RiderDeliveryResponse(
    UUID id,
    UUID orderId,
    String vendorName,
    String pickupAddress,
    String deliveryAddress,
    BigDecimal pickupLat,
    BigDecimal pickupLng,
    BigDecimal dropoffLat,
    BigDecimal dropoffLng,
    BigDecimal totalAmount,
    String status,
    UUID customerId,
    String customerPhone
) {}
