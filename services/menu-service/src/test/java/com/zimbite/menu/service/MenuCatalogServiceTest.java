package com.zimbite.menu.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.zimbite.menu.model.dto.MenuItemResponse;
import com.zimbite.menu.model.entity.MenuItemEntity;
import com.zimbite.menu.repository.MenuItemRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class MenuCatalogServiceTest {

  @Mock
  private MenuItemRepository menuItemRepository;

  private MenuCatalogService service;

  @BeforeEach
  void setUp() {
    service = new MenuCatalogService(menuItemRepository);
  }

  @Test
  void updateAvailabilityPersistsToggle() {
    UUID itemId = UUID.randomUUID();
    MenuItemEntity entity = new MenuItemEntity();
    entity.setId(itemId);
    entity.setVendorId(UUID.randomUUID());
    entity.setName("Tea");
    entity.setCategory("Drinks");
    entity.setBasePrice(new BigDecimal("1.20"));
    entity.setCurrency("USD");
    entity.setAvailable(true);
    entity.setCreatedAt(OffsetDateTime.now());

    when(menuItemRepository.findById(itemId)).thenReturn(Optional.of(entity));
    when(menuItemRepository.save(any(MenuItemEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));

    MenuItemResponse response = service.updateAvailability(itemId, false);

    assertNotNull(response);
    assertFalse(response.available());
  }
}
