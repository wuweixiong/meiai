package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.repository.UserRepository;
import com.xindongriji.backend.utils.UserContext;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class UserServiceTest {

  @Autowired
  private UserService userService;

  @Autowired
  private UserRepository userRepository;

  @AfterEach
  void clearContext() {
    UserContext.clear();
  }

  @Test
  void updatePhone_success() {
    User user = new User();
    user.setPhone("13800001000");
    user.setPasswordHash("hash");
    user = userRepository.save(user);

    UserContext.setUserId(user.getId());
    User updated = userService.updatePhone("13800001999");

    assertEquals("13800001999", updated.getPhone());
    assertTrue(userRepository.existsByPhone("13800001999"));
  }

  @Test
  void updatePhone_duplicate() {
    User userA = new User();
    userA.setPhone("13800002000");
    userA.setPasswordHash("hash");
    userA = userRepository.save(userA);

    User userB = new User();
    userB.setPhone("13800002001");
    userB.setPasswordHash("hash");
    userRepository.save(userB);

    UserContext.setUserId(userA.getId());
    ApiException ex = assertThrows(ApiException.class,
        () -> userService.updatePhone("13800002001"));
    assertEquals(40001, ex.getCode());
  }
}
