/**
 * BEGINNER GUIDE:
 * File: JwtProperties.java
 * Role: Application configuration: wires framework and app settings.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
  private String secret;
  private long accessTokenExpireSeconds;
}
