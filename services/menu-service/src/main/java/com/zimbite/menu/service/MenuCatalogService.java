package com.zimbite.menu.service;

import com.zimbite.menu.model.dto.CategoryResponse;
import com.zimbite.menu.model.dto.CreateMenuItemRequest;
import com.zimbite.menu.model.dto.MenuItemResponse;
import com.zimbite.menu.model.dto.UpdateMenuItemRequest;
import com.zimbite.menu.model.entity.MenuItemEntity;
import com.zimbite.menu.repository.MenuItemRepository;
import org.springframework.transaction.annotation.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.stereotype.Service;

@Service
public class MenuCatalogService {

  private final MenuItemRepository menuItemRepository;

  public MenuCatalogService(MenuItemRepository menuItemRepository) {
    this.menuItemRepository = menuItemRepository;
  }

  @Cacheable(value = "menu-items", key = "#vendorId")
  public List<MenuItemResponse> listByVendor(UUID vendorId) {
    return menuItemRepository.findByVendorId(vendorId).stream().map(this::toResponse).toList();
  }

  @Cacheable(value = "menu-categories", key = "#vendorId")
  public List<CategoryResponse> listCategories(UUID vendorId) {
    return menuItemRepository.findDistinctCategoriesByVendorId(vendorId).stream()
        .map(CategoryResponse::new)
        .toList();
  }

  public MenuItemResponse getById(UUID itemId) {
    return menuItemRepository.findById(itemId).map(this::toResponse).orElse(null);
  }

  @Caching(evict = {
      @CacheEvict(value = "menu-items", key = "#vendorId"),
      @CacheEvict(value = "menu-categories", key = "#vendorId")
  })
  @Transactional
  public MenuItemResponse create(UUID vendorId, CreateMenuItemRequest request) {
    MenuItemEntity item = new MenuItemEntity();
    item.setId(UUID.randomUUID());
    item.setVendorId(vendorId);
    item.setName(request.name());
    item.setCategory("General");
    item.setBasePrice(request.basePrice());
    item.setCurrency(request.currency());
    item.setAvailable(true);
    item.setCreatedAt(OffsetDateTime.now());
    return toResponse(menuItemRepository.save(item));
  }

  @Caching(evict = {
      @CacheEvict(value = "menu-items", allEntries = true),
      @CacheEvict(value = "menu-categories", allEntries = true)
  })
  @Transactional
  public MenuItemResponse update(UUID itemId, UpdateMenuItemRequest request) {
    MenuItemEntity item = menuItemRepository.findById(itemId).orElse(null);
    if (item == null) {
      return null;
    }
    if (request.name() != null && !request.name().isBlank()) {
      item.setName(request.name().trim());
    }
    if (request.category() != null && !request.category().isBlank()) {
      item.setCategory(request.category().trim());
    }
    if (request.basePrice() != null) {
      item.setBasePrice(request.basePrice());
    }
    if (request.currency() != null && !request.currency().isBlank()) {
      item.setCurrency(request.currency().trim().toUpperCase());
    }
    return toResponse(menuItemRepository.save(item));
  }

  @Caching(evict = {
      @CacheEvict(value = "menu-items", allEntries = true),
      @CacheEvict(value = "menu-categories", allEntries = true)
  })
  @Transactional
  public MenuItemResponse updateAvailability(UUID itemId, boolean available) {
    MenuItemEntity item = menuItemRepository.findById(itemId).orElse(null);
    if (item == null) {
      return null;
    }
    item.setAvailable(available);
    return toResponse(menuItemRepository.save(item));
  }

  private MenuItemResponse toResponse(MenuItemEntity item) {
    return new MenuItemResponse(
        item.getId(),
        item.getVendorId(),
        item.getName(),
        item.getCategory(),
        item.getBasePrice(),
        item.getCurrency(),
        item.isAvailable()
    );
  }
}
