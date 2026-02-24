package com.zimbite.analytics.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

  @GetMapping("/vendor/{vendorId}/dashboard")
  public ResponseEntity<Map<String, Object>> vendorDashboard(@PathVariable UUID vendorId) {
    Map<String, Object> response = Map.of(
        "vendorId", vendorId,
        "ordersToday", 84,
        "grossRevenueToday", BigDecimal.valueOf(1260.40),
        "averagePrepMinutes", 18,
        "averageRating", 4.6
    );
    return ResponseEntity.ok(response);
  }

  @GetMapping("/admin/overview")
  public ResponseEntity<Map<String, Object>> adminOverview() {
    Map<String, Object> response = Map.of(
        "activeVendors", 146,
        "activeRiders", 219,
        "ordersToday", 3481,
        "platformGrossRevenueToday", BigDecimal.valueOf(48129.77),
        "currency", "USD"
    );
    return ResponseEntity.ok(response);
  }

  @GetMapping("/revenue")
  public ResponseEntity<Map<String, Object>> revenue(
      @RequestParam(name = "from", required = false) LocalDate from,
      @RequestParam(name = "to", required = false) LocalDate to,
      @RequestParam(name = "currency", defaultValue = "USD") String currency
  ) {
    LocalDate end = to == null ? LocalDate.now() : to;
    LocalDate start = from == null ? end.minusDays(6) : from;

    List<Map<String, Object>> series = start.datesUntil(end.plusDays(1))
        .map(day -> Map.<String, Object>of(
            "date", day.toString(),
            "revenue", BigDecimal.valueOf(3500 + Math.abs(day.hashCode() % 4000)).setScale(2)))
        .toList();

    return ResponseEntity.ok(Map.of(
        "from", start,
        "to", end,
        "currency", currency.toUpperCase(),
        "series", series
    ));
  }
}
