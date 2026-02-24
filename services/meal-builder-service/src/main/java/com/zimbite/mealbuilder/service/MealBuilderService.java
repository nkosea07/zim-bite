package com.zimbite.mealbuilder.service;

import com.zimbite.mealbuilder.model.dto.MealCalculationResponse;
import com.zimbite.mealbuilder.model.dto.MealCompositionRequest;
import com.zimbite.mealbuilder.model.dto.MealPresetResponse;
import com.zimbite.mealbuilder.model.dto.MealRecommendationResponse;
import com.zimbite.mealbuilder.model.dto.MealValidationResponse;
import com.zimbite.mealbuilder.model.dto.SaveMealPresetRequest;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class MealBuilderService {

  private static final BigDecimal BASE_PRICE = BigDecimal.valueOf(3.00);
  private static final BigDecimal COMPONENT_UNIT_PRICE = BigDecimal.valueOf(1.20);

  private final Map<UUID, List<MealPresetResponse>> presetsByUser = new ConcurrentHashMap<>();

  public MealCalculationResponse calculate(MealCompositionRequest request) {
    BigDecimal componentTotal = request.components().stream()
        .map(c -> COMPONENT_UNIT_PRICE.multiply(c.quantity()))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    BigDecimal totalPrice = BASE_PRICE.add(componentTotal).setScale(2, RoundingMode.HALF_UP);

    int calories = 250 + request.components().stream()
        .mapToInt(c -> c.quantity().multiply(BigDecimal.valueOf(85)).intValue())
        .sum();
    boolean available = unavailableComponents(request).isEmpty();
    return new MealCalculationResponse(totalPrice, calories, available);
  }

  public MealValidationResponse validate(MealCompositionRequest request) {
    List<UUID> unavailable = unavailableComponents(request);
    return new MealValidationResponse(unavailable.isEmpty(), unavailable);
  }

  public List<MealPresetResponse> listPresets(UUID userId) {
    return presetsByUser.getOrDefault(userId, List.of());
  }

  public MealPresetResponse savePreset(UUID userId, SaveMealPresetRequest request) {
    MealPresetResponse preset = new MealPresetResponse(
        UUID.randomUUID(),
        request.name().trim(),
        request.vendorId(),
        request.baseItemId(),
        request.components(),
        OffsetDateTime.now()
    );
    presetsByUser.compute(userId, (id, existing) -> {
      List<MealPresetResponse> next = new ArrayList<>(existing == null ? List.of() : existing);
      next.add(0, preset);
      return next;
    });
    return preset;
  }

  public List<MealRecommendationResponse> recommendations(UUID vendorId) {
    return presetsByUser.values().stream()
        .flatMap(List::stream)
        .filter(preset -> vendorId == null || vendorId.equals(preset.vendorId()))
        .sorted(Comparator.comparing(MealPresetResponse::createdAt).reversed())
        .limit(3)
        .map(this::toRecommendation)
        .toList();
  }

  private List<UUID> unavailableComponents(MealCompositionRequest request) {
    List<UUID> unavailable = new ArrayList<>();
    request.components().forEach(component -> {
      if (component.quantity().compareTo(BigDecimal.valueOf(5.0)) > 0) {
        unavailable.add(component.componentId());
      }
    });
    return unavailable;
  }

  private MealRecommendationResponse toRecommendation(MealPresetResponse preset) {
    BigDecimal componentTotal = preset.components().stream()
        .map(component -> COMPONENT_UNIT_PRICE.multiply(component.quantity()))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    BigDecimal totalPrice = BASE_PRICE.add(componentTotal).setScale(2, RoundingMode.HALF_UP);

    int calories = 250 + preset.components().stream()
        .mapToInt(component -> component.quantity().multiply(BigDecimal.valueOf(85)).intValue())
        .sum();

    return new MealRecommendationResponse(
        preset.presetId(),
        preset.name(),
        totalPrice,
        calories
    );
  }
}
