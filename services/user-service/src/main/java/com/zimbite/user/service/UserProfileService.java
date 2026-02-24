package com.zimbite.user.service;

import com.zimbite.user.model.dto.AddressRequest;
import com.zimbite.user.model.dto.AddressResponse;
import com.zimbite.user.model.dto.FavoriteItemRequest;
import com.zimbite.user.model.dto.FavoriteItemResponse;
import com.zimbite.user.model.dto.OrderHistoryItemResponse;
import com.zimbite.user.model.dto.UpdateProfileRequest;
import com.zimbite.user.model.dto.UserProfileResponse;
import com.zimbite.user.model.entity.UserAddressEntity;
import com.zimbite.user.model.entity.UserFavoriteItemEntity;
import com.zimbite.user.model.entity.UserEntity;
import com.zimbite.user.model.entity.UserOrderHistoryEntity;
import com.zimbite.user.repository.UserAddressRepository;
import com.zimbite.user.repository.UserFavoriteItemRepository;
import com.zimbite.user.repository.UserOrderHistoryRepository;
import com.zimbite.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class UserProfileService {

  private final UserRepository userRepository;
  private final UserAddressRepository userAddressRepository;
  private final UserFavoriteItemRepository userFavoriteItemRepository;
  private final UserOrderHistoryRepository userOrderHistoryRepository;

  public UserProfileService(
      UserRepository userRepository,
      UserAddressRepository userAddressRepository,
      UserFavoriteItemRepository userFavoriteItemRepository,
      UserOrderHistoryRepository userOrderHistoryRepository
  ) {
    this.userRepository = userRepository;
    this.userAddressRepository = userAddressRepository;
    this.userFavoriteItemRepository = userFavoriteItemRepository;
    this.userOrderHistoryRepository = userOrderHistoryRepository;
  }

  @Transactional
  public UserProfileResponse getCurrentProfile(UUID userId) {
    UserEntity user = getOrCreateUser(userId);
    return toResponse(user);
  }

  @Transactional
  public UserProfileResponse updateCurrentProfile(UUID userId, UpdateProfileRequest request) {
    UserEntity user = getOrCreateUser(userId);
    user.setFirstName(request.firstName());
    user.setLastName(request.lastName());
    user.setUpdatedAt(OffsetDateTime.now());
    return toResponse(userRepository.save(user));
  }

  @Transactional
  public List<AddressResponse> listAddresses(UUID userId) {
    getOrCreateUser(userId);
    return userAddressRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(this::toAddressResponse)
        .toList();
  }

  @Transactional
  public AddressResponse addAddress(UUID userId, AddressRequest request) {
    getOrCreateUser(userId);

    UserAddressEntity address = new UserAddressEntity();
    address.setId(UUID.randomUUID());
    address.setUserId(userId);
    address.setLabel(request.label());
    address.setLine1(request.line1());
    address.setLine2(request.line2());
    address.setCity(request.city());
    address.setArea(request.area());
    address.setLatitude(request.latitude());
    address.setLongitude(request.longitude());
    address.setCreatedAt(OffsetDateTime.now());
    return toAddressResponse(userAddressRepository.save(address));
  }

  @Transactional
  public List<FavoriteItemResponse> listFavorites(UUID userId) {
    getOrCreateUser(userId);
    return userFavoriteItemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .map(favorite -> new FavoriteItemResponse(favorite.getMenuItemId(), favorite.getCreatedAt()))
        .toList();
  }

  @Transactional
  public FavoriteItemResponse addFavorite(UUID userId, FavoriteItemRequest request) {
    getOrCreateUser(userId);

    UserFavoriteItemEntity existing = userFavoriteItemRepository
        .findByUserIdAndMenuItemId(userId, request.menuItemId())
        .orElse(null);
    if (existing != null) {
      return new FavoriteItemResponse(existing.getMenuItemId(), existing.getCreatedAt());
    }

    UserFavoriteItemEntity favorite = new UserFavoriteItemEntity();
    favorite.setId(UUID.randomUUID());
    favorite.setUserId(userId);
    favorite.setMenuItemId(request.menuItemId());
    favorite.setCreatedAt(OffsetDateTime.now());
    UserFavoriteItemEntity saved = userFavoriteItemRepository.save(favorite);
    return new FavoriteItemResponse(saved.getMenuItemId(), saved.getCreatedAt());
  }

  @Transactional
  public List<OrderHistoryItemResponse> listOrderHistory(UUID userId, int limit) {
    getOrCreateUser(userId);
    int safeLimit = Math.max(limit, 1);
    return userOrderHistoryRepository.findByUserIdOrderByPlacedAtDesc(userId).stream()
        .limit(safeLimit)
        .map(this::toOrderHistoryResponse)
        .toList();
  }

  private UserEntity getOrCreateUser(UUID userId) {
    return userRepository.findById(userId).orElseGet(() -> {
      UserEntity user = new UserEntity();
      user.setId(userId);
      user.setFirstName("New");
      user.setLastName("User");
      user.setEmail("user-" + userId + "@zimbite.local");
      user.setPhoneNumber("user-" + userId.toString().substring(0, 12));
      user.setCreatedAt(OffsetDateTime.now());
      user.setUpdatedAt(OffsetDateTime.now());
      return userRepository.save(user);
    });
  }

  private static UserProfileResponse toResponse(UserEntity user) {
    return new UserProfileResponse(
        user.getId(),
        user.getFirstName(),
        user.getLastName(),
        user.getEmail(),
        user.getPhoneNumber()
    );
  }

  private AddressResponse toAddressResponse(UserAddressEntity address) {
    return new AddressResponse(
        address.getId(),
        address.getLabel(),
        address.getLine1(),
        address.getLine2(),
        address.getCity(),
        address.getArea(),
        address.getLatitude(),
        address.getLongitude(),
        address.getCreatedAt()
    );
  }

  private OrderHistoryItemResponse toOrderHistoryResponse(UserOrderHistoryEntity entry) {
    return new OrderHistoryItemResponse(
        entry.getOrderId(),
        entry.getVendorId(),
        entry.getStatus(),
        entry.getTotalAmount(),
        entry.getCurrency(),
        entry.getPlacedAt()
    );
  }
}
