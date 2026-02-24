package com.zimbite.analytics.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.zimbite.analytics.service.AnalyticsQueryService;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class AnalyticsControllerTest {

  @Test
  void revenueReturnsSeriesForRange() {
    AnalyticsQueryService service = new AnalyticsQueryService();
    AnalyticsController controller = new AnalyticsController(service);
    var response = controller.revenue(LocalDate.parse("2026-02-20"), LocalDate.parse("2026-02-22"), "USD");

    assertNotNull(response.getBody());
    assertEquals("USD", response.getBody().get("currency"));
  }

  @Test
  void vendorDashboardReflectsRecordedEvents() {
    AnalyticsQueryService service = new AnalyticsQueryService();
    AnalyticsController controller = new AnalyticsController(service);
    UUID vendorId = UUID.randomUUID();
    UUID orderId = UUID.randomUUID();

    service.recordOrderCreated(new OrderCreatedEvent(
        orderId,
        UUID.randomUUID(),
        vendorId,
        new BigDecimal("10.00"),
        "USD",
        OffsetDateTime.now()
    ));
    service.recordPaymentSucceeded(new PaymentSucceededEvent(
        UUID.randomUUID(),
        orderId,
        new BigDecimal("10.00"),
        "USD",
        "ECOCASH",
        OffsetDateTime.now()
    ));

    var response = controller.vendorDashboard(vendorId);
    assertNotNull(response.getBody());
    assertEquals(vendorId, response.getBody().get("vendorId"));
    assertEquals(new BigDecimal("10.00"), response.getBody().get("grossRevenueToday"));
    assertTrue((Long) response.getBody().get("ordersToday") > 0);
  }
}
