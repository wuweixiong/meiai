/**
 * BEGINNER GUIDE:
 * File: TagUpdateRequest.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import lombok.Data;

/**
 * xindongriji-backend tag update request.
 */
@Data
public class TagUpdateRequest {
  @NotBlank(message = "name required")
  @Size(max = 30, message = "name too long")
  private String name;
}
