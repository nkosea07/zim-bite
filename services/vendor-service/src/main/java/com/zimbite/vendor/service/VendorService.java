package com.zimbite.vendor.service;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.UpdateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import com.zimbite.vendor.model.dto.VendorStatsResponse;
import com.zimbite.vendor.model.entity.VendorEntity;
import com.zimbite.vendor.repository.VendorRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VendorService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    private final VendorRepository vendorRepository;

    public VendorService(VendorRepository vendorRepository) {
        this.vendorRepository = vendorRepository;
    }

    public List<VendorResponse> list(Double lat, Double lng, Double radiusKm) {
        List<VendorEntity> vendors = vendorRepository.findByActiveTrue();
        if (lat == null || lng == null) {
            return vendors.stream().map(this::toResponse).toList();
        }

        double effectiveRadiusKm = radiusKm == null ? 5.0 : Math.max(radiusKm, 0.1);
        return vendors.stream()
                .filter(v -> haversineKm(lat, lng,
                        v.getLatitude().doubleValue(),
                        v.getLongitude().doubleValue()) <= effectiveRadiusKm)
                .map(this::toResponse)
                .toList();
    }

    public VendorResponse getById(UUID vendorId) {
        return vendorRepository.findById(vendorId)
                .map(this::toResponse)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vendor not found"));
    }

    @Transactional
    public VendorResponse create(CreateVendorRequest request) {
        String slug = request.name().toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("^-|-$", "");
        if (vendorRepository.findBySlug(slug).isPresent()) {
            slug = slug + "-" + UUID.randomUUID().toString().substring(0, 6);
        }

        OffsetDateTime now = OffsetDateTime.now();
        VendorEntity vendor = new VendorEntity();
        vendor.setId(UUID.randomUUID());
        vendor.setOwnerUserId(request.ownerUserId());
        vendor.setName(request.name());
        vendor.setSlug(slug);
        vendor.setDescription(request.description());
        vendor.setPhoneNumber(request.phoneNumber());
        vendor.setSupportEmail(request.supportEmail());
        vendor.setLatitude(request.latitude());
        vendor.setLongitude(request.longitude());
        vendor.setAveragePrepMinutes((short) 20);
        vendor.setDeliveryRadiusKm(BigDecimal.valueOf(6));
        vendor.setMinOrderValue(BigDecimal.ZERO);
        vendor.setAcceptsCash(true);
        vendor.setActive(true);
        vendor.setRatingAvg(BigDecimal.ZERO);
        vendor.setCreatedAt(now);
        vendor.setUpdatedAt(now);

        return toResponse(vendorRepository.save(vendor));
    }

    @Transactional
    public VendorResponse update(UUID vendorId, UpdateVendorRequest request) {
        VendorEntity vendor = vendorRepository.findById(vendorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vendor not found"));

        if (request.name() != null) vendor.setName(request.name());
        if (request.description() != null) vendor.setDescription(request.description());
        if (request.phoneNumber() != null) vendor.setPhoneNumber(request.phoneNumber());
        if (request.supportEmail() != null) vendor.setSupportEmail(request.supportEmail());
        if (request.latitude() != null) vendor.setLatitude(request.latitude());
        if (request.longitude() != null) vendor.setLongitude(request.longitude());
        if (request.averagePrepMinutes() != null) vendor.setAveragePrepMinutes(request.averagePrepMinutes());
        if (request.deliveryRadiusKm() != null) vendor.setDeliveryRadiusKm(request.deliveryRadiusKm());
        if (request.minOrderValue() != null) vendor.setMinOrderValue(request.minOrderValue());
        if (request.acceptsCash() != null) vendor.setAcceptsCash(request.acceptsCash());
        if (request.active() != null) vendor.setActive(request.active());
        vendor.setUpdatedAt(OffsetDateTime.now());

        return toResponse(vendorRepository.save(vendor));
    }

    public VendorStatsResponse stats(UUID vendorId) {
        VendorEntity vendor = vendorRepository.findById(vendorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vendor not found"));

        int seed = Math.abs(vendorId.hashCode());
        int totalOrders = 30 + (seed % 120);
        BigDecimal revenue = BigDecimal.valueOf(150 + (seed % 1000)).setScale(2, RoundingMode.HALF_UP);
        double rating = 3.5 + ((seed % 15) / 10.0);

        return new VendorStatsResponse(vendorId, totalOrders, revenue, "USD", Math.min(5.0, rating));
    }

    private VendorResponse toResponse(VendorEntity v) {
        return new VendorResponse(
                v.getId(), v.getName(), v.getSlug(), v.getDescription(),
                v.getPhoneNumber(), v.getLatitude(), v.getLongitude(),
                v.getAveragePrepMinutes(), v.getDeliveryRadiusKm(),
                v.getMinOrderValue(), v.isAcceptsCash(), v.isActive(),
                v.getRatingAvg());
    }

    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(a));
    }
}
