package com.zimbite.payment.service;

import com.zimbite.payment.model.dto.PaymentMethodResponse;
import com.zimbite.payment.model.dto.SavePaymentMethodRequest;
import com.zimbite.payment.model.dto.SavePaymentMethodResponse;
import com.zimbite.payment.model.entity.PaymentMethodEntity;
import com.zimbite.payment.repository.PaymentMethodRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PaymentMethodService {

  private static final Set<String> SUPPORTED_PROVIDERS = Set.of("ECOCASH", "ONEMONEY", "CARD");

  private final PaymentMethodRepository paymentMethodRepository;

  public PaymentMethodService(PaymentMethodRepository paymentMethodRepository) {
    this.paymentMethodRepository = paymentMethodRepository;
  }

  @Transactional(readOnly = true)
  public List<PaymentMethodResponse> listMethods(UUID userId) {
    return paymentMethodRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId).stream()
        .map(this::toResponse)
        .toList();
  }

  @Transactional
  public SavePaymentMethodResponse saveMethod(UUID userId, SavePaymentMethodRequest request) {
    String provider = normalizeProvider(request.provider());
    String tokenReference = required(request.tokenReference(), "tokenReference");
    String last4 = required(request.last4(), "last4");
    OffsetDateTime now = OffsetDateTime.now();

    PaymentMethodEntity method = paymentMethodRepository
        .findByUserIdAndProviderAndTokenReference(userId, provider, tokenReference)
        .orElseGet(() -> createMethod(userId, provider, tokenReference, now));

    method.setLast4(last4);
    method.setUpdatedAt(now);

    PaymentMethodEntity saved = paymentMethodRepository.save(method);
    return new SavePaymentMethodResponse(
        saved.getId(),
        saved.getProvider(),
        saved.getLast4(),
        "saved",
        saved.isDefault()
    );
  }

  private PaymentMethodEntity createMethod(UUID userId, String provider, String tokenReference, OffsetDateTime now) {
    PaymentMethodEntity method = new PaymentMethodEntity();
    method.setId(UUID.randomUUID());
    method.setUserId(userId);
    method.setProvider(provider);
    method.setTokenReference(tokenReference);
    method.setDefault(paymentMethodRepository.countByUserId(userId) == 0);
    method.setCreatedAt(now);
    method.setUpdatedAt(now);
    return method;
  }

  private PaymentMethodResponse toResponse(PaymentMethodEntity method) {
    return new PaymentMethodResponse(
        method.getId(),
        method.getProvider(),
        method.getLast4(),
        method.isDefault()
    );
  }

  private String normalizeProvider(String provider) {
    String normalized = required(provider, "provider").toUpperCase(Locale.ROOT);
    if (!SUPPORTED_PROVIDERS.contains(normalized)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported provider");
    }
    return normalized;
  }

  private String required(String value, String field) {
    if (value == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, field + " is required");
    }
    String trimmed = value.trim();
    if (trimmed.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, field + " is required");
    }
    return trimmed;
  }
}
