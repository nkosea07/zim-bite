package com.zimbite.vendor.controller;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.UpdateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import com.zimbite.vendor.model.dto.VendorStatsResponse;
import com.zimbite.vendor.service.VendorService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/vendors")
public class VendorController {

    private final VendorService vendorService;

    public VendorController(VendorService vendorService) {
        this.vendorService = vendorService;
    }

    @GetMapping
    public ResponseEntity<List<VendorResponse>> listVendors(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(name = "radius_km", required = false) Double radiusKm) {
        return ResponseEntity.ok(vendorService.list(lat, lng, radiusKm));
    }

    @PostMapping
    public ResponseEntity<VendorResponse> createVendor(@Valid @RequestBody CreateVendorRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(vendorService.create(request));
    }

    @GetMapping("/{vendorId}")
    public ResponseEntity<VendorResponse> getVendor(@PathVariable UUID vendorId) {
        return ResponseEntity.ok(vendorService.getById(vendorId));
    }

    @PatchMapping("/{vendorId}")
    public ResponseEntity<VendorResponse> updateVendor(@PathVariable UUID vendorId,
                                                        @RequestBody UpdateVendorRequest request) {
        return ResponseEntity.ok(vendorService.update(vendorId, request));
    }

    @GetMapping("/{vendorId}/stats")
    public ResponseEntity<VendorStatsResponse> stats(@PathVariable UUID vendorId) {
        return ResponseEntity.ok(vendorService.stats(vendorId));
    }
}
