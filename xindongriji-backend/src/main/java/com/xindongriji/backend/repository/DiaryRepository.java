/**
 * BEGINNER GUIDE:
 * File: DiaryRepository.java
 * Role: Persistence access: communicates with database through JPA.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.repository;

import com.xindongriji.backend.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.Optional;

public interface DiaryRepository extends JpaRepository<Diary, Long>, JpaSpecificationExecutor<Diary> {
  Optional<Diary> findByIdAndUserId(Long id, Long userId);
  void deleteByIdAndUserId(Long id, Long userId);
  boolean existsByIdAndUserId(Long id, Long userId);
}
