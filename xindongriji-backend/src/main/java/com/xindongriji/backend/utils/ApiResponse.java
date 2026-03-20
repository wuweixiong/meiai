/**
 * BEGINNER GUIDE:
 * File: ApiResponse.java
 * Role: Utility helpers: shared low-level helpers used by services/controllers.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.utils;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * xindongriji-backend common API response wrapper.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
  private int code;
  private String message;
  private T data;

  public static <T> ApiResponse<T> ok(T data) {
    return new ApiResponse<>(0, "ok", data);
  }

  public static <T> ApiResponse<T> error(int code, String message) {
    return new ApiResponse<>(code, message, null);
  }
}
