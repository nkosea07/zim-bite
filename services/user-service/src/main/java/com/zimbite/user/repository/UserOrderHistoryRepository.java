package com.zimbite.user.repository;

import com.zimbite.user.model.entity.UserOrderHistoryEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserOrderHistoryRepository extends JpaRepository<UserOrderHistoryEntity, UUID> {
  List<UserOrderHistoryEntity> findByUserIdOrderByPlacedAtDesc(UUID userId);
}
