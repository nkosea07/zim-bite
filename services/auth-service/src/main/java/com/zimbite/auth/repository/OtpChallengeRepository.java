package com.zimbite.auth.repository;

import com.zimbite.auth.model.entity.OtpChallengeEntity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OtpChallengeRepository extends JpaRepository<OtpChallengeEntity, UUID> {
  Optional<OtpChallengeEntity> findFirstByPrincipalOrderByCreatedAtDesc(String principal);
}
