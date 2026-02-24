package com.zimbite.delivery.consumer;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.delivery.service.DeliveryService;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentEventConsumerTest {

  @Mock
  private DeliveryService deliveryService;

  private ObjectMapper objectMapper;
  private PaymentEventConsumer consumer;

  @BeforeEach
  void setUp() {
    objectMapper = new ObjectMapper().findAndRegisterModules();
    consumer = new PaymentEventConsumer(objectMapper, deliveryService);
  }

  @Test
  void forwardsPaymentSucceededToDeliveryService() throws Exception {
    UUID orderId = UUID.randomUUID();
    PaymentSucceededEvent event = new PaymentSucceededEvent(
        UUID.randomUUID(),
        orderId,
        new BigDecimal("12.50"),
        "USD",
        "ECOCASH",
        OffsetDateTime.now()
    );

    String payload = objectMapper.writeValueAsString(event);
    consumer.onPaymentSucceeded(payload);

    verify(deliveryService, times(1)).assignDelivery(orderId);
  }

  @Test
  void ignoresInvalidPayload() {
    consumer.onPaymentSucceeded("{invalid-json");

    verify(deliveryService, never()).assignDelivery(any(UUID.class));
  }
}
