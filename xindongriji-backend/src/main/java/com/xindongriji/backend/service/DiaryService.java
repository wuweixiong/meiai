/**
 * BEGINNER GUIDE:
 * File: DiaryService.java
 * Role: Business service: applies core business rules and use cases.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.Diary;
import com.xindongriji.backend.entity.Tag;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.repository.DiaryRepository;
import com.xindongriji.backend.repository.TagRepository;
import com.xindongriji.backend.utils.UserContext;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.persistence.criteria.Join;
import javax.persistence.criteria.JoinType;
import javax.persistence.criteria.Predicate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * xindongriji-backend diary service.
 */
@Service
public class DiaryService {
  private final DiaryRepository diaryRepository;
  private final TagRepository tagRepository;
  private final UserService userService;

  public DiaryService(DiaryRepository diaryRepository, TagRepository tagRepository, UserService userService) {
    this.diaryRepository = diaryRepository;
    this.tagRepository = tagRepository;
    this.userService = userService;
  }

  @Transactional
  public Diary create(String title, String content, LocalDate date, List<Long> tagIds) {
    User user = userService.currentUser();
    Diary diary = new Diary();
    diary.setUser(user);
    diary.setTitle(title);
    diary.setContent(content);
    diary.setDate(date);
    diary.setTags(resolveTags(tagIds, user.getId()));
    return diaryRepository.save(diary);
  }

  @Transactional
  public Diary update(Long id, String title, String content, LocalDate date, List<Long> tagIds) {
    Long userId = UserContext.getUserId();
    Diary diary = diaryRepository.findByIdAndUserId(id, userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "diary not found"));
    if (title != null) {
      diary.setTitle(title);
    }
    if (content != null) {
      diary.setContent(content);
    }
    if (date != null) {
      diary.setDate(date);
    }
    if (tagIds != null) {
      diary.setTags(resolveTags(tagIds, userId));
    }
    return diaryRepository.save(diary);
  }

  @Transactional(readOnly = true)
  public Diary get(Long id) {
    Long userId = UserContext.getUserId();
    return diaryRepository.findByIdAndUserId(id, userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "diary not found"));
  }

  @Transactional
  public void delete(Long id) {
    Long userId = UserContext.getUserId();
    Diary diary = diaryRepository.findByIdAndUserId(id, userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "diary not found"));
    diaryRepository.delete(diary);
  }

  @Transactional(readOnly = true)
  public Page<Diary> list(LocalDate dateFrom, LocalDate dateTo, Long tagId, String keyword, Pageable pageable) {
    Long userId = UserContext.getUserId();
    String trimmed = keyword != null && !keyword.isBlank() ? keyword.trim() : null;
    Specification<Diary> spec = (root, query, cb) -> {
      List<Predicate> predicates = new ArrayList<>();
      predicates.add(cb.equal(root.get("user").get("id"), userId));
      if (dateFrom != null) {
        predicates.add(cb.greaterThanOrEqualTo(root.get("date"), dateFrom));
      }
      if (dateTo != null) {
        predicates.add(cb.lessThanOrEqualTo(root.get("date"), dateTo));
      }
      if (trimmed != null) {
        String like = "%" + trimmed + "%";
        predicates.add(cb.or(
          cb.like(root.get("title"), like),
          cb.like(root.get("content"), like)
        ));
      }
      if (tagId != null) {
        Join<Diary, Tag> tagJoin = root.join("tags", JoinType.LEFT);
        predicates.add(cb.equal(tagJoin.get("id"), tagId));
        query.distinct(true);
      }
      return cb.and(predicates.toArray(new Predicate[0]));
    };
    return diaryRepository.findAll(spec, pageable);
  }

  private Set<Tag> resolveTags(List<Long> tagIds, Long userId) {
    if (tagIds == null || tagIds.isEmpty()) {
      return new HashSet<>();
    }
    List<Tag> tags = tagRepository.findByIdInAndUserId(tagIds, userId);
    if (tags.size() != tagIds.size()) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "invalid tag ids");
    }
    return new HashSet<>(tags);
  }
}
