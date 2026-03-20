/**
 * BEGINNER GUIDE:
 * File: UserRepository.java
 * Role: Persistence access: communicates with database through JPA.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.repository;

import com.xindongriji.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByPhone(String phone);
  boolean existsByPhone(String phone);
  boolean existsByPhoneAndIdNot(String phone, Long id);
}
