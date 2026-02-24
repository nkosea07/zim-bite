package com.zimbite.payment.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.zimbite.payment.model.entity.PaymentEntity;
import com.zimbite.payment.repository.PaymentRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentReconciliationJobTest {

  @Mock
  private PaymentRepository paymentRepository;

  @Mock
  private PaymentService paymentService;

  @Test
  void reconcilePendingPaymentsMarksStalePendingAsFailed() {
    PaymentEntity pending = new PaymentEntity();
    pending.setId(UUID.randomUUID());
    pending.setOrderId(UUID.randomUUID());
    pending.setProvider("ECOCASH");
    pending.setStatus("PENDING");
    pending.setAmount(new BigDecimal("12.00"));
    pending.setCurrency("USD");
    pending.setCreatedAt(OffsetDateTime.now().minusHours(2));

    when(paymentRepository.findByStatusAndCreatedAtBeforeOrderByCreatedAtAsc(
        eq("PENDING"), any(OffsetDateTime.class), any(org.springframework.data.domain.Pageable.class)))
        .thenReturn(List.of(pending));

    PaymentReconciliationJob job = new PaymentReconciliationJob(
        paymentRepository,
        paymentService,
        true,
        300,
        50
    );

    job.reconcilePendingPayments();

    verify(paymentService).markFailed(pending.getId(), "reconciliation_timeout");
  }
}
