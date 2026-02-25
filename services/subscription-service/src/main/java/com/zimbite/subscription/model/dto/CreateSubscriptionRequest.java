package com.zimbite.subscription.model.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.util.List;
import java.util.UUID;

public record CreateSubscriptionRequest(
    @NotNull UUID vendorId,
    @NotNull UUID deliveryAddressId,
    @NotBlank @Pattern(regexp = "DAILY|WEEKLY|MONTHLY") String planType,
    @NotBlank @Pattern(regexp = "USD|ZWL") String currency,
    @NotEmpty @Valid List<SubscriptionItemRequest> items,
    String presetName,
    String notes
) {
  public record SubscriptionItemRequest(
      @NotNull UUID menuItemId,
      @NotNull Integer quantity
  ) {}
}
