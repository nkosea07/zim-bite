package com.zimbite.menu.controller;

import com.zimbite.menu.model.dto.CreateMenuItemRequest;
import com.zimbite.menu.model.dto.MenuItemResponse;
import com.zimbite.menu.service.MenuCatalogService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/menu/vendors/{vendorId}/items")
public class MenuItemController {

  private final MenuCatalogService menuCatalogService;

  public MenuItemController(MenuCatalogService menuCatalogService) {
    this.menuCatalogService = menuCatalogService;
  }

  @GetMapping
  public ResponseEntity<List<MenuItemResponse>> list(@PathVariable UUID vendorId) {
    return ResponseEntity.ok(menuCatalogService.listByVendor(vendorId));
  }

  @PostMapping
  public ResponseEntity<MenuItemResponse> create(
      @PathVariable UUID vendorId,
      @Valid @RequestBody CreateMenuItemRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED).body(menuCatalogService.create(vendorId, request));
  }
}
