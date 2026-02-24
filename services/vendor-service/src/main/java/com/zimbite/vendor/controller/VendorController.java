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
  public ResponseEntity<List<VendorResponse>> list(
      @RequestParam(required = false) Double lat,
      @RequestParam(required = false) Double lng,
      @RequestParam(name = "radius_km", required = false) Double radiusKm
  ) {
    return ResponseEntity.ok(vendorService.list(lat, lng, radiusKm));
  }

  @PostMapping
  public ResponseEntity<VendorResponse> create(@Valid @RequestBody CreateVendorRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(vendorService.create(request));
  }

  @GetMapping("/{vendorId}")
  public ResponseEntity<VendorResponse> get(@PathVariable UUID vendorId) {
    VendorResponse response = vendorService.get(vendorId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PatchMapping("/{vendorId}")
  public ResponseEntity<VendorResponse> update(
      @PathVariable UUID vendorId,
      @RequestBody UpdateVendorRequest request
  ) {
    VendorResponse response = vendorService.update(vendorId, request);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @GetMapping("/{vendorId}/stats")
  public ResponseEntity<VendorStatsResponse> stats(@PathVariable UUID vendorId) {
    VendorStatsResponse response = vendorService.stats(vendorId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }
}
