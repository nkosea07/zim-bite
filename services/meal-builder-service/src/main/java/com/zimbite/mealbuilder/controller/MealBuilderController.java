package com.zimbite.mealbuilder.controller;

import com.zimbite.mealbuilder.model.dto.MealCalculationResponse;
import com.zimbite.mealbuilder.model.dto.MealCompositionRequest;
import com.zimbite.mealbuilder.model.dto.MealPresetResponse;
import com.zimbite.mealbuilder.model.dto.MealRecommendationResponse;
import com.zimbite.mealbuilder.model.dto.MealValidationResponse;
import com.zimbite.mealbuilder.model.dto.SaveMealPresetRequest;
import com.zimbite.mealbuilder.service.MealBuilderService;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/meal-builder")
public class MealBuilderController {

  private final MealBuilderService mealBuilderService;

  public MealBuilderController(MealBuilderService mealBuilderService) {
    this.mealBuilderService = mealBuilderService;
  }

  @PostMapping("/calculate")
  public ResponseEntity<MealCalculationResponse> calculate(@Valid @RequestBody MealCompositionRequest request) {
    return ResponseEntity.ok(mealBuilderService.calculate(request));
  }

  @PostMapping("/validate")
  public ResponseEntity<MealValidationResponse> validate(@Valid @RequestBody MealCompositionRequest request) {
    return ResponseEntity.ok(mealBuilderService.validate(request));
  }

  @GetMapping("/presets")
  public ResponseEntity<List<MealPresetResponse>> listPresets(HttpServletRequest request) {
    return ResponseEntity.ok(mealBuilderService.listPresets(currentUserId(request)));
  }

  @PostMapping("/presets")
  public ResponseEntity<MealPresetResponse> savePreset(
      HttpServletRequest request,
      @Valid @RequestBody SaveMealPresetRequest payload
  ) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(mealBuilderService.savePreset(currentUserId(request), payload));
  }

  @GetMapping("/recommendations")
  public ResponseEntity<List<MealRecommendationResponse>> recommendations(
      @RequestParam(name = "vendor_id", required = false) UUID vendorId
  ) {
    return ResponseEntity.ok(mealBuilderService.recommendations(vendorId));
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
