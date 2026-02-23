package com.zimbite.menu.service;

import com.zimbite.menu.model.dto.CreateMenuItemRequest;
import com.zimbite.menu.model.dto.MenuItemResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class MenuCatalogService {

  private final Map<UUID, List<MenuItemResponse>> byVendor = new ConcurrentHashMap<>();

  public List<MenuItemResponse> listByVendor(UUID vendorId) {
    return byVendor.getOrDefault(vendorId, List.of());
  }

  public MenuItemResponse create(UUID vendorId, CreateMenuItemRequest request) {
    MenuItemResponse item = new MenuItemResponse(
        UUID.randomUUID(),
        vendorId,
        request.name(),
        request.basePrice(),
        request.currency(),
        true
    );
    byVendor.computeIfAbsent(vendorId, ignored -> new ArrayList<>()).add(item);
    return item;
  }
}
