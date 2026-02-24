package com.zimbite.vendor.service;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.UpdateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import com.zimbite.vendor.model.entity.VendorEntity;
import com.zimbite.vendor.repository.VendorRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VendorService {

    private final VendorRepository vendorRepository;

    public VendorService(VendorRepository vendorRepository) {
        this.vendorRepository = vendorRepository;
    }

    public List<VendorResponse> listActive() {
        return vendorRepository.findByActiveTrue().stream()
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

    private VendorResponse toResponse(VendorEntity v) {
        return new VendorResponse(
                v.getId(), v.getName(), v.getSlug(), v.getDescription(),
                v.getPhoneNumber(), v.getLatitude(), v.getLongitude(),
                v.getAveragePrepMinutes(), v.getDeliveryRadiusKm(),
                v.getMinOrderValue(), v.isAcceptsCash(), v.isActive(),
                v.getRatingAvg());
    }
}
