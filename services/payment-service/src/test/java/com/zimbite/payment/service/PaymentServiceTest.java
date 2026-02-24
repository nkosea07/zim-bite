package com.zimbite.payment.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.model.entity.PaymentEntity;
import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import com.zimbite.payment.repository.PaymentOutboxEventRepository;
import com.zimbite.payment.repository.PaymentRepository;
import com.zimbite.shared.messaging.Topics;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

  @Mock
  private PaymentRepository paymentRepository;

  @Mock
  private PaymentOutboxEventRepository outboxEventRepository;

  private PaymentService paymentService;

  @BeforeEach
  void setUp() {
    paymentService = new PaymentService(
        paymentRepository,
        outboxEventRepository,
        new ObjectMapper().findAndRegisterModules()
    );
  }

  @Test
  void initiateReusesExistingPaymentForIdempotencyKey() {
    PaymentEntity existing = payment(
        UUID.randomUUID(),
        UUID.randomUUID(),
        "ECOCASH",
        "PENDING",
        new BigDecimal("15.00"),
        "USD"
    );
    existing.setIdempotencyKey("idem-123");
    when(paymentRepository.findByIdempotencyKey("idem-123")).thenReturn(Optional.of(existing));

    PaymentResponse response = paymentService.initiate(
        new InitiatePaymentRequest(existing.getOrderId(), "ECOCASH", existing.getAmount(), "USD"),
        "  idem-123 "
    );

    assertEquals(existing.getId(), response.paymentId());
    verify(paymentRepository, never()).save(any(PaymentEntity.class));
    verify(outboxEventRepository, never()).save(any(PaymentOutboxEventEntity.class));
  }

  @Test
  void initiateCreatesPaymentAndOutboxWhenIdempotencyKeyIsNew() {
    UUID orderId = UUID.randomUUID();
    when(paymentRepository.findByIdempotencyKey("idem-1")).thenReturn(Optional.empty());
    when(paymentRepository.save(any(PaymentEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(outboxEventRepository.save(any(PaymentOutboxEventEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));

    PaymentResponse response = paymentService.initiate(
        new InitiatePaymentRequest(orderId, "ONEMONEY", new BigDecimal("9.50"), "USD"),
        "idem-1"
    );

    assertEquals(orderId, response.orderId());
    assertEquals("PENDING", response.status());
    assertEquals("ONEMONEY", response.provider());

    ArgumentCaptor<PaymentEntity> paymentCaptor = ArgumentCaptor.forClass(PaymentEntity.class);
    verify(paymentRepository).save(paymentCaptor.capture());
    assertEquals("idem-1", paymentCaptor.getValue().getIdempotencyKey());

    ArgumentCaptor<PaymentOutboxEventEntity> outboxCaptor = ArgumentCaptor.forClass(PaymentOutboxEventEntity.class);
    verify(outboxEventRepository).save(outboxCaptor.capture());
    assertEquals(Topics.PAYMENT_INITIATED, outboxCaptor.getValue().getEventType());
  }

  @Test
  void markSucceededIgnoresDuplicateSuccessCallback() {
    UUID paymentId = UUID.randomUUID();
    PaymentEntity existing = payment(
        paymentId,
        UUID.randomUUID(),
        "ECOCASH",
        "SUCCEEDED",
        new BigDecimal("12.00"),
        "USD"
    );
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(existing));

    PaymentResponse response = paymentService.markSucceeded(paymentId);

    assertEquals("SUCCEEDED", response.status());
    verify(paymentRepository, never()).save(any(PaymentEntity.class));
    verify(outboxEventRepository, never()).save(any(PaymentOutboxEventEntity.class));
  }

  @Test
  void markFailedUpdatesStatusAndEmitsFailedEvent() {
    UUID paymentId = UUID.randomUUID();
    PaymentEntity existing = payment(
        paymentId,
        UUID.randomUUID(),
        "CARD",
        "PENDING",
        new BigDecimal("20.00"),
        "USD"
    );
    when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(existing));
    when(paymentRepository.save(any(PaymentEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));
    when(outboxEventRepository.save(any(PaymentOutboxEventEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));

    PaymentResponse response = paymentService.markFailed(paymentId, "declined");

    assertEquals("FAILED", response.status());

    ArgumentCaptor<PaymentOutboxEventEntity> outboxCaptor = ArgumentCaptor.forClass(PaymentOutboxEventEntity.class);
    verify(outboxEventRepository).save(outboxCaptor.capture());
    assertEquals(Topics.PAYMENT_FAILED, outboxCaptor.getValue().getEventType());
    assertTrue(outboxCaptor.getValue().getPayload().contains("declined"));
  }

  private PaymentEntity payment(
      UUID paymentId,
      UUID orderId,
      String provider,
      String status,
      BigDecimal amount,
      String currency
  ) {
    PaymentEntity payment = new PaymentEntity();
    payment.setId(paymentId);
    payment.setOrderId(orderId);
    payment.setProvider(provider);
    payment.setStatus(status);
    payment.setAmount(amount);
    payment.setCurrency(currency);
    payment.setCreatedAt(OffsetDateTime.now());
    return payment;
  }
}
