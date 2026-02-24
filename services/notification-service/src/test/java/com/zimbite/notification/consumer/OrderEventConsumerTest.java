package com.zimbite.notification.consumer;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.notification.model.entity.OrderRecipientEntity;
import com.zimbite.notification.repository.OrderRecipientRepository;
import com.zimbite.notification.service.NotificationQueryService;
import com.zimbite.shared.messaging.contract.DeliveryCompletedEvent;
import com.zimbite.shared.messaging.contract.PaymentRefundedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class OrderEventConsumerTest {

  @Mock
  private NotificationQueryService notificationQueryService;

  @Mock
  private OrderRecipientRepository orderRecipientRepository;

  private ObjectMapper objectMapper;
  private OrderEventConsumer consumer;

  @BeforeEach
  void setUp() {
    objectMapper = new ObjectMapper().findAndRegisterModules();
    consumer = new OrderEventConsumer(objectMapper, notificationQueryService, orderRecipientRepository);
  }

  @Test
  void paymentSucceededCreatesNotificationForOrderOwner() throws Exception {
    UUID orderId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    when(orderRecipientRepository.findById(orderId)).thenReturn(Optional.of(recipient(orderId, userId)));

    PaymentSucceededEvent event = new PaymentSucceededEvent(
        UUID.randomUUID(),
        orderId,
        new BigDecimal("12.50"),
        "USD",
        "ECOCASH",
        OffsetDateTime.now()
    );

    consumer.onPaymentSucceeded(objectMapper.writeValueAsString(event));

    verify(notificationQueryService).createNotification(
        userId,
        "PAYMENT_SUCCESS",
        "Payment confirmed for order " + orderId + " (12.50 USD) via ECOCASH."
    );
  }

  @Test
  void deliveryCompletedSkipsWhenOrderOwnerNotFound() throws Exception {
    UUID orderId = UUID.randomUUID();
    when(orderRecipientRepository.findById(orderId)).thenReturn(Optional.empty());

    DeliveryCompletedEvent event = new DeliveryCompletedEvent(
        UUID.randomUUID(),
        orderId,
        UUID.randomUUID(),
        OffsetDateTime.now()
    );

    consumer.onDeliveryCompleted(objectMapper.writeValueAsString(event));

    verify(notificationQueryService, never()).createNotification(any(), any(), any());
  }

  @Test
  void paymentRefundedCreatesNotificationForOrderOwner() throws Exception {
    UUID orderId = UUID.randomUUID();
    UUID userId = UUID.randomUUID();
    when(orderRecipientRepository.findById(orderId)).thenReturn(Optional.of(recipient(orderId, userId)));

    PaymentRefundedEvent event = new PaymentRefundedEvent(
        UUID.randomUUID(),
        orderId,
        new BigDecimal("7.25"),
        "USD",
        "CARD",
        "merchant_requested",
        OffsetDateTime.now()
    );

    consumer.onPaymentRefunded(objectMapper.writeValueAsString(event));

    verify(notificationQueryService).createNotification(
        userId,
        "PAYMENT_REFUNDED",
        "Payment refunded for order " + orderId + " (7.25 USD)."
    );
  }

  private OrderRecipientEntity recipient(UUID orderId, UUID userId) {
    OrderRecipientEntity entity = new OrderRecipientEntity();
    entity.setId(orderId);
    entity.setUserId(userId);
    return entity;
  }
}
