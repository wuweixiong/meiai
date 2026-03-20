package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AuthServiceTest {

  @Autowired
  private AuthService authService;

  @Autowired
  private UserRepository userRepository;

  @Test
  void register_success() {
    User user = authService.register("13800000000", "P@ssw0rd");
    assertNotNull(user.getId());
    assertEquals("13800000000", user.getPhone());
    assertTrue(userRepository.existsByPhone("13800000000"));
  }

  @Test
  void register_duplicatePhone() {
    authService.register("13800000000", "P@ssw0rd");
    ApiException ex = assertThrows(ApiException.class,
        () -> authService.register("13800000000", "OtherPwd"));
    assertEquals(40001, ex.getCode());
  }

  @Test
  void login_success() {
    authService.register("13800000001", "P@ssw0rd");
    String token = authService.login("13800000001", "P@ssw0rd");
    assertNotNull(token);
    assertFalse(token.isBlank());
  }

  @Test
  void login_wrongPassword() {
    authService.register("13800000002", "P@ssw0rd");
    ApiException ex = assertThrows(ApiException.class,
        () -> authService.login("13800000002", "WrongPwd"));
    assertEquals(40001, ex.getCode());
  }
}
