package com.xindongriji.backend.service;

import com.xindongriji.backend.entity.Diary;
import com.xindongriji.backend.entity.Tag;
import com.xindongriji.backend.entity.User;
import com.xindongriji.backend.repository.DiaryRepository;
import com.xindongriji.backend.repository.TagRepository;
import com.xindongriji.backend.repository.UserRepository;
import com.xindongriji.backend.utils.UserContext;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;
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
class TagServiceTest {

  @Autowired
  private TagService tagService;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private TagRepository tagRepository;

  @Autowired
  private DiaryRepository diaryRepository;

  @AfterEach
  void clearContext() {
    UserContext.clear();
  }

  @Test
  void create_and_list() {
    User user = createUser("13800004000");
    UserContext.setUserId(user.getId());

    tagService.create("工作");
    tagService.create("生活");

    List<Tag> tags = tagService.list();
    List<String> names = tags.stream().map(Tag::getName).collect(Collectors.toList());
    assertEquals(List.of("工作", "生活"), names);
  }

  @Test
  void update_success() {
    User user = createUser("13800004001");
    UserContext.setUserId(user.getId());

    Tag tag = tagService.create("旅行");
    Tag updated = tagService.update(tag.getId(), "心情");

    assertEquals("心情", updated.getName());
  }

  @Test
  void delete_detachesFromDiaries() {
    User user = createUser("13800004002");
    UserContext.setUserId(user.getId());

    Tag tag = tagService.create("工作");
    Diary diary = new Diary();
    diary.setUser(user);
    diary.setTitle("标题");
    diary.setContent("内容");
    diary.setDate(LocalDate.of(2026, 3, 20));
    diary.getTags().add(tag);
    diary = diaryRepository.save(diary);

    tagService.delete(tag.getId());

    Diary reloaded = diaryRepository.findById(diary.getId()).orElseThrow();
    assertTrue(reloaded.getTags().isEmpty());
    assertFalse(tagRepository.findById(tag.getId()).isPresent());
  }

  private User createUser(String phone) {
    User user = new User();
    user.setPhone(phone);
    user.setPasswordHash("hash");
    return userRepository.save(user);
  }
}
