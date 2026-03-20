/**
 * BEGINNER GUIDE:
 * File: DateUtil.java
 * Role: Utility helpers: shared low-level helpers used by services/controllers.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.utils;

import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.exception.ErrorCodes;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * xindongriji-backend date utility.
 */
public final class DateUtil {
  private DateUtil() {}

  public static LocalDate parseDate(String value) {
    try {
      return LocalDate.parse(value);
    } catch (DateTimeParseException ex) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "invalid date format, use yyyy-MM-dd");
    }
  }
}
