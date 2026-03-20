/**
 * BEGINNER GUIDE:
 * File: UserContext.java
 * Role: Utility helpers: shared low-level helpers used by services/controllers.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.utils;

/**
 * xindongriji-backend user context holder.
 */
public final class UserContext {
  private static final ThreadLocal<Long> USER_ID = new ThreadLocal<>();

  private UserContext() {}

  public static void setUserId(Long userId) {
    USER_ID.set(userId);
  }

  public static Long getUserId() {
    return USER_ID.get();
  }

  public static void clear() {
    USER_ID.remove();
  }
}
