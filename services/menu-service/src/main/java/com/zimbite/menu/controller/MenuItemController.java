package com.zimbite.menu.controller;

import com.zimbite.menu.model.dto.CategoryResponse;
import com.zimbite.menu.model.dto.CreateMenuItemRequest;
import com.zimbite.menu.model.dto.MenuItemResponse;
import com.zimbite.menu.model.dto.UpdateAvailabilityRequest;
import com.zimbite.menu.model.dto.UpdateMenuItemRequest;
import com.zimbite.menu.service.MenuCatalogService;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/menu")
public class MenuItemController {

  private final MenuCatalogService menuCatalogService;

  public MenuItemController(MenuCatalogService menuCatalogService) {
    this.menuCatalogService = menuCatalogService;
  }

  @GetMapping("/vendors/{vendorId}/categories")
  public ResponseEntity<List<CategoryResponse>> listCategories(@PathVariable UUID vendorId) {
    return ResponseEntity.ok(menuCatalogService.listCategories(vendorId));
  }

  @GetMapping("/vendors/{vendorId}/items")
  public ResponseEntity<List<MenuItemResponse>> list(@PathVariable UUID vendorId) {
    return ResponseEntity.ok(menuCatalogService.listByVendor(vendorId));
  }

  @PostMapping("/vendors/{vendorId}/items")
  public ResponseEntity<MenuItemResponse> create(
      @PathVariable UUID vendorId,
      @Valid @RequestBody CreateMenuItemRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED).body(menuCatalogService.create(vendorId, request));
  }

  @GetMapping("/items/{itemId}")
  public ResponseEntity<MenuItemResponse> getItem(@PathVariable UUID itemId) {
    MenuItemResponse response = menuCatalogService.getById(itemId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PatchMapping("/items/{itemId}")
  public ResponseEntity<MenuItemResponse> updateItem(
      @PathVariable UUID itemId,
      @RequestBody UpdateMenuItemRequest request
  ) {
    MenuItemResponse response = menuCatalogService.update(itemId, request);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PatchMapping("/items/{itemId}/availability")
  public ResponseEntity<MenuItemResponse> updateAvailability(
      @PathVariable UUID itemId,
      @Valid @RequestBody UpdateAvailabilityRequest request
  ) {
    MenuItemResponse response = menuCatalogService.updateAvailability(itemId, request.available());
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }
}
