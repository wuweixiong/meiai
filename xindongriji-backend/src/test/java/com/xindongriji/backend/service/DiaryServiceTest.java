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
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class DiaryServiceTest {

  @Autowired
  private DiaryService diaryService;

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
  void create_success() {
    User user = createUser("13800003000");
    Tag tagWork = createTag(user, "工作");
    Tag tagLife = createTag(user, "生活");

    UserContext.setUserId(user.getId());
    Diary diary = diaryService.create(
        "今天的心情",
        "记录一些事情",
        LocalDate.of(2026, 3, 20),
        List.of(tagWork.getId(), tagLife.getId())
    );

    assertNotNull(diary.getId());
    assertEquals(2, diary.getTags().size());
  }

  @Test
  void list_byDateRange() {
    User user = createUser("13800003001");
    UserContext.setUserId(user.getId());
    diaryService.create("A", "content A", LocalDate.of(2026, 3, 18), List.of());
    diaryService.create("B", "content B", LocalDate.of(2026, 3, 20), List.of());
    diaryService.create("C", "content C", LocalDate.of(2026, 3, 25), List.of());

    Page<Diary> page = diaryService.list(
        LocalDate.of(2026, 3, 19),
        LocalDate.of(2026, 3, 21),
        null,
        null,
        PageRequest.of(0, 10)
    );

    assertEquals(1, page.getTotalElements());
    assertEquals("B", page.getContent().get(0).getTitle());
  }

  @Test
  void list_byTag() {
    User user = createUser("13800003002");
    Tag tagWork = createTag(user, "工作");
    Tag tagLife = createTag(user, "生活");

    UserContext.setUserId(user.getId());
    diaryService.create("工作记录", "content", LocalDate.of(2026, 3, 20), List.of(tagWork.getId()));
    diaryService.create("生活记录", "content", LocalDate.of(2026, 3, 20), List.of(tagLife.getId()));

    Page<Diary> page = diaryService.list(null, null, tagWork.getId(), null, PageRequest.of(0, 10));

    assertEquals(1, page.getTotalElements());
    assertEquals("工作记录", page.getContent().get(0).getTitle());
  }

  @Test
  void update_success() {
    User user = createUser("13800003003");
    Tag tagOld = createTag(user, "旧标签");
    Tag tagNew = createTag(user, "新标签");

    UserContext.setUserId(user.getId());
    Diary diary = diaryService.create("旧标题", "旧内容", LocalDate.of(2026, 3, 20), List.of(tagOld.getId()));

    Diary updated = diaryService.update(
        diary.getId(),
        "新标题",
        "新内容",
        LocalDate.of(2026, 3, 21),
        List.of(tagNew.getId())
    );

    assertEquals("新标题", updated.getTitle());
    assertEquals(LocalDate.of(2026, 3, 21), updated.getDate());
    Set<Long> tagIds = updated.getTags().stream().map(Tag::getId).collect(Collectors.toSet());
    assertTrue(tagIds.contains(tagNew.getId()));
    assertFalse(tagIds.contains(tagOld.getId()));
  }

  @Test
  void delete_success() {
    User user = createUser("13800003004");
    UserContext.setUserId(user.getId());
    Diary diary = diaryService.create("标题", "内容", LocalDate.of(2026, 3, 20), List.of());

    diaryService.delete(diary.getId());

    assertFalse(diaryRepository.existsById(diary.getId()));
  }

  @Test
  void list_pagination() {
    User user = createUser("13800003005");
    UserContext.setUserId(user.getId());
    for (int i = 0; i < 12; i++) {
      diaryService.create("标题" + i, "内容" + i, LocalDate.of(2026, 3, 20), List.of());
    }

    Page<Diary> page0 = diaryService.list(null, null, null, null, PageRequest.of(0, 10));
    Page<Diary> page1 = diaryService.list(null, null, null, null, PageRequest.of(1, 10));

    assertEquals(12, page0.getTotalElements());
    assertEquals(10, page0.getContent().size());
    assertEquals(2, page1.getContent().size());
  }

  private User createUser(String phone) {
    User user = new User();
    user.setPhone(phone);
    user.setPasswordHash("hash");
    return userRepository.save(user);
  }

  private Tag createTag(User user, String name) {
    Tag tag = new Tag();
    tag.setName(name);
    tag.setUser(user);
    return tagRepository.save(tag);
  }
}
