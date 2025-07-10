package com.simplecrm.controller;

import com.simplecrm.dto.CustomerCreateRequest;
import com.simplecrm.dto.CustomerDto;
import com.simplecrm.dto.CustomerUpdateRequest;
import com.simplecrm.entity.CustomerStatus;
import com.simplecrm.service.CustomerService;
import com.simplecrm.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/customers")
@Validated
public class CustomerController {

    private final CustomerService customerService;
    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public CustomerController(CustomerService customerService, JwtTokenProvider jwtTokenProvider) {
        this.customerService = customerService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @PostMapping
    public ResponseEntity<CustomerDto> createCustomer(@Valid @RequestBody CustomerCreateRequest request,
                                                    HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        CustomerDto createdCustomer = customerService.createCustomer(request, userId);
        return new ResponseEntity<>(createdCustomer, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerDto> getCustomer(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        CustomerDto customer = customerService.getCustomerById(id, userId);
        return ResponseEntity.ok(customer);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CustomerDto> updateCustomer(@PathVariable Long id,
                                                    @Valid @RequestBody CustomerUpdateRequest request,
                                                    HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        CustomerDto updatedCustomer = customerService.updateCustomer(id, request, userId);
        return ResponseEntity.ok(updatedCustomer);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCustomer(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        customerService.deleteCustomer(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<Page<CustomerDto>> getCustomers(
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<CustomerDto> customers = customerService.getCustomers(userId, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(customers);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<CustomerDto>> searchCustomers(
            @RequestParam("q") @NotBlank String query,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<CustomerDto> customers = customerService.searchCustomers(userId, query, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(customers);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<Page<CustomerDto>> getCustomersByStatus(
            @PathVariable CustomerStatus status,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<CustomerDto> customers = customerService.getCustomersByStatus(userId, status, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(customers);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getCustomerStats(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCustomers", customerService.getCustomerCount(userId));
        stats.put("activeCustomers", customerService.getCustomerCountByStatus(userId, CustomerStatus.ACTIVE));
        stats.put("inactiveCustomers", customerService.getCustomerCountByStatus(userId, CustomerStatus.INACTIVE));
        return ResponseEntity.ok(stats);
    }

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String token = jwtTokenProvider.getTokenFromRequest(request);
        return jwtTokenProvider.getUserIdFromToken(token);
    }
}