package com.zimbite.user.service;

import com.zimbite.user.model.dto.UpdateProfileRequest;
import com.zimbite.user.model.dto.UserProfileResponse;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class UserProfileService {

  private UserProfileResponse current = new UserProfileResponse(
      UUID.fromString("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1"),
      "Tariro",
      "Moyo",
      "tariro@example.com",
      "+263771000001"
  );

  public UserProfileResponse getCurrentProfile() {
    return current;
  }

  public UserProfileResponse updateCurrentProfile(UpdateProfileRequest request) {
    current = new UserProfileResponse(
        current.id(),
        request.firstName(),
        request.lastName(),
        current.email(),
        current.phoneNumber()
    );
    return current;
  }
}
