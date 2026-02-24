package com.zimbite.payment.repository;

import com.zimbite.payment.model.entity.PaymentCallbackEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentCallbackRepository extends JpaRepository<PaymentCallbackEntity, UUID> {
  Optional<PaymentCallbackEntity> findByProviderAndCallbackId(String provider, String callbackId);
}
