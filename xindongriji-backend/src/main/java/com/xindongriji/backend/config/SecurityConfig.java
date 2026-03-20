/**
 * BEGINNER GUIDE:
 * File: SecurityConfig.java
 * Role: Application configuration: wires framework and app settings.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.config;

import com.xindongriji.backend.security.JwtAuthenticationFilter;
import com.xindongriji.backend.security.JsonAuthenticationEntryPoint;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

  @Bean
  public SecurityFilterChain securityFilterChain(
      HttpSecurity http,
      JwtAuthenticationFilter jwtAuthenticationFilter,
      JsonAuthenticationEntryPoint authenticationEntryPoint
  ) throws Exception {
    http.csrf().disable();
    http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    http.exceptionHandling().authenticationEntryPoint(authenticationEntryPoint);
    http.authorizeRequests()
        .antMatchers("/api/v1/auth/**").permitAll()
        .antMatchers("/api/v1/**").authenticated()
        .anyRequest().permitAll();
    http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }
}
