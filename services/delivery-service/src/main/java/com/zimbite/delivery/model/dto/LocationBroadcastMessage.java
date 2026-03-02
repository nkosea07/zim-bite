package com.zimbite.delivery.model.dto;

import java.util.UUID;

public record LocationBroadcastMessage(
    UUID deliveryId,
    double lat,
    double lng,
    Double heading,
    Double speedKmh,
    long timestamp
) {}
