package com.zimbite.user.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.zimbite.user.model.dto.FavoriteItemRequest;
import com.zimbite.user.model.dto.FavoriteItemResponse;
import com.zimbite.user.model.entity.UserEntity;
import com.zimbite.user.model.entity.UserFavoriteItemEntity;
import com.zimbite.user.repository.UserAddressRepository;
import com.zimbite.user.repository.UserFavoriteItemRepository;
import com.zimbite.user.repository.UserOrderHistoryRepository;
import com.zimbite.user.repository.UserRepository;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UserProfileServiceTest {

  @Mock
  private UserRepository userRepository;

  @Mock
  private UserAddressRepository userAddressRepository;

  @Mock
  private UserFavoriteItemRepository userFavoriteItemRepository;

  @Mock
  private UserOrderHistoryRepository userOrderHistoryRepository;

  private UserProfileService service;

  @BeforeEach
  void setUp() {
    service = new UserProfileService(
        userRepository,
        userAddressRepository,
        userFavoriteItemRepository,
        userOrderHistoryRepository
    );
  }

  @Test
  void addFavoriteReturnsExistingRecordWithoutDuplicateSave() {
    UUID userId = UUID.randomUUID();
    UUID menuItemId = UUID.randomUUID();

    UserEntity user = new UserEntity();
    user.setId(userId);
    user.setFirstName("A");
    user.setLastName("B");
    user.setEmail("a@zimbite.local");
    user.setPhoneNumber("+1");
    user.setCreatedAt(OffsetDateTime.now());
    user.setUpdatedAt(OffsetDateTime.now());

    UserFavoriteItemEntity existing = new UserFavoriteItemEntity();
    existing.setId(UUID.randomUUID());
    existing.setUserId(userId);
    existing.setMenuItemId(menuItemId);
    existing.setCreatedAt(OffsetDateTime.now());

    when(userRepository.findById(userId)).thenReturn(Optional.of(user));
    when(userFavoriteItemRepository.findByUserIdAndMenuItemId(userId, menuItemId)).thenReturn(Optional.of(existing));

    FavoriteItemResponse response = service.addFavorite(userId, new FavoriteItemRequest(menuItemId));

    assertEquals(menuItemId, response.menuItemId());
    verify(userFavoriteItemRepository, never()).save(org.mockito.ArgumentMatchers.any(UserFavoriteItemEntity.class));
  }
}
