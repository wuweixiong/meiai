/**
 * BEGINNER GUIDE:
 * File: ApiException.java
 * Role: Error handling: normalizes exceptions into stable API error output.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.exception;

public class ApiException extends RuntimeException {
  private final int code;

  public ApiException(int code, String message) {
    super(message);
    this.code = code;
  }

  public int getCode() {
    return code;
  }
}
