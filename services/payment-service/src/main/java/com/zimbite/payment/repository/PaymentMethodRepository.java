package com.zimbite.payment.repository;

import com.zimbite.payment.model.entity.PaymentMethodEntity;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentMethodRepository extends JpaRepository<PaymentMethodEntity, UUID> {
  List<PaymentMethodEntity> findByUserIdOrderByIsDefaultDescCreatedAtDesc(UUID userId);

  Optional<PaymentMethodEntity> findByUserIdAndProviderAndTokenReference(
      UUID userId,
      String provider,
      String tokenReference
  );

  long countByUserId(UUID userId);
}
