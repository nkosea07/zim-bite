package com.zimbite.mealbuilder.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.zimbite.mealbuilder.model.dto.MealComponentRequest;
import com.zimbite.mealbuilder.model.dto.MealCompositionRequest;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class MealBuilderServiceTest {

  @Test
  void validateRejectsOversizedComponents() {
    MealBuilderService service = new MealBuilderService();
    MealCompositionRequest request = new MealCompositionRequest(
        UUID.randomUUID(),
        UUID.randomUUID(),
        List.of(new MealComponentRequest(UUID.randomUUID(), new BigDecimal("6")))
    );

    assertFalse(service.validate(request).valid());
  }

  @Test
  void calculateReturnsPositivePrice() {
    MealBuilderService service = new MealBuilderService();
    MealCompositionRequest request = new MealCompositionRequest(
        UUID.randomUUID(),
        UUID.randomUUID(),
        List.of(new MealComponentRequest(UUID.randomUUID(), new BigDecimal("1")))
    );

    assertTrue(service.calculate(request).totalPrice().compareTo(BigDecimal.ZERO) > 0);
  }
}
