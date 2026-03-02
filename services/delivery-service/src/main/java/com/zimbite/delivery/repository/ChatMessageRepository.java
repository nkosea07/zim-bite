package com.zimbite.delivery.repository;

import com.zimbite.delivery.model.entity.ChatMessageEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, UUID> {
    List<ChatMessageEntity> findTop50ByDeliveryIdOrderBySentAtDesc(UUID deliveryId);
}
