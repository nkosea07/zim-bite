package com.zimbite.menu.service;

import com.zimbite.menu.model.dto.CreateMenuItemRequest;
import com.zimbite.menu.model.dto.MenuItemResponse;
import com.zimbite.menu.model.entity.MenuItemEntity;
import com.zimbite.menu.repository.MenuItemRepository;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class MenuCatalogService {

  private final MenuItemRepository menuItemRepository;

  public MenuCatalogService(MenuItemRepository menuItemRepository) {
    this.menuItemRepository = menuItemRepository;
  }

  @Transactional
  public List<MenuItemResponse> listByVendor(UUID vendorId) {
    return menuItemRepository.findByVendorId(vendorId).stream().map(this::toResponse).toList();
  }

  @Transactional
  public MenuItemResponse create(UUID vendorId, CreateMenuItemRequest request) {
    MenuItemEntity item = new MenuItemEntity();
    item.setId(UUID.randomUUID());
    item.setVendorId(vendorId);
    item.setName(request.name());
    item.setBasePrice(request.basePrice());
    item.setCurrency(request.currency());
    item.setAvailable(true);
    item.setCreatedAt(OffsetDateTime.now());
    return toResponse(menuItemRepository.save(item));
  }

  private MenuItemResponse toResponse(MenuItemEntity item) {
    return new MenuItemResponse(
        item.getId(),
        item.getVendorId(),
        item.getName(),
        item.getBasePrice(),
        item.getCurrency(),
        item.isAvailable()
    );
  }
}
