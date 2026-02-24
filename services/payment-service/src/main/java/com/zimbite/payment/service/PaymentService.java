package com.zimbite.payment.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.model.entity.PaymentCallbackEntity;
import com.zimbite.payment.model.entity.PaymentEntity;
import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import com.zimbite.payment.repository.PaymentCallbackRepository;
import com.zimbite.payment.repository.PaymentOutboxEventRepository;
import com.zimbite.payment.repository.PaymentRepository;
import com.zimbite.shared.messaging.Topics;
import com.zimbite.shared.messaging.contract.PaymentFailedEvent;
import com.zimbite.shared.messaging.contract.PaymentInitiatedEvent;
import com.zimbite.shared.messaging.contract.PaymentRefundedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PaymentService {

  private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

  private final PaymentRepository paymentRepository;
  private final PaymentCallbackRepository callbackRepository;
  private final PaymentOutboxEventRepository outboxEventRepository;
  private final CallbackSignatureVerifier callbackSignatureVerifier;
  private final ObjectMapper objectMapper;

  public PaymentService(
      PaymentRepository paymentRepository,
      PaymentCallbackRepository callbackRepository,
      PaymentOutboxEventRepository outboxEventRepository,
      CallbackSignatureVerifier callbackSignatureVerifier,
      ObjectMapper objectMapper
  ) {
    this.paymentRepository = paymentRepository;
    this.callbackRepository = callbackRepository;
    this.outboxEventRepository = outboxEventRepository;
    this.callbackSignatureVerifier = callbackSignatureVerifier;
    this.objectMapper = objectMapper;
  }

  @Transactional
  public PaymentResponse initiate(InitiatePaymentRequest request) {
    return initiate(request, null);
  }

  @Transactional
  public PaymentResponse initiate(InitiatePaymentRequest request, String idempotencyKey) {
    String normalizedIdempotencyKey = normalizeIdempotencyKey(idempotencyKey);
    if (normalizedIdempotencyKey != null) {
      PaymentEntity existing = paymentRepository.findByIdempotencyKey(normalizedIdempotencyKey).orElse(null);
      if (existing != null) {
        log.info("Reusing existing payment for idempotencyKey={}, paymentId={}",
            normalizedIdempotencyKey, existing.getId());
        return toResponse(existing);
      }
    }

    PaymentEntity payment = new PaymentEntity();
    payment.setId(UUID.randomUUID());
    payment.setOrderId(request.orderId());
    payment.setProvider(request.provider());
    payment.setStatus("PENDING");
    payment.setAmount(request.amount());
    payment.setCurrency(request.currency());
    payment.setIdempotencyKey(normalizedIdempotencyKey);
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
    if ("SUCCEEDED".equals(payment.getStatus())) {
      log.info("Ignoring duplicate success callback for paymentId={}", paymentId);
      return toResponse(payment);
    }
    if ("FAILED".equals(payment.getStatus())) {
      log.warn("Ignoring success callback for already failed paymentId={}", paymentId);
      return toResponse(payment);
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

  @Transactional
  public PaymentResponse markSucceededFromCallback(
      UUID paymentId,
      String provider,
      String callbackId,
      String callbackSignature
  ) {
    return markFromCallback(paymentId, provider, callbackId, callbackSignature, "SUCCESS", null);
  }

  @Transactional
  public PaymentResponse markFailed(UUID paymentId, String reason) {
    PaymentEntity payment = paymentRepository.findById(paymentId).orElse(null);
    if (payment == null) {
      return null;
    }
    if ("FAILED".equals(payment.getStatus())) {
      log.info("Ignoring duplicate failure callback for paymentId={}", paymentId);
      return toResponse(payment);
    }
    if ("SUCCEEDED".equals(payment.getStatus())) {
      log.warn("Ignoring failure callback for already succeeded paymentId={}", paymentId);
      return toResponse(payment);
    }

    payment.setStatus("FAILED");
    PaymentEntity saved = paymentRepository.save(payment);

    PaymentFailedEvent event = new PaymentFailedEvent(
        saved.getId(),
        saved.getOrderId(),
        saved.getAmount(),
        saved.getCurrency(),
        saved.getProvider(),
        normalizeFailureReason(reason),
        OffsetDateTime.now()
    );
    saveOutbox(saved.getId(), Topics.PAYMENT_FAILED, event);

    return toResponse(saved);
  }

  @Transactional
  public PaymentResponse markFailedFromCallback(
      UUID paymentId,
      String provider,
      String reason,
      String callbackId,
      String callbackSignature
  ) {
    return markFromCallback(paymentId, provider, callbackId, callbackSignature, "FAILURE", reason);
  }

  @Transactional
  public PaymentResponse markRefunded(UUID paymentId, String reason) {
    PaymentEntity payment = paymentRepository.findById(paymentId).orElse(null);
    if (payment == null) {
      return null;
    }
    if ("REFUNDED".equals(payment.getStatus())) {
      log.info("Ignoring duplicate refund callback for paymentId={}", paymentId);
      return toResponse(payment);
    }
    if (!"SUCCEEDED".equals(payment.getStatus())) {
      log.warn("Ignoring refund request for non-succeeded paymentId={}, status={}",
          paymentId, payment.getStatus());
      return toResponse(payment);
    }

    payment.setStatus("REFUNDED");
    PaymentEntity saved = paymentRepository.save(payment);

    PaymentRefundedEvent event = new PaymentRefundedEvent(
        saved.getId(),
        saved.getOrderId(),
        saved.getAmount(),
        saved.getCurrency(),
        saved.getProvider(),
        normalizeRefundReason(reason),
        OffsetDateTime.now()
    );
    saveOutbox(saved.getId(), Topics.PAYMENT_REFUNDED, event);

    return toResponse(saved);
  }

  private PaymentResponse markFromCallback(
      UUID paymentId,
      String provider,
      String callbackId,
      String callbackSignature,
      String outcome,
      String reason
  ) {
    String normalizedProvider = normalizeProvider(provider);
    String normalizedCallbackId = normalizeCallbackId(callbackId, paymentId, outcome);

    PaymentCallbackEntity existingCallback = callbackRepository
        .findByProviderAndCallbackId(normalizedProvider, normalizedCallbackId)
        .orElse(null);
    if (existingCallback != null) {
      log.info("Ignoring duplicate callback provider={}, callbackId={}", normalizedProvider, normalizedCallbackId);
      return paymentRepository.findById(paymentId).map(this::toResponse).orElse(null);
    }

    boolean signatureValid = callbackSignatureVerifier.verify(
        normalizedProvider,
        paymentId,
        outcome,
        callbackSignature
    );
    saveCallback(paymentId, normalizedProvider, normalizedCallbackId, outcome, signatureValid, reason);

    if (!signatureValid) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid callback signature");
    }

    PaymentEntity payment = paymentRepository.findById(paymentId).orElse(null);
    if (payment == null) {
      return null;
    }
    if (!normalizedProvider.equals(payment.getProvider())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Callback provider mismatch");
    }

    if ("SUCCESS".equals(outcome)) {
      return markSucceeded(paymentId);
    }
    return markFailed(paymentId, reason);
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

  private void saveCallback(
      UUID paymentId,
      String provider,
      String callbackId,
      String outcome,
      boolean signatureValid,
      String reason
  ) {
    PaymentCallbackEntity callback = new PaymentCallbackEntity();
    callback.setId(UUID.randomUUID());
    callback.setPaymentId(paymentId);
    callback.setProvider(provider);
    callback.setCallbackId(callbackId);
    callback.setOutcome(outcome);
    callback.setSignatureValid(signatureValid);
    callback.setReason(reason);
    callback.setCreatedAt(OffsetDateTime.now());
    callbackRepository.save(callback);
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

  private String normalizeIdempotencyKey(String idempotencyKey) {
    if (idempotencyKey == null) {
      return null;
    }
    String trimmed = idempotencyKey.trim();
    return trimmed.isEmpty() ? null : trimmed;
  }

  private String normalizeFailureReason(String reason) {
    if (reason == null) {
      return "provider_callback_failed";
    }
    String trimmed = reason.trim();
    return trimmed.isEmpty() ? "provider_callback_failed" : trimmed;
  }

  private String normalizeRefundReason(String reason) {
    if (reason == null) {
      return "merchant_requested";
    }
    String trimmed = reason.trim();
    return trimmed.isEmpty() ? "merchant_requested" : trimmed;
  }

  private String normalizeProvider(String provider) {
    if (provider == null || provider.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "provider is required");
    }
    String normalized = provider.trim().toUpperCase(Locale.ROOT);
    return switch (normalized) {
      case "ECOCASH", "ONEMONEY", "CARD" -> normalized;
      default -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported provider");
    };
  }

  private String normalizeCallbackId(String callbackId, UUID paymentId, String outcome) {
    if (callbackId == null || callbackId.isBlank()) {
      return ("auto:" + paymentId + ":" + outcome).toLowerCase(Locale.ROOT);
    }
    return callbackId.trim();
  }
}
