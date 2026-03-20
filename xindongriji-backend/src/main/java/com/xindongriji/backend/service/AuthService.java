/**
 * BEGINNER GUIDE:
 * File: AuthService.java
 * Role: Business service: applies core business rules and use cases.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.service;

import com.xindongriji.backend.config.JwtProperties;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.repository.UserRepository;
import com.xindongriji.backend.utils.JwtUtil;
import com.xindongriji.backend.utils.PasswordUtil;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * xindongriji-backend auth service.
 */
@Service
public class AuthService {
  private final UserRepository userRepository;
  private final JwtProperties jwtProperties;

  public AuthService(UserRepository userRepository, JwtProperties jwtProperties) {
    this.userRepository = userRepository;
    this.jwtProperties = jwtProperties;
  }

  @Transactional
  public User register(String phone, String password) {
    Optional<User> existing = userRepository.findByPhone(phone);
    if (existing.isPresent()) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "phone already registered");
    }
    User user = new User();
    user.setPhone(phone);
    user.setPasswordHash(PasswordUtil.hash(password));
    return userRepository.save(user);
  }

  public String login(String phone, String password) {
    User user = userRepository.findByPhone(phone)
      .orElseThrow(() -> new ApiException(ErrorCodes.BAD_REQUEST, "invalid credentials"));
    if (!PasswordUtil.verify(password, user.getPasswordHash())) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "invalid credentials");
    }
    return JwtUtil.generateToken(String.valueOf(user.getId()), jwtProperties.getSecret(),
      jwtProperties.getAccessTokenExpireSeconds());
  }
}
