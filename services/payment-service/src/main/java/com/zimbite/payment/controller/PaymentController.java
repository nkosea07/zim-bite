package com.zimbite.payment.controller;

import com.zimbite.payment.model.dto.InitiatePaymentRequest;
import com.zimbite.payment.model.dto.PaymentResponse;
import com.zimbite.payment.service.PaymentService;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
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
  public ResponseEntity<PaymentResponse> initiate(@Valid @RequestBody InitiatePaymentRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(paymentService.initiate(request));
  }

  @PostMapping("/callbacks/{provider}/{paymentId}/success")
  public ResponseEntity<PaymentResponse> callbackSuccess(@PathVariable String provider, @PathVariable UUID paymentId) {
    PaymentResponse response = paymentService.markSucceeded(paymentId);
    if (response == null) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(response);
  }
}
