package com.zimbite.user.service;

import com.zimbite.user.model.dto.UpdateProfileRequest;
import com.zimbite.user.model.dto.UserProfileResponse;
import com.zimbite.user.model.entity.UserEntity;
import com.zimbite.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class UserProfileService {

  private static final UUID DEMO_USER_ID = UUID.fromString("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1");

  private final UserRepository userRepository;

  public UserProfileService(UserRepository userRepository) {
    this.userRepository = userRepository;
  }

  @Transactional
  public UserProfileResponse getCurrentProfile() {
    UserEntity user = getOrCreateDemoUser();
    return toResponse(user);
  }

  @Transactional
  public UserProfileResponse updateCurrentProfile(UpdateProfileRequest request) {
    UserEntity user = getOrCreateDemoUser();
    user.setFirstName(request.firstName());
    user.setLastName(request.lastName());
    user.setUpdatedAt(OffsetDateTime.now());
    return toResponse(userRepository.save(user));
  }

  private UserEntity getOrCreateDemoUser() {
    return userRepository.findById(DEMO_USER_ID).orElseGet(() -> {
      UserEntity user = new UserEntity();
      user.setId(DEMO_USER_ID);
      user.setFirstName("Tariro");
      user.setLastName("Moyo");
      user.setEmail("tariro@example.com");
      user.setPhoneNumber("+263771000001");
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
}
