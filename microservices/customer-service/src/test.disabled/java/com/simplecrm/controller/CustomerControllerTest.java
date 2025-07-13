package com.simplecrm.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.simplecrm.dto.CustomerCreateRequest;
import com.simplecrm.dto.CustomerDto;
import com.simplecrm.entity.CustomerStatus;
import com.simplecrm.security.JwtTokenProvider;
import com.simplecrm.service.CustomerService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CustomerController.class)
class CustomerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CustomerService customerService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private ObjectMapper objectMapper;

    private CustomerDto customerDto;
    private CustomerCreateRequest createRequest;

    @BeforeEach
    void setUp() {
        customerDto = new CustomerDto();
        customerDto.setId(1L);
        customerDto.setFirstName("John");
        customerDto.setLastName("Doe");
        customerDto.setEmail("john.doe@example.com");
        customerDto.setPhoneNumber("+1234567890");
        customerDto.setStatus(CustomerStatus.ACTIVE);
        customerDto.setCreatedAt(LocalDateTime.now());

        createRequest = new CustomerCreateRequest();
        createRequest.setFirstName("John");
        createRequest.setLastName("Doe");
        createRequest.setEmail("john.doe@example.com");
        createRequest.setPhoneNumber("+1234567890");

        // Mock JWT token provider
        when(jwtTokenProvider.getTokenFromRequest(any())).thenReturn("valid-token");
        when(jwtTokenProvider.getUserIdFromToken(anyString())).thenReturn(1L);
    }

    @Test
    void createCustomer_ShouldReturnCreatedCustomer() throws Exception {
        when(customerService.createCustomer(any(CustomerCreateRequest.class), anyLong()))
                .thenReturn(customerDto);

        mockMvc.perform(post("/customers")
                        .header("Authorization", "Bearer valid-token")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"))
                .andExpected(jsonPath("$.email").value("john.doe@example.com"));
    }

    @Test
    void getCustomer_ShouldReturnCustomer() throws Exception {
        when(customerService.getCustomerById(1L, 1L)).thenReturn(customerDto);

        mockMvc.perform(get("/customers/1")
                        .header("Authorization", "Bearer valid-token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.firstName").value("John"));
    }

    @Test
    void getCustomers_ShouldReturnPageOfCustomers() throws Exception {
        Page<CustomerDto> page = new PageImpl<>(Arrays.asList(customerDto));
        when(customerService.getCustomers(anyLong(), anyInt(), anyInt(), anyString(), anyString()))
                .thenReturn(page);

        mockMvc.perform(get("/customers")
                        .header("Authorization", "Bearer valid-token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.content[0].id").value(1L));
    }

    @Test
    void deleteCustomer_ShouldReturnNoContent() throws Exception {
        mockMvc.perform(delete("/customers/1")
                        .header("Authorization", "Bearer valid-token"))
                .andExpect(status().isNoContent());
    }
}