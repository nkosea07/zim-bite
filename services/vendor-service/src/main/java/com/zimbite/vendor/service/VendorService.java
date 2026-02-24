package com.zimbite.vendor.service;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.UpdateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import com.zimbite.vendor.model.dto.VendorStatsResponse;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class VendorService {

  private static final double EARTH_RADIUS_KM = 6371.0;

  private final Map<UUID, VendorRecord> vendors = new ConcurrentHashMap<>();

  public VendorService() {
    UUID firstId = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001");
    UUID secondId = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002");
    vendors.put(firstId, new VendorRecord(firstId, "Sunrise Kitchen", "Harare", -17.8292, 31.0522, true));
    vendors.put(secondId, new VendorRecord(secondId, "Morning Plate", "Harare", -17.8016, 31.0447, true));
  }

  public List<VendorResponse> list(Double lat, Double lng, Double radiusKm) {
    if (lat == null || lng == null) {
      return vendors.values().stream().map(this::toResponse).toList();
    }

    double effectiveRadiusKm = radiusKm == null ? 5.0 : Math.max(radiusKm, 0.1);
    return vendors.values().stream()
        .filter(v -> haversineKm(lat, lng, v.latitude(), v.longitude()) <= effectiveRadiusKm)
        .map(this::toResponse)
        .toList();
  }

  public VendorResponse create(CreateVendorRequest request) {
    UUID vendorId = UUID.randomUUID();
    VendorRecord record = new VendorRecord(
        vendorId,
        request.name().trim(),
        request.city().trim(),
        request.latitude(),
        request.longitude(),
        request.open() == null || request.open()
    );
    vendors.put(vendorId, record);
    return toResponse(record);
  }

  public VendorResponse get(UUID vendorId) {
    VendorRecord record = vendors.get(vendorId);
    if (record == null) {
      return null;
    }
    return toResponse(record);
  }

  public VendorResponse update(UUID vendorId, UpdateVendorRequest request) {
    VendorRecord record = vendors.get(vendorId);
    if (record == null) {
      return null;
    }

    VendorRecord updated = new VendorRecord(
        vendorId,
        request.name() == null || request.name().isBlank() ? record.name() : request.name().trim(),
        request.city() == null || request.city().isBlank() ? record.city() : request.city().trim(),
        request.latitude() == null ? record.latitude() : request.latitude(),
        request.longitude() == null ? record.longitude() : request.longitude(),
        request.open() == null ? record.open() : request.open()
    );
    vendors.put(vendorId, updated);
    return toResponse(updated);
  }

  public VendorStatsResponse stats(UUID vendorId) {
    VendorRecord vendor = vendors.get(vendorId);
    if (vendor == null) {
      return null;
    }

    int seed = Math.abs(vendorId.hashCode());
    int totalOrders = 30 + (seed % 120);
    BigDecimal revenue = BigDecimal.valueOf(150 + (seed % 1000)).setScale(2, RoundingMode.HALF_UP);
    double rating = 3.5 + ((seed % 15) / 10.0);

    return new VendorStatsResponse(vendorId, totalOrders, revenue, "USD", Math.min(5.0, rating));
  }

  private VendorResponse toResponse(VendorRecord record) {
    return new VendorResponse(
        record.id(),
        record.name(),
        record.city(),
        record.latitude(),
        record.longitude(),
        record.open()
    );
  }

  private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
    double dLat = Math.toRadians(lat2 - lat1);
    double dLon = Math.toRadians(lon2 - lon1);
    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
        + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
        * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(a));
  }

  private record VendorRecord(
      UUID id,
      String name,
      String city,
      double latitude,
      double longitude,
      boolean open
  ) {
  }
}
