package com.zimbite.user.repository;

import com.zimbite.user.model.entity.UserFavoriteItemEntity;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserFavoriteItemRepository extends JpaRepository<UserFavoriteItemEntity, UUID> {
  List<UserFavoriteItemEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);

  Optional<UserFavoriteItemEntity> findByUserIdAndMenuItemId(UUID userId, UUID menuItemId);
}
