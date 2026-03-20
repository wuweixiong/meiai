/**
 * BEGINNER GUIDE:
 * File: TagController.java
 * Role: API controller: receives HTTP requests and returns API responses.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.controller;

import com.xindongriji.backend.controller.dto.TagCreateRequest;
import com.xindongriji.backend.controller.dto.TagResponse;
import com.xindongriji.backend.controller.dto.TagUpdateRequest;
import com.xindongriji.backend.entity.Tag;
import com.xindongriji.backend.service.TagService;
import com.xindongriji.backend.utils.ApiResponse;
import java.util.List;
import java.util.stream.Collectors;
import javax.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * xindongriji-backend tag controller.
 */
@RestController
@RequestMapping("/api/v1/tags")
public class TagController {
  private final TagService tagService;

  public TagController(TagService tagService) {
    this.tagService = tagService;
  }

  @GetMapping
  public ApiResponse<List<TagResponse>> list() {
    List<TagResponse> data = tagService.list().stream()
      .map(tag -> new TagResponse(tag.getId(), tag.getName()))
      .collect(Collectors.toList());
    return ApiResponse.ok(data);
  }

  @PostMapping
  public ApiResponse<TagResponse> create(@Valid @RequestBody TagCreateRequest request) {
    Tag tag = tagService.create(request.getName());
    return ApiResponse.ok(new TagResponse(tag.getId(), tag.getName()));
  }

  @PutMapping("/{id}")
  public ApiResponse<TagResponse> update(@PathVariable Long id, @Valid @RequestBody TagUpdateRequest request) {
    Tag tag = tagService.update(id, request.getName());
    return ApiResponse.ok(new TagResponse(tag.getId(), tag.getName()));
  }

  @DeleteMapping("/{id}")
  public ApiResponse<Void> delete(@PathVariable Long id) {
    tagService.delete(id);
    return ApiResponse.ok(null);
  }
}
