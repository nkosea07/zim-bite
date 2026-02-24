package com.zimbite.vendor.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.zimbite.vendor.model.dto.CreateVendorRequest;
import com.zimbite.vendor.model.dto.VendorResponse;
import com.zimbite.vendor.model.entity.VendorEntity;
import com.zimbite.vendor.repository.VendorRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class VendorServiceTest {

    @Mock
    private VendorRepository vendorRepository;

    @InjectMocks
    private VendorService vendorService;

    @Test
    void createVendorPersistsAndReturnsResponse() {
        when(vendorRepository.save(any(VendorEntity.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CreateVendorRequest request = new CreateVendorRequest(
                UUID.randomUUID(),
                "Dawn Bites",
                "+263771234567",
                null,
                "A local kitchen",
                BigDecimal.valueOf(-20.15),
                BigDecimal.valueOf(28.58)
        );

        VendorResponse created = vendorService.create(request);

        assertNotNull(created.id());
        assertEquals("Dawn Bites", created.name());
    }

    @Test
    void listReturnsActiveVendors() {
        VendorEntity vendor = buildVendorEntity("Sunrise Kitchen");
        when(vendorRepository.findByActiveTrue()).thenReturn(List.of(vendor));

        List<VendorResponse> results = vendorService.list(null, null, null);

        assertFalse(results.isEmpty());
        assertEquals("Sunrise Kitchen", results.get(0).name());
    }

    private VendorEntity buildVendorEntity(String name) {
        VendorEntity entity = new VendorEntity();
        entity.setId(UUID.randomUUID());
        entity.setOwnerUserId(UUID.randomUUID());
        entity.setName(name);
        entity.setSlug(name.toLowerCase().replace(" ", "-"));
        entity.setPhoneNumber("+263771234567");
        entity.setLatitude(BigDecimal.valueOf(-17.83));
        entity.setLongitude(BigDecimal.valueOf(31.05));
        entity.setAveragePrepMinutes((short) 20);
        entity.setDeliveryRadiusKm(BigDecimal.valueOf(6));
        entity.setMinOrderValue(BigDecimal.ZERO);
        entity.setAcceptsCash(true);
        entity.setActive(true);
        entity.setRatingAvg(BigDecimal.ZERO);
        return entity;
    }
}
