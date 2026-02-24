package com.zimbite.analytics.controller;

import com.zimbite.analytics.service.AnalyticsQueryService;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

  private final AnalyticsQueryService analyticsQueryService;

  public AnalyticsController(AnalyticsQueryService analyticsQueryService) {
    this.analyticsQueryService = analyticsQueryService;
  }

  @GetMapping("/vendor/{vendorId}/dashboard")
  public ResponseEntity<Map<String, Object>> vendorDashboard(@PathVariable UUID vendorId) {
    return ResponseEntity.ok(analyticsQueryService.vendorDashboard(vendorId));
  }

  @GetMapping("/admin/overview")
  public ResponseEntity<Map<String, Object>> adminOverview() {
    return ResponseEntity.ok(analyticsQueryService.adminOverview());
  }

  @GetMapping("/revenue")
  public ResponseEntity<Map<String, Object>> revenue(
      @RequestParam(name = "from", required = false) LocalDate from,
      @RequestParam(name = "to", required = false) LocalDate to,
      @RequestParam(name = "currency", defaultValue = "USD") String currency
  ) {
    LocalDate end = to == null ? LocalDate.now() : to;
    LocalDate start = from == null ? end.minusDays(6) : from;
    if (start.isAfter(end)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "`from` must be on or before `to`");
    }

    return ResponseEntity.ok(analyticsQueryService.revenue(start, end, currency));
  }
}
