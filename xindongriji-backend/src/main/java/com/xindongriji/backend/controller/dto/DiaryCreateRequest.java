/**
 * BEGINNER GUIDE:
 * File: DiaryCreateRequest.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import java.util.List;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import lombok.Data;

/**
 * xindongriji-backend diary create request.
 */
@Data
public class DiaryCreateRequest {
  @NotBlank(message = "title required")
  @Size(max = 100, message = "title too long")
  private String title;

  @NotBlank(message = "content required")
  private String content;

  @NotBlank(message = "date required")
  private String date;

  private List<Long> tagIds;
}
