/**
 * BEGINNER GUIDE:
 * File: LoginRequest.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import lombok.Data;

/**
 * xindongriji-backend login request.
 */
@Data
public class LoginRequest {
  @NotBlank(message = "phone required")
  @Size(max = 20, message = "phone too long")
  private String phone;

  @NotBlank(message = "password required")
  @Size(min = 6, max = 50, message = "password length 6-50")
  private String password;
}
