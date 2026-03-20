/**
 * BEGINNER GUIDE:
 * File: DiaryController.java
 * Role: API controller: receives HTTP requests and returns API responses.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller;

import com.xindongriji.backend.controller.dto.DiaryCreateRequest;
import com.xindongriji.backend.controller.dto.DiaryResponse;
import com.xindongriji.backend.controller.dto.DiaryUpdateRequest;
import com.xindongriji.backend.controller.dto.PageResponse;
import com.xindongriji.backend.controller.dto.TagResponse;
import com.xindongriji.backend.entity.Diary;
import com.xindongriji.backend.entity.Tag;
import com.xindongriji.backend.service.DiaryService;
import com.xindongriji.backend.utils.ApiResponse;
import com.xindongriji.backend.utils.DateUtil;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;
import javax.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * xindongriji-backend diary controller.
 */
@RestController
@RequestMapping("/api/v1/diaries")
public class DiaryController {
  private final DiaryService diaryService;

  public DiaryController(DiaryService diaryService) {
    this.diaryService = diaryService;
  }

  @PostMapping
  public ApiResponse<DiaryResponse> create(@Valid @RequestBody DiaryCreateRequest request) {
    Diary diary = diaryService.create(
      request.getTitle(),
      request.getContent(),
      DateUtil.parseDate(request.getDate()),
      request.getTagIds()
    );
    return ApiResponse.ok(toResponse(diary));
  }

  @GetMapping
  public ApiResponse<PageResponse<DiaryResponse>> list(
    @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateFrom,
    @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate dateTo,
    @RequestParam(required = false) Long tagId,
    @RequestParam(required = false) String keyword,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size
  ) {
    Pageable pageable = PageRequest.of(page, size);
    Page<Diary> diaryPage = diaryService.list(dateFrom, dateTo, tagId, keyword, pageable);
    List<DiaryResponse> items = diaryPage.getContent().stream()
      .map(this::toResponse)
      .collect(Collectors.toList());
    PageResponse<DiaryResponse> data = new PageResponse<>(items, page, size, diaryPage.getTotalElements());
    return ApiResponse.ok(data);
  }

  @GetMapping("/{id}")
  public ApiResponse<DiaryResponse> get(@PathVariable Long id) {
    return ApiResponse.ok(toResponse(diaryService.get(id)));
  }

  @PutMapping("/{id}")
  public ApiResponse<DiaryResponse> update(@PathVariable Long id, @RequestBody DiaryUpdateRequest request) {
    Diary diary = diaryService.update(
      id,
      request.getTitle(),
      request.getContent(),
      request.getDate() != null ? DateUtil.parseDate(request.getDate()) : null,
      request.getTagIds()
    );
    return ApiResponse.ok(toResponse(diary));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    diaryService.delete(id);
    return ApiResponse.ok(null);
  }

  private DiaryResponse toResponse(Diary diary) {
    List<TagResponse> tags = diary.getTags().stream()
      .map(this::toTagResponse)
      .collect(Collectors.toList());
    String createdAt = diary.getCreatedAt() != null ? diary.getCreatedAt().toString() : null;
    return new DiaryResponse(
      diary.getId(),
      diary.getTitle(),
      diary.getContent(),
      diary.getDate() != null ? diary.getDate().toString() : null,
      tags,
      createdAt
    );
  }

  private TagResponse toTagResponse(Tag tag) {
    return new TagResponse(tag.getId(), tag.getName());
  }
}
