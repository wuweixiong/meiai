/**
 * BEGINNER GUIDE:
 * File: DiaryResponse.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * xindongriji-backend diary response.
 */
@Data
@AllArgsConstructor
public class DiaryResponse {
  private Long diaryId;
  private String title;
  private String content;
  private String date;
  private List<TagResponse> tags;
  private String createdAt;
}
