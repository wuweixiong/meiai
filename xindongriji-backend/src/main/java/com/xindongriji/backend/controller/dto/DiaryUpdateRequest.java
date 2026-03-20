/**
 * BEGINNER GUIDE:
 * File: DiaryUpdateRequest.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import java.util.List;
import lombok.Data;

/**
 * xindongriji-backend diary update request.
 */
@Data
public class DiaryUpdateRequest {
  private String title;
  private String content;

  private String date;

  private List<Long> tagIds;
}
