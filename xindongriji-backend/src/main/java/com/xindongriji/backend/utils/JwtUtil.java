/**
 * BEGINNER GUIDE:
 * File: JwtUtil.java
 * Role: Utility helpers: shared low-level helpers used by services/controllers.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import javax.crypto.SecretKey;

/**
 * xindongriji-backend JWT utility template.
 */
public class JwtUtil {
  private JwtUtil() {}

  public static String generateToken(String subject, String secret, long expireSeconds) {
    SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    Date now = new Date();
    Date exp = new Date(now.getTime() + expireSeconds * 1000);
    return Jwts.builder()
      .setSubject(subject)
      .setIssuedAt(now)
      .setExpiration(exp)
      .signWith(key, SignatureAlgorithm.HS256)
      .compact();
  }

  public static Claims parseToken(String token, String secret) {
    SecretKey key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
  }
}
