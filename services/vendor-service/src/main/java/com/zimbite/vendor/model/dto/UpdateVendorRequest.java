package com.zimbite.vendor.model.dto;

public record UpdateVendorRequest(
    String name,
    String city,
    Double latitude,
    Double longitude,
    Boolean open
) {
}
