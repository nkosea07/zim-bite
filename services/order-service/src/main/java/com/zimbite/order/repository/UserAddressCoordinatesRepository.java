package com.zimbite.order.repository;

import com.zimbite.order.model.entity.UserAddressCoordinatesEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAddressCoordinatesRepository extends JpaRepository<UserAddressCoordinatesEntity, UUID> {

  Optional<UserAddressCoordinatesEntity> findByIdAndUserId(UUID id, UUID userId);
}
