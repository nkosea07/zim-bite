package com.zimbite.payment.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.zimbite.payment.model.dto.SavePaymentMethodRequest;
import com.zimbite.payment.model.entity.PaymentMethodEntity;
import com.zimbite.payment.repository.PaymentMethodRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PaymentMethodServiceTest {

  @Mock
  private PaymentMethodRepository paymentMethodRepository;

  private PaymentMethodService paymentMethodService;

  @BeforeEach
  void setUp() {
    paymentMethodService = new PaymentMethodService(paymentMethodRepository);
  }

  @Test
  void saveMethodMarksFirstMethodAsDefault() {
    UUID userId = UUID.randomUUID();
    when(paymentMethodRepository.findByUserIdAndProviderAndTokenReference(userId, "ECOCASH", "tok-1"))
        .thenReturn(Optional.empty());
    when(paymentMethodRepository.countByUserId(userId)).thenReturn(0L);
    when(paymentMethodRepository.save(org.mockito.ArgumentMatchers.any(PaymentMethodEntity.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    var response = paymentMethodService.saveMethod(
        userId,
        new SavePaymentMethodRequest("ecocash", "tok-1", "0123")
    );

    assertEquals("ECOCASH", response.provider());
    assertTrue(response.isDefault());
  }

  @Test
  void saveMethodReusesExistingMethodByToken() {
    UUID userId = UUID.randomUUID();
    UUID methodId = UUID.randomUUID();
    PaymentMethodEntity existing = new PaymentMethodEntity();
    existing.setId(methodId);
    existing.setUserId(userId);
    existing.setProvider("CARD");
    existing.setTokenReference("token-abc");
    existing.setLast4("4242");
    existing.setDefault(false);
    existing.setCreatedAt(OffsetDateTime.now().minusDays(2));
    existing.setUpdatedAt(OffsetDateTime.now().minusDays(2));

    when(paymentMethodRepository.findByUserIdAndProviderAndTokenReference(userId, "CARD", "token-abc"))
        .thenReturn(Optional.of(existing));
    when(paymentMethodRepository.save(existing)).thenReturn(existing);

    var response = paymentMethodService.saveMethod(
        userId,
        new SavePaymentMethodRequest("card", "token-abc", "1111")
    );

    assertEquals(methodId, response.paymentMethodId());
    assertEquals("1111", response.last4());
    verify(paymentMethodRepository, never()).countByUserId(userId);
  }

  @Test
  void listMethodsReturnsStoredMethods() {
    UUID userId = UUID.randomUUID();
    PaymentMethodEntity method = new PaymentMethodEntity();
    method.setId(UUID.randomUUID());
    method.setUserId(userId);
    method.setProvider("ONEMONEY");
    method.setLast4("9999");
    method.setDefault(true);

    when(paymentMethodRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId))
        .thenReturn(List.of(method));

    var methods = paymentMethodService.listMethods(userId);
    assertEquals(1, methods.size());
    assertEquals("ONEMONEY", methods.getFirst().provider());
  }
}
