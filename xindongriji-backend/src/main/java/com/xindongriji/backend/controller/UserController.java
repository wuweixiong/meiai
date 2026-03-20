/**
 * BEGINNER GUIDE:
 * File: UserController.java
 * Role: API controller: receives HTTP requests and returns API responses.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller;

import com.xindongriji.backend.controller.dto.UserResponse;
import com.xindongriji.backend.controller.dto.UserUpdateRequest;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.service.UserService;
import com.xindongriji.backend.utils.ApiResponse;
import javax.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * xindongriji-backend user controller.
 */
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
  private final UserService userService;

  public UserController(UserService userService) {
    this.userService = userService;
  }

  @GetMapping("/me")
  public ApiResponse<UserResponse> me() {
    User user = userService.currentUser();
    return ApiResponse.ok(new UserResponse(user.getId(), user.getPhone()));
  }

  @PutMapping("/me")
  public ApiResponse<UserResponse> update(@Valid @RequestBody UserUpdateRequest request) {
    User user = userService.updatePhone(request.getPhone());
    return ApiResponse.ok(new UserResponse(user.getId(), user.getPhone()));
  }
}
