/**
 * BEGINNER GUIDE:
 * File: JsonAuthenticationEntryPoint.java
 * Role: Security pipeline: authenticates requests and protects endpoints.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.security;

import com.alibaba.fastjson.JSON;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.utils.ApiResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

@Component
public class JsonAuthenticationEntryPoint implements AuthenticationEntryPoint {
  @Override
  public void commence(HttpServletRequest request, HttpServletResponse response,
                       AuthenticationException authException) throws IOException {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    response.setCharacterEncoding(StandardCharsets.UTF_8.name());
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    ApiResponse<Void> body = ApiResponse.error(ErrorCodes.UNAUTHORIZED, "unauthorized");
    response.getWriter().write(JSON.toJSONString(body));
  }
}
