package com.zimbite.analytics.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class AnalyticsControllerTest {

  @Test
  void revenueReturnsSeriesForRange() {
    AnalyticsController controller = new AnalyticsController();
    var response = controller.revenue(LocalDate.parse("2026-02-20"), LocalDate.parse("2026-02-22"), "USD");

    assertNotNull(response.getBody());
    assertEquals("USD", response.getBody().get("currency"));
  }

  @Test
  void vendorDashboardReturnsPayload() {
    AnalyticsController controller = new AnalyticsController();
    var response = controller.vendorDashboard(UUID.randomUUID());
    assertNotNull(response.getBody());
  }
}
