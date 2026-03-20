/**
 * BEGINNER GUIDE:
 * File: XindongrijiBackendApplication.java
 * Role: Backend bootstrap: Spring Boot startup class.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class XindongrijiBackendApplication {
  public static void main(String[] args) {
    SpringApplication.run(XindongrijiBackendApplication.class, args);
  }
}
