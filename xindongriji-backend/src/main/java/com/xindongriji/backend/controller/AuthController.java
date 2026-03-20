/**
 * BEGINNER GUIDE:
 * File: AuthController.java
 * Role: API controller: receives HTTP requests and returns API responses.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller;

import com.xindongriji.backend.config.JwtProperties;
import com.xindongriji.backend.controller.dto.LoginRequest;
import com.xindongriji.backend.controller.dto.LoginResponse;
import com.xindongriji.backend.controller.dto.RegisterRequest;
import com.xindongriji.backend.controller.dto.UserResponse;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.service.AuthService;
import com.xindongriji.backend.utils.ApiResponse;
import javax.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * xindongriji-backend auth controller.
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  private final AuthService authService;
  private final JwtProperties jwtProperties;

  public AuthController(AuthService authService, JwtProperties jwtProperties) {
    this.authService = authService;
    this.jwtProperties = jwtProperties;
  }

  @PostMapping("/register")
  public ApiResponse<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
    User user = authService.register(request.getPhone(), request.getPassword());
    return ApiResponse.ok(new UserResponse(user.getId(), user.getPhone()));
  }

  @PostMapping("/login")
  public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
    String token = authService.login(request.getPhone(), request.getPassword());
    return ApiResponse.ok(new LoginResponse(token, "Bearer", jwtProperties.getAccessTokenExpireSeconds()));
  }
}
