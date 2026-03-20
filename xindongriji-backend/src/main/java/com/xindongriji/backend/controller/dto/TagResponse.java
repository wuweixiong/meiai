/**
 * BEGINNER GUIDE:
 * File: TagResponse.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * xindongriji-backend tag response.
 */
@Data
@AllArgsConstructor
public class TagResponse {
  private Long id;
  private String name;
}
