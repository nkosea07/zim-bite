package com.zimbite.delivery.consumer;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.KafkaTemplate;

@ExtendWith(MockitoExtension.class)
class PaymentEventConsumerTest {

  @Mock
  private KafkaTemplate<String, String> kafkaTemplate;

  private ObjectMapper objectMapper;
  private PaymentEventConsumer consumer;

  @BeforeEach
  void setUp() {
    objectMapper = new ObjectMapper().findAndRegisterModules();
    consumer = new PaymentEventConsumer(objectMapper, kafkaTemplate);
  }

  @Test
  void ignoresReplayOfPaymentSucceededForSameOrder() throws Exception {
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
    when(kafkaTemplate.send(anyString(), anyString(), anyString()))
        .thenReturn(CompletableFuture.completedFuture(null));

    consumer.onPaymentSucceeded(payload);
    consumer.onPaymentSucceeded(payload);

    verify(kafkaTemplate, times(1))
        .send(eq(Topics.DELIVERY_ASSIGNED), eq(orderId.toString()), anyString());
  }
}
