package com.simplecrm.controller;

import com.simplecrm.dto.ContactCreateRequest;
import com.simplecrm.dto.ContactDto;
import com.simplecrm.dto.ContactUpdateRequest;
import com.simplecrm.entity.ContactStatus;
import com.simplecrm.entity.ContactType;
import com.simplecrm.service.ContactService;
import com.simplecrm.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/contacts")
@Validated
public class ContactController {

    private final ContactService contactService;
    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public ContactController(ContactService contactService, JwtTokenProvider jwtTokenProvider) {
        this.contactService = contactService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @PostMapping
    public ResponseEntity<ContactDto> createContact(@Valid @RequestBody ContactCreateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ContactDto createdContact = contactService.createContact(request, userId);
        return new ResponseEntity<>(createdContact, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContactDto> getContact(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ContactDto contact = contactService.getContactById(id, userId);
        return ResponseEntity.ok(contact);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ContactDto> updateContact(@PathVariable Long id,
                                                   @Valid @RequestBody ContactUpdateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ContactDto updatedContact = contactService.updateContact(id, request, userId);
        return ResponseEntity.ok(updatedContact);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteContact(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        contactService.deleteContact(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<Page<ContactDto>> getContacts(
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Pageable pageable = createPageable(page, size, sortBy, sortDirection);
        Page<ContactDto> contacts = contactService.getAllContacts(userId, pageable);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<ContactDto>> searchContacts(
            @RequestParam("q") @NotBlank String query,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Pageable pageable = createPageable(page, size, sortBy, sortDirection);
        Page<ContactDto> contacts = contactService.searchContacts(query, userId, pageable);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<Page<ContactDto>> getContactsByStatus(
            @PathVariable ContactStatus status,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Pageable pageable = createPageable(page, size, sortBy, sortDirection);
        Page<ContactDto> contacts = contactService.getContactsByStatus(status, userId, pageable);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/type/{contactType}")
    public ResponseEntity<Page<ContactDto>> getContactsByType(
            @PathVariable ContactType contactType,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Pageable pageable = createPageable(page, size, sortBy, sortDirection);
        Page<ContactDto> contacts = contactService.getContactsByType(contactType, userId, pageable);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/company/{company}")
    public ResponseEntity<Page<ContactDto>> getContactsByCompany(
            @PathVariable String company,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Pageable pageable = createPageable(page, size, sortBy, sortDirection);
        Page<ContactDto> contacts = contactService.getContactsByCompany(company, userId, pageable);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<ContactDto>> getContactsByCustomerId(
            @PathVariable Long customerId,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        List<ContactDto> contacts = contactService.getContactsByCustomerId(customerId, userId);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<ContactDto> getContactByEmail(
            @PathVariable String email,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ContactDto contact = contactService.getContactByEmail(email, userId);
        return ResponseEntity.ok(contact);
    }

    @GetMapping("/recent")
    public ResponseEntity<List<ContactDto>> getRecentContacts(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        List<ContactDto> contacts = contactService.getRecentContacts(userId);
        return ResponseEntity.ok(contacts);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getContactStats(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Map<String, Object> stats = new HashMap<>();
        
        // Contact type statistics
        stats.put("totalContacts", contactService.getContactCountByType(ContactType.LEAD, userId) +
                                  contactService.getContactCountByType(ContactType.PROSPECT, userId) +
                                  contactService.getContactCountByType(ContactType.CUSTOMER, userId) +
                                  contactService.getContactCountByType(ContactType.PARTNER, userId) +
                                  contactService.getContactCountByType(ContactType.VENDOR, userId) +
                                  contactService.getContactCountByType(ContactType.EMPLOYEE, userId));
        
        stats.put("leadContacts", contactService.getContactCountByType(ContactType.LEAD, userId));
        stats.put("prospectContacts", contactService.getContactCountByType(ContactType.PROSPECT, userId));
        stats.put("customerContacts", contactService.getContactCountByType(ContactType.CUSTOMER, userId));
        stats.put("partnerContacts", contactService.getContactCountByType(ContactType.PARTNER, userId));
        stats.put("vendorContacts", contactService.getContactCountByType(ContactType.VENDOR, userId));
        stats.put("employeeContacts", contactService.getContactCountByType(ContactType.EMPLOYEE, userId));
        
        // Contact status statistics
        stats.put("activeContacts", contactService.getContactCountByStatus(ContactStatus.ACTIVE, userId));
        stats.put("inactiveContacts", contactService.getContactCountByStatus(ContactStatus.INACTIVE, userId));
        stats.put("qualifiedContacts", contactService.getContactCountByStatus(ContactStatus.QUALIFIED, userId));
        stats.put("unqualifiedContacts", contactService.getContactCountByStatus(ContactStatus.UNQUALIFIED, userId));
        stats.put("convertedContacts", contactService.getContactCountByStatus(ContactStatus.CONVERTED, userId));
        stats.put("blockedContacts", contactService.getContactCountByStatus(ContactStatus.BLOCKED, userId));
        
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("service", "contact-service");
        return ResponseEntity.ok(status);
    }

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String token = jwtTokenProvider.getTokenFromRequest(request);
        return jwtTokenProvider.getUserIdFromToken(token);
    }

    private Pageable createPageable(int page, int size, String sortBy, String sortDirection) {
        Sort sort = sortDirection.equalsIgnoreCase("desc") 
            ? Sort.by(sortBy).descending() 
            : Sort.by(sortBy).ascending();
        return PageRequest.of(page, size, sort);
    }
}