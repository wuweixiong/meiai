/**
 * BEGINNER GUIDE:
 * File: PageResponse.java
 * Role: API DTO: request/response shape exchanged with clients.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * xindongriji-backend page response.
 */
@Data
@AllArgsConstructor
public class PageResponse<T> {
  private List<T> items;
  private int page;
  private int size;
  private long total;
}
