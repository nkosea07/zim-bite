package com.zimbite.auth.repository;

import com.zimbite.auth.model.entity.AuthUserEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuthUserRepository extends JpaRepository<AuthUserEntity, UUID> {

    Optional<AuthUserEntity> findByEmail(String email);

    Optional<AuthUserEntity> findByPhoneNumber(String phoneNumber);
}
