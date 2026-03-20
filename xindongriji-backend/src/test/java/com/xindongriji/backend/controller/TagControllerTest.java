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
class TagControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  void tag_crud_flow() throws Exception {
    String token = registerAndLogin("13800007000", "P@ssw0rd");

    String createPayload = "{\"name\":\"旅行\"}";
    MvcResult createResult = mockMvc.perform(post("/api/v1/tags")
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(createPayload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andReturn();

    Long tagId = JsonPath.read(createResult.getResponse().getContentAsString(), "$.data.id");

    mockMvc.perform(get("/api/v1/tags")
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data[0].name").value("旅行"));

    String updatePayload = "{\"name\":\"心情\"}";
    mockMvc.perform(put("/api/v1/tags/" + tagId)
        .header("Authorization", "Bearer " + token)
        .contentType(MediaType.APPLICATION_JSON)
        .content(updatePayload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.name").value("心情"));

    mockMvc.perform(delete("/api/v1/tags/" + tagId)
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0));

    mockMvc.perform(get("/api/v1/tags")
        .header("Authorization", "Bearer " + token))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.data").isEmpty());
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
