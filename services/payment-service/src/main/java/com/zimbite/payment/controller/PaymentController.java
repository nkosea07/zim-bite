package com.zimbite.payment.controller;

import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentMethodResponse;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.model.dto.SavePaymentMethodRequest;
import com.zimbite.payment.model.dto.SavePaymentMethodResponse;
import com.zimbite.payment.service.PaymentMethodService;
import com.zimbite.payment.service.PaymentService;
import com.zimbite.shared.security.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
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
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {

  private final PaymentService paymentService;
  private final PaymentMethodService paymentMethodService;

  public PaymentController(PaymentService paymentService, PaymentMethodService paymentMethodService) {
    this.paymentService = paymentService;
    this.paymentMethodService = paymentMethodService;
  }

  @PostMapping("/initiate")
  public ResponseEntity<PaymentResponse> initiate(
      @RequestHeader("Idempotency-Key") String idempotencyKey,
      @Valid @RequestBody InitiatePaymentRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED).body(paymentService.initiate(request, idempotencyKey));
  }

  @PostMapping("/callbacks/{provider}/{paymentId}/success")
  public ResponseEntity<PaymentResponse> callbackSuccess(
      @PathVariable String provider,
      @PathVariable UUID paymentId,
      @RequestHeader(name = "X-Callback-Id", required = false) String callbackId,
      @RequestHeader(name = "X-Callback-Signature", required = false) String callbackSignature
  ) {
    PaymentResponse response = paymentService.markSucceededFromCallback(
        paymentId,
        provider,
        callbackId,
        callbackSignature
    );
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }

  @PostMapping("/callbacks/{provider}/{paymentId}/failure")
  public ResponseEntity<PaymentResponse> callbackFailure(
      @PathVariable String provider,
      @PathVariable UUID paymentId,
      @RequestHeader(name = "X-Callback-Id", required = false) String callbackId,
      @RequestHeader(name = "X-Callback-Signature", required = false) String callbackSignature,
      @RequestParam(name = "reason", required = false) String reason
  ) {
    PaymentResponse response = paymentService.markFailedFromCallback(
        paymentId,
        provider,
        reason,
        callbackId,
        callbackSignature
    );
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
  public ResponseEntity<List<PaymentMethodResponse>> listMethods(HttpServletRequest request) {
    return ResponseEntity.ok(paymentMethodService.listMethods(currentUserId(request)));
  }

  @PostMapping("/methods")
  public ResponseEntity<SavePaymentMethodResponse> saveMethod(
      HttpServletRequest servletRequest,
      @Valid @RequestBody SavePaymentMethodRequest request
  ) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(paymentMethodService.saveMethod(currentUserId(servletRequest), request));
  }

  private UUID currentUserId(HttpServletRequest request) {
    return UserContext.getUserId(request)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing user context"));
  }
}
