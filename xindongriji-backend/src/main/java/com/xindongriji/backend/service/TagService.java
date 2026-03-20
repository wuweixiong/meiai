/**
 * BEGINNER GUIDE:
 * File: TagService.java
 * Role: Business service: applies core business rules and use cases.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.Diary;
import com.xindongriji.backend.entity.Tag;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.exception.ApiException;
import com.xindongriji.backend.exception.ErrorCodes;
import com.xindongriji.backend.repository.TagRepository;
import com.xindongriji.backend.utils.UserContext;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * xindongriji-backend tag service.
 */
@Service
public class TagService {
  private final TagRepository tagRepository;
  private final UserService userService;

  public TagService(TagRepository tagRepository, UserService userService) {
    this.tagRepository = tagRepository;
    this.userService = userService;
  }

  public List<Tag> list() {
    Long userId = UserContext.getUserId();
    return tagRepository.findByUserIdOrderByNameAsc(userId);
  }

  @Transactional
  public Tag create(String name) {
    Long userId = UserContext.getUserId();
    if (tagRepository.findByNameAndUserId(name, userId).isPresent()) {
      throw new ApiException(ErrorCodes.BAD_REQUEST, "tag already exists");
    }
    User user = userService.currentUser();
    Tag tag = new Tag();
    tag.setName(name);
    tag.setUser(user);
    return tagRepository.save(tag);
  }

  @Transactional
  public Tag update(Long id, String name) {
    Long userId = UserContext.getUserId();
    Tag tag = tagRepository.findByIdAndUserId(id, userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "tag not found"));
    tag.setName(name);
    return tagRepository.save(tag);
  }

  @Transactional
  public void delete(Long id) {
    Long userId = UserContext.getUserId();
    Tag tag = tagRepository.findByIdAndUserId(id, userId)
      .orElseThrow(() -> new ApiException(ErrorCodes.NOT_FOUND, "tag not found"));
    Set<Diary> diaries = tag.getDiaries();
    for (Diary diary : diaries) {
      diary.getTags().remove(tag);
    }
    tagRepository.delete(tag);
  }
}
