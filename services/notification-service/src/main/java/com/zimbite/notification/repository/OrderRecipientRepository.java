package com.zimbite.notification.repository;

import com.zimbite.notification.model.entity.OrderRecipientEntity;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRecipientRepository extends JpaRepository<OrderRecipientEntity, UUID> {
}
