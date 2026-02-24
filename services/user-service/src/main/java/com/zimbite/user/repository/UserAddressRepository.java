package com.zimbite.user.repository;

import com.zimbite.user.model.entity.UserAddressEntity;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAddressRepository extends JpaRepository<UserAddressEntity, UUID> {
  List<UserAddressEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
