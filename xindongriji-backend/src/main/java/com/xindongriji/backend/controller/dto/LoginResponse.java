/**
 * BEGINNER GUIDE:
 * File: LoginResponse.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * xindongriji-backend login response.
 */
@Data
@AllArgsConstructor
public class LoginResponse {
  private String accessToken;
  private String tokenType;
  private long expiresIn;
}
