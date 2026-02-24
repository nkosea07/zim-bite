package com.zimbite.payment.service;

import com.zimbite.payment.model.entity.PaymentEntity;
import com.zimbite.payment.repository.PaymentRepository;
import java.time.OffsetDateTime;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class PaymentReconciliationJob {

  private static final Logger log = LoggerFactory.getLogger(PaymentReconciliationJob.class);

  private final PaymentRepository paymentRepository;
  private final PaymentService paymentService;
  private final boolean enabled;
  private final int staleAfterSeconds;
  private final int batchSize;

  public PaymentReconciliationJob(
      PaymentRepository paymentRepository,
      PaymentService paymentService,
      @Value("${payment.reconciliation.enabled:true}") boolean enabled,
      @Value("${payment.reconciliation.stale-after-seconds:900}") int staleAfterSeconds,
      @Value("${payment.reconciliation.batch-size:200}") int batchSize
  ) {
    this.paymentRepository = paymentRepository;
    this.paymentService = paymentService;
    this.enabled = enabled;
    this.staleAfterSeconds = staleAfterSeconds;
    this.batchSize = batchSize;
  }

  @Scheduled(fixedDelayString = "${payment.reconciliation.fixed-delay-ms:60000}")
  @Transactional
  public void reconcilePendingPayments() {
    if (!enabled) {
      return;
    }

    OffsetDateTime cutoff = OffsetDateTime.now().minusSeconds(Math.max(60, staleAfterSeconds));
    List<PaymentEntity> stalePending = paymentRepository.findByStatusAndCreatedAtBeforeOrderByCreatedAtAsc(
        "PENDING",
        cutoff,
        PageRequest.of(0, Math.max(1, batchSize))
    );

    stalePending.forEach(payment -> {
      paymentService.markFailed(payment.getId(), "reconciliation_timeout");
      log.warn("Marked stale pending payment as failed: paymentId={}, orderId={}",
          payment.getId(), payment.getOrderId());
    });
  }
}
