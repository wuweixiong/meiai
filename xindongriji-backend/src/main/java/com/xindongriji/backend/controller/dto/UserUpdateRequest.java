/**
 * BEGINNER GUIDE:
 * File: UserUpdateRequest.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import lombok.Data;

/**
 * xindongriji-backend user update request.
 */
@Data
public class UserUpdateRequest {
  @NotBlank(message = "phone required")
  @Size(max = 20, message = "phone too long")
  private String phone;
}
