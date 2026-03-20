/**
 * BEGINNER GUIDE:
 * File: ErrorCodes.java
 * Role: Error handling: normalizes exceptions into stable API error output.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.exception;

/**
 * xindongriji-backend error codes.
 */
public final class ErrorCodes {
  private ErrorCodes() {}

  public static final int BAD_REQUEST = 40001;
  public static final int UNAUTHORIZED = 40101;
  public static final int FORBIDDEN = 40301;
  public static final int NOT_FOUND = 40401;
  public static final int SERVER_ERROR = 50001;
}
