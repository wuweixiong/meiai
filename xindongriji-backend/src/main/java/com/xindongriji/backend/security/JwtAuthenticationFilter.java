/**
 * BEGINNER GUIDE:
 * File: JwtAuthenticationFilter.java
 * Role: Security pipeline: authenticates requests and protects endpoints.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.security;

import com.alibaba.fastjson.JSON;
import com.xindongriji.backend.config.JwtProperties;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.utils.ApiResponse;
import com.xindongriji.backend.utils.JwtUtil;
import com.xindongriji.backend.utils.UserContext;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import java.util.Collections;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.util.StringUtils;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
  private final JwtProperties jwtProperties;

  public JwtAuthenticationFilter(JwtProperties jwtProperties) {
    this.jwtProperties = jwtProperties;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    try {
      String path = request.getRequestURI();
      if (path != null && path.startsWith("/api/v1/auth/")) {
        filterChain.doFilter(request, response);
        return;
      }

      String auth = request.getHeader("Authorization");
      if (!StringUtils.hasText(auth) || !auth.startsWith("Bearer ")) {
        filterChain.doFilter(request, response);
        return;
      }

      String token = auth.substring(7);
      Claims claims = JwtUtil.parseToken(token, jwtProperties.getSecret());
      String subject = claims.getSubject();
      if (!StringUtils.hasText(subject)) {
        writeUnauthorized(response);
        return;
      }
      Long userId = Long.parseLong(subject);
      UserContext.setUserId(userId);
      UsernamePasswordAuthenticationToken authentication =
          new UsernamePasswordAuthenticationToken(userId, null, Collections.emptyList());
      authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
      SecurityContextHolder.getContext().setAuthentication(authentication);
      filterChain.doFilter(request, response);
    } catch (JwtException | IllegalArgumentException ex) {
      writeUnauthorized(response);
    } finally {
      UserContext.clear();
      SecurityContextHolder.clearContext();
    }
  }

  private void writeUnauthorized(HttpServletResponse response) throws IOException {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    response.setCharacterEncoding(StandardCharsets.UTF_8.name());
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    ApiResponse<Void> body = ApiResponse.error(ErrorCodes.UNAUTHORIZED, "unauthorized");
    response.getWriter().write(JSON.toJSONString(body));
  }
}
