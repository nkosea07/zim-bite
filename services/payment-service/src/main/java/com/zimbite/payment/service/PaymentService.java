package com.zimbite.payment.service;

import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.shared.messaging.contract.PaymentInitiatedEvent;
import com.zimbite.shared.messaging.contract.PaymentSucceededEvent;
import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

  private final Map<UUID, PaymentResponse> payments = new ConcurrentHashMap<>();
  private final Map<UUID, PaymentInitiatedEvent> initiatedOutbox = new ConcurrentHashMap<>();
  private final Map<UUID, PaymentSucceededEvent> succeededOutbox = new ConcurrentHashMap<>();

  public PaymentResponse initiate(InitiatePaymentRequest request) {
    UUID paymentId = UUID.randomUUID();
    PaymentResponse response = new PaymentResponse(
        paymentId,
        request.orderId(),
        request.provider(),
        "PENDING",
        request.amount(),
        request.currency()
    );

    payments.put(paymentId, response);
    initiatedOutbox.put(paymentId, new PaymentInitiatedEvent(
        paymentId,
        request.orderId(),
        request.amount(),
        request.currency(),
        request.provider(),
        OffsetDateTime.now()
    ));

    return response;
  }

  public PaymentResponse markSucceeded(UUID paymentId) {
    PaymentResponse current = payments.get(paymentId);
    if (current == null) {
      return null;
    }

    PaymentResponse updated = new PaymentResponse(
        current.paymentId(),
        current.orderId(),
        current.provider(),
        "SUCCEEDED",
        current.amount(),
        current.currency()
    );

    payments.put(paymentId, updated);
    succeededOutbox.put(paymentId, new PaymentSucceededEvent(
        updated.paymentId(),
        updated.orderId(),
        updated.amount(),
        updated.currency(),
        updated.provider(),
        OffsetDateTime.now()
    ));

    return updated;
  }
}
