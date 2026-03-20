/**
 * BEGINNER GUIDE:
 * File: TagRepository.java
 * Role: Persistence access: communicates with database through JPA.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.repository;

import com.xindongriji.backend.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TagRepository extends JpaRepository<Tag, Long> {
  List<Tag> findByUserIdOrderByIdAsc(Long userId);
  List<Tag> findByUserIdOrderByNameAsc(Long userId);
  Optional<Tag> findByNameAndUserId(String name, Long userId);
  List<Tag> findByIdInAndUserId(List<Long> ids, Long userId);
  Optional<Tag> findByIdAndUserId(Long id, Long userId);
  boolean existsByUserIdAndName(Long userId, String name);
}
