/**
 * BEGINNER GUIDE:
 * File: UserService.java
 * Role: Business service: applies core business rules and use cases.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.repository.UserRepository;
import com.xindongriji.backend.utils.UserContext;
import org.springframework.stereotype.Service;

/**
 * xindongriji-backend user service.
 */
@Service
public class UserService {
  private final UserRepository userRepository;

  public UserService(UserRepository userRepository) {
    this.userRepository = userRepository;
  }

  public User currentUser() {
    Long userId = UserContext.getUserId();
    if (userId == null) {
      throw new ApiException(ErrorCodes.UNAUTHORIZED, "unauthorized");
    }
    return userRepository.findById(userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "user not found"));
  }

  public User updatePhone(String phone) {
    User user = currentUser();
    if (userRepository.existsByPhoneAndIdNot(phone, user.getId())) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "phone already registered");
    }
    user.setPhone(phone);
    return userRepository.save(user);
  }
}
