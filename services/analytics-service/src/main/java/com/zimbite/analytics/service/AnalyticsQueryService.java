package com.zimbite.analytics.service;

import com.zimbite.shared.messaging.contract.DeliveryAssignedEvent;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import com.zimbite.shared.messaging.contract.OrderCreatedEvent;
import com.zimbite.shared.messaging.contract.PaymentRefundedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Clock;
import java.time.Duration;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class AnalyticsQueryService {

  private static final String DEFAULT_CURRENCY = "USD";
  private static final String ZWL_CURRENCY = "ZWL";

  private final Clock clock;
  private final Map<UUID, OrderSnapshot> ordersById = new ConcurrentHashMap<>();
  private final Map<UUID, PaymentSnapshot> succeededPaymentsById = new ConcurrentHashMap<>();
  private final Map<UUID, PaymentSnapshot> refundedPaymentsById = new ConcurrentHashMap<>();
  private final Map<UUID, DeliverySnapshot> deliveriesById = new ConcurrentHashMap<>();

  public AnalyticsQueryService() {
    this(Clock.systemUTC());
  }

  AnalyticsQueryService(Clock clock) {
    this.clock = clock;
  }

  public Map<String, Object> vendorDashboard(UUID vendorId) {
    LocalDate today = LocalDate.now(clock);

    long ordersToday = ordersById.values().stream()
        .filter(order -> vendorId.equals(order.vendorId()))
        .filter(order -> toDate(order.createdAt()).equals(today))
        .count();

    BigDecimal grossRevenueToday = netRevenue(today, DEFAULT_CURRENCY, vendorId);

    List<Long> prepDurations = vendorPrepDurationsMinutes(vendorId, today);
    int averagePrepMinutes = prepDurations.isEmpty()
        ? 0
        : (int) Math.round(prepDurations.stream().mapToLong(Long::longValue).average().orElse(0));

    long onTimeCount = prepDurations.stream().filter(minutes -> minutes <= 30).count();
    BigDecimal averageRating = prepDurations.isEmpty()
        ? BigDecimal.ZERO.setScale(1, RoundingMode.HALF_UP)
        : BigDecimal.valueOf(3.0 + (2.0 * ((double) onTimeCount / prepDurations.size())))
            .setScale(1, RoundingMode.HALF_UP);

    return Map.of(
        "vendorId", vendorId,
        "ordersToday", ordersToday,
        "grossRevenueToday", grossRevenueToday,
        "averagePrepMinutes", averagePrepMinutes,
        "averageRating", averageRating
    );
  }

  public Map<String, Object> adminOverview() {
    LocalDate today = LocalDate.now(clock);

    long activeVendors = ordersById.values().stream()
        .filter(order -> toDate(order.createdAt()).equals(today))
        .map(OrderSnapshot::vendorId)
        .distinct()
        .count();

    long activeRiders = deliveriesById.values().stream()
        .filter(delivery -> isSameDate(delivery.assignedAt(), today) || isSameDate(delivery.completedAt(), today))
        .map(DeliverySnapshot::riderId)
        .filter(riderId -> riderId != null)
        .distinct()
        .count();

    long ordersToday = ordersById.values().stream()
        .filter(order -> toDate(order.createdAt()).equals(today))
        .count();

    return Map.of(
        "activeVendors", activeVendors,
        "activeRiders", activeRiders,
        "ordersToday", ordersToday,
        "platformGrossRevenueToday", netRevenue(today, DEFAULT_CURRENCY, null),
        "currency", DEFAULT_CURRENCY
    );
  }

  public Map<String, Object> revenue(LocalDate from, LocalDate to, String currency) {
    String normalizedCurrency = normalizeCurrency(currency);
    List<Map<String, Object>> series = from.datesUntil(to.plusDays(1))
        .map(day -> Map.<String, Object>of(
            "date", day.toString(),
            "revenue", netRevenue(day, normalizedCurrency, null)
        ))
        .toList();

    return Map.of(
        "from", from,
        "to", to,
        "currency", normalizedCurrency,
        "series", series
    );
  }

  public void recordOrderCreated(OrderCreatedEvent event) {
    ordersById.put(event.orderId(), new OrderSnapshot(
        event.orderId(),
        event.vendorId(),
        event.currency(),
        event.createdAt()
    ));
  }

  public void recordPaymentSucceeded(PaymentSucceededEvent event) {
    succeededPaymentsById.put(event.paymentId(), new PaymentSnapshot(
        event.paymentId(),
        event.orderId(),
        event.amount(),
        event.currency(),
        event.completedAt()
    ));
  }

  public void recordPaymentRefunded(PaymentRefundedEvent event) {
    refundedPaymentsById.put(event.paymentId(), new PaymentSnapshot(
        event.paymentId(),
        event.orderId(),
        event.amount(),
        event.currency(),
        event.refundedAt()
    ));
  }

  public void recordDeliveryAssigned(DeliveryAssignedEvent event) {
    deliveriesById.compute(event.deliveryId(), (deliveryId, existing) -> new DeliverySnapshot(
        event.deliveryId(),
        event.orderId(),
        event.riderId(),
        event.assignedAt(),
        existing == null ? null : existing.completedAt()
    ));
  }

  public void recordDeliveryCompleted(DeliveryCompletedEvent event) {
    deliveriesById.compute(event.deliveryId(), (deliveryId, existing) -> new DeliverySnapshot(
        event.deliveryId(),
        event.orderId(),
        event.riderId(),
        existing == null ? null : existing.assignedAt(),
        event.completedAt()
    ));
  }

  private BigDecimal netRevenue(LocalDate date, String currency, UUID vendorId) {
    BigDecimal succeeded = succeededPaymentsById.values().stream()
        .filter(payment -> isSameDate(payment.happenedAt(), date))
        .filter(payment -> currency.equalsIgnoreCase(payment.currency()))
        .filter(payment -> vendorId == null || belongsToVendor(payment.orderId(), vendorId))
        .map(PaymentSnapshot::amount)
        .reduce(BigDecimal.ZERO, BigDecimal::add);

    BigDecimal refunded = refundedPaymentsById.values().stream()
        .filter(payment -> isSameDate(payment.happenedAt(), date))
        .filter(payment -> currency.equalsIgnoreCase(payment.currency()))
        .filter(payment -> vendorId == null || belongsToVendor(payment.orderId(), vendorId))
        .map(PaymentSnapshot::amount)
        .reduce(BigDecimal.ZERO, BigDecimal::add);

    return succeeded.subtract(refunded).setScale(2, RoundingMode.HALF_UP);
  }

  private List<Long> vendorPrepDurationsMinutes(UUID vendorId, LocalDate day) {
    List<Long> durations = new ArrayList<>();
    deliveriesById.values().forEach(delivery -> {
      if (!isSameDate(delivery.completedAt(), day)) {
        return;
      }

      OrderSnapshot order = ordersById.get(delivery.orderId());
      if (order == null || !vendorId.equals(order.vendorId())) {
        return;
      }

      long minutes = Duration.between(order.createdAt(), delivery.completedAt()).toMinutes();
      if (minutes >= 0) {
        durations.add(minutes);
      }
    });
    return durations;
  }

  private boolean belongsToVendor(UUID orderId, UUID vendorId) {
    OrderSnapshot order = ordersById.get(orderId);
    return order != null && vendorId.equals(order.vendorId());
  }

  private String normalizeCurrency(String currency) {
    if (currency == null || currency.isBlank()) {
      return DEFAULT_CURRENCY;
    }
    String normalized = currency.trim().toUpperCase(Locale.ROOT);
    if (DEFAULT_CURRENCY.equals(normalized) || ZWL_CURRENCY.equals(normalized)) {
      return normalized;
    }
    return DEFAULT_CURRENCY;
  }

  private boolean isSameDate(OffsetDateTime timestamp, LocalDate date) {
    return timestamp != null && toDate(timestamp).equals(date);
  }

  private LocalDate toDate(OffsetDateTime timestamp) {
    return timestamp.atZoneSameInstant(ZoneOffset.UTC).toLocalDate();
  }

  private record OrderSnapshot(
      UUID orderId,
      UUID vendorId,
      String currency,
      OffsetDateTime createdAt
  ) {
  }

  private record PaymentSnapshot(
      UUID paymentId,
      UUID orderId,
      BigDecimal amount,
      String currency,
      OffsetDateTime happenedAt
  ) {
  }

  private record DeliverySnapshot(
      UUID deliveryId,
      UUID orderId,
      UUID riderId,
      OffsetDateTime assignedAt,
      OffsetDateTime completedAt
  ) {
  }
}
