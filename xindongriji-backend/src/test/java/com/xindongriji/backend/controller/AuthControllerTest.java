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

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
class AuthControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  void register_success() throws Exception {
    String payload = "{\"phone\":\"13800005000\",\"password\":\"P@ssw0rd\"}";
    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.userId").isNumber())
      .andExpect(jsonPath("$.data.phone").value("13800005000"));
  }

  @Test
  void register_duplicatePhone() throws Exception {
    String payload = "{\"phone\":\"13800005001\",\"password\":\"P@ssw0rd\"}";
    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0));

    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(40001));
  }

  @Test
  void login_success() throws Exception {
    String payload = "{\"phone\":\"13800005002\",\"password\":\"P@ssw0rd\"}";
    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk());

    MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(0))
      .andExpect(jsonPath("$.data.tokenType").value("Bearer"))
      .andReturn();

    String token = JsonPath.read(result.getResponse().getContentAsString(), "$.data.accessToken");
    assertThat(token).isNotBlank();
  }

  @Test
  void login_wrongPassword() throws Exception {
    String payload = "{\"phone\":\"13800005003\",\"password\":\"P@ssw0rd\"}";
    mockMvc.perform(post("/api/v1/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(payload))
      .andExpect(status().isOk());

    String wrongPayload = "{\"phone\":\"13800005003\",\"password\":\"WrongPwd\"}";
    mockMvc.perform(post("/api/v1/auth/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(wrongPayload))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.code").value(40001));
  }
}
