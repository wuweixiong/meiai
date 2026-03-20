package com.xindongriji.backend.controller;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
class DiaryControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  void diary_crud_and_query_flow() throws Exception {
    String token = registerAndLogin("13800008000", "P@ssw0rd");

    Long tagWork = createTag(token, "工作");
    Long tagLife = createTag(token, "生活");

    String createPayload = String.format(
        "{\"title\":\"今天的心情\",\"content\":\"记录一些事情\",\"date\":\"2026-03-20\",\"tagIds\":[%d,%d]}",
        tagWork, tagLife
    );
    MvcResult createResult = mockMvc.perform(post("/api/v1/diaries")
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(createPayload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.tags").isArray())
      .andReturn();

    Long diaryId = JsonPath.read(createResult.getResponse().getContentAsString(), "$.data.diaryId");

    String createPayload2 = String.format(
        "{\"title\":\"工作记录\",\"content\":\"记录工作\",\"date\":\"2026-03-21\",\"tagIds\":[%d]}",
        tagWork
    );
    mockMvc.perform(post("/api/v1/diaries")
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(createPayload2))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0));

    mockMvc.perform(get("/api/v1/diaries")
        .header("Authorization", "Bearer " + token)
        .param("dateFrom", "2026-03-20")
        .param("dateTo", "2026-03-20"))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.items.length()").value(1));

    mockMvc.perform(get("/api/v1/diaries")
        .header("Authorization", "Bearer " + token)
        .param("tagId", String.valueOf(tagWork)))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.items.length()").value(2));

    mockMvc.perform(get("/api/v1/diaries")
        .header("Authorization", "Bearer " + token)
        .param("page", "0")
        .param("size", "1"))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.items.length()").value(1))
      .andExpect(jsonPath("$.data.total").value(2));

    mockMvc.perform(get("/api/v1/diaries/" + diaryId)
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.diaryId").value(diaryId));

    String updatePayload = String.format(
        "{\"title\":\"更新后的标题\",\"content\":\"更新后的内容\",\"date\":\"2026-03-22\",\"tagIds\":[%d]}",
        tagLife
    );
    mockMvc.perform(put("/api/v1/diaries/" + diaryId)
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(updatePayload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.title").value("更新后的标题"));

    mockMvc.perform(delete("/api/v1/diaries/" + diaryId)
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0));

    mockMvc.perform(get("/api/v1/diaries/" + diaryId)
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(40401));
  }

  private Long createTag(String token, String name) throws Exception {
    String payload = String.format("{\"name\":\"%s\"}", name);
    MvcResult result = mockMvc.perform(post("/api/v1/tags")
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andReturn();

    return JsonPath.read(result.getResponse().getContentAsString(), "$.data.id");
  }

  private String registerAndLogin(String phone, String password) throws Exception {
    String payload = String.format("{\"phone\":\"%s\",\"password\":\"%s\"}", phone, password);
    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk());

    MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andReturn();

    return JsonPath.read(result.getResponse().getContentAsString(), "$.data.accessToken");
  }
}
