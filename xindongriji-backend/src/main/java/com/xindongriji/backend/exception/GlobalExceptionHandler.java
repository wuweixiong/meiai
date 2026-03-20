/**
 * BEGINNER GUIDE:
 * File: GlobalExceptionHandler.java
 * Role: Error handling: normalizes exceptions into stable API error output.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.exception;

import com.xindongriji.backend.utils.ApiResponse;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(ApiException.class)
  public ApiResponse<Void> handleApiException(ApiException ex) {
    return ApiResponse.error(ex.getCode(), ex.getMessage());
  }

  @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
  public ApiResponse<Void> handleValidation(Exception ex) {
    String message;
    if (ex instanceof MethodArgumentNotValidException) {
      message = ((MethodArgumentNotValidException) ex).getBindingResult().getFieldErrors().stream()
          .map(error -> error.getField() + " " + error.getDefaultMessage())
          .collect(Collectors.joining("; "));
    } else {
      message = ((BindException) ex).getBindingResult().getFieldErrors().stream()
          .map(error -> error.getField() + " " + error.getDefaultMessage())
          .collect(Collectors.joining("; "));
    }
    return ApiResponse.error(ErrorCodes.BAD_REQUEST, message);
  }

  @ExceptionHandler(HttpMessageNotReadableException.class)
  public ApiResponse<Void> handleNotReadable(HttpMessageNotReadableException ex) {
    return ApiResponse.error(ErrorCodes.BAD_REQUEST, "invalid request body");
  }

  @ExceptionHandler(Exception.class)
  public ApiResponse<Void> handleOther(Exception ex) {
    return ApiResponse.error(ErrorCodes.SERVER_ERROR, "server error");
  }
}
