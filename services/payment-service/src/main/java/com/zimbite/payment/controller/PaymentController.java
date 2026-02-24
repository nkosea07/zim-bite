package com.zimbite.payment.controller;

import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.model.dto.SavePaymentMethodRequest;
import com.zimbite.payment.service.PaymentService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {

  private final PaymentService paymentService;

  public PaymentController(PaymentService paymentService) {
    this.paymentService = paymentService;
  }

  @PostMapping("/initiate")
  public ResponseEntity<PaymentResponse> initiate(
      @RequestHeader("Idempotency-Key") String idempotencyKey,
      @Valid @RequestBody InitiatePaymentRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED).body(paymentService.initiate(request, idempotencyKey));
  }

  @PostMapping("/callbacks/{provider}/{paymentId}/success")
  public ResponseEntity<PaymentResponse> callbackSuccess(@PathVariable String provider, @PathVariable UUID paymentId) {
    PaymentResponse response = paymentService.markSucceeded(paymentId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PostMapping("/callbacks/{provider}/{paymentId}/failure")
  public ResponseEntity<PaymentResponse> callbackFailure(
      @PathVariable String provider,
      @PathVariable UUID paymentId,
      @RequestParam(name = "reason", required = false) String reason
  ) {
    PaymentResponse response = paymentService.markFailed(paymentId, reason);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PostMapping("/refunds/{paymentId}")
  public ResponseEntity<PaymentResponse> refund(
      @PathVariable UUID paymentId,
      @RequestParam(name = "reason", required = false) String reason
  ) {
    PaymentResponse response = paymentService.markRefunded(paymentId, reason);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @GetMapping("/methods")
  public ResponseEntity<List<Map<String, String>>> listMethods() {
    return ResponseEntity.ok(List.of(
        Map.of("paymentMethodId", "pm-ecocash-default", "provider", "ECOCASH", "last4", "0001"),
        Map.of("paymentMethodId", "pm-card-default", "provider", "CARD", "last4", "4242")
    ));
  }

  @PostMapping("/methods")
  public ResponseEntity<Map<String, String>> saveMethod(@Valid @RequestBody SavePaymentMethodRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
        "paymentMethodId", UUID.randomUUID().toString(),
        "provider", request.provider(),
        "last4", request.last4(),
        "status", "saved"
    ));
  }
}
