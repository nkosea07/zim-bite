package com.zimbite.vendor.model.dto;

import java.util.UUID;

public record VendorResponse(
    UUID id,
    String name,
    String city,
    Double latitude,
    Double longitude,
    boolean open
) {
}
