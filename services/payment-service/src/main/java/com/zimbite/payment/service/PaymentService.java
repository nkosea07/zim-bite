package com.zimbite.payment.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.model.entity.PaymentEntity;
import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import com.zimbite.payment.repository.PaymentOutboxEventRepository;
import com.zimbite.payment.repository.PaymentRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.PaymentInitiatedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

  private final PaymentRepository paymentRepository;
  private final PaymentOutboxEventRepository outboxEventRepository;
  private final ObjectMapper objectMapper;

  public PaymentService(
      PaymentRepository paymentRepository,
      PaymentOutboxEventRepository outboxEventRepository,
      ObjectMapper objectMapper
  ) {
    this.paymentRepository = paymentRepository;
    this.outboxEventRepository = outboxEventRepository;
    this.objectMapper = objectMapper;
  }

  @Transactional
  public PaymentResponse initiate(InitiatePaymentRequest request) {
    PaymentEntity payment = new PaymentEntity();
    payment.setId(UUID.randomUUID());
    payment.setOrderId(request.orderId());
    payment.setProvider(request.provider());
    payment.setStatus("PENDING");
    payment.setAmount(request.amount());
    payment.setCurrency(request.currency());
    payment.setCreatedAt(OffsetDateTime.now());

    PaymentEntity saved = paymentRepository.save(payment);

    PaymentInitiatedEvent event = new PaymentInitiatedEvent(
        saved.getId(),
        saved.getOrderId(),
        saved.getAmount(),
        saved.getCurrency(),
        saved.getProvider(),
        OffsetDateTime.now()
    );
    saveOutbox(saved.getId(), Topics.PAYMENT_INITIATED, event);

    return toResponse(saved);
  }

  @Transactional
  public PaymentResponse markSucceeded(UUID paymentId) {
    PaymentEntity payment = paymentRepository.findById(paymentId).orElse(null);
    if (payment == null) {
      return null;
    }

    payment.setStatus("SUCCEEDED");
    PaymentEntity saved = paymentRepository.save(payment);

    PaymentSucceededEvent event = new PaymentSucceededEvent(
        saved.getId(),
        saved.getOrderId(),
        saved.getAmount(),
        saved.getCurrency(),
        saved.getProvider(),
        OffsetDateTime.now()
    );
    saveOutbox(saved.getId(), Topics.PAYMENT_SUCCEEDED, event);

    return toResponse(saved);
  }

  private PaymentResponse toResponse(PaymentEntity payment) {
    return new PaymentResponse(
        payment.getId(),
        payment.getOrderId(),
        payment.getProvider(),
        payment.getStatus(),
        payment.getAmount(),
        payment.getCurrency()
    );
  }

  private void saveOutbox(UUID aggregateId, String eventType, Object payload) {
    PaymentOutboxEventEntity outbox = new PaymentOutboxEventEntity();
    outbox.setId(UUID.randomUUID());
    outbox.setAggregateId(aggregateId);
    outbox.setEventType(eventType);
    outbox.setPayload(serialize(payload));
    outbox.setPublished(false);
    outbox.setCreatedAt(OffsetDateTime.now());
    outboxEventRepository.save(outbox);
  }

  private String serialize(Object payload) {
    try {
      return objectMapper.writeValueAsString(payload);
    } catch (JsonProcessingException e) {
      throw new IllegalStateException("Failed to serialize payment event payload", e);
    }
  }
}
