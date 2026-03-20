/**
 * BEGINNER GUIDE:
 * File: UserResponse.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * xindongriji-backend user response.
 */
@Data
@AllArgsConstructor
public class UserResponse {
  private Long userId;
  private String phone;
}
