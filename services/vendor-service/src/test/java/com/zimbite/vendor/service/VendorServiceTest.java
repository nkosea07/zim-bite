package com.zimbite.vendor.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import org.junit.jupiter.api.Test;

class VendorServiceTest {

  @Test
  void createVendorAddsStorefront() {
    VendorService service = new VendorService();

    VendorResponse created = service.create(new CreateVendorRequest(
        "Dawn Bites",
        "Bulawayo",
        -20.15,
        28.58,
        true
    ));

    assertNotNull(created.id());
    assertFalse(service.list(null, null, null).isEmpty());
  }
}
