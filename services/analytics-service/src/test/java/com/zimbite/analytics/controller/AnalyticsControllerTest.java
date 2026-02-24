package com.zimbite.analytics.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.zimbite.analytics.repository.DeliveryProjectionRepository;
import com.zimbite.analytics.repository.OrderProjectionRepository;
import com.zimbite.analytics.repository.RefundedPaymentProjectionRepository;
import com.zimbite.analytics.repository.SucceededPaymentProjectionRepository;
import com.zimbite.analytics.service.AnalyticsQueryService;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class AnalyticsControllerTest {

  @Mock
  private OrderProjectionRepository orderProjectionRepository;

  @Mock
  private SucceededPaymentProjectionRepository succeededPaymentProjectionRepository;

  @Mock
  private RefundedPaymentProjectionRepository refundedPaymentProjectionRepository;

  @Mock
  private DeliveryProjectionRepository deliveryProjectionRepository;

  private AnalyticsQueryService service;
  private AnalyticsController controller;

  @BeforeEach
  void setUp() {
    service = new AnalyticsQueryService(
        orderProjectionRepository,
        succeededPaymentProjectionRepository,
        refundedPaymentProjectionRepository,
        deliveryProjectionRepository
    );
    controller = new AnalyticsController(service);
  }

  @Test
  void revenueReturnsSeriesForRange() {
    var response = controller.revenue(LocalDate.parse("2026-02-20"), LocalDate.parse("2026-02-22"), "USD");

    assertNotNull(response.getBody());
    assertEquals("USD", response.getBody().get("currency"));
  }

  @Test
  void vendorDashboardReflectsRecordedEvents() {
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
