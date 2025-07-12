package com.simplecrm.controller;

import com.simplecrm.dto.*;
import com.simplecrm.entity.LeadStatus;
import com.simplecrm.entity.LeadSource;
import com.simplecrm.entity.SalesStage;
import com.simplecrm.entity.OpportunityPriority;
import com.simplecrm.service.LeadService;
import com.simplecrm.service.OpportunityService;
import com.simplecrm.service.PipelineAnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/sales")
@Validated
@CrossOrigin(origins = "*")
public class SalesPipelineController {

    private final LeadService leadService;
    private final OpportunityService opportunityService;
    private final PipelineAnalyticsService analyticsService;

    @Autowired
    public SalesPipelineController(LeadService leadService, 
                                  OpportunityService opportunityService,
                                  PipelineAnalyticsService analyticsService) {
        this.leadService = leadService;
        this.opportunityService = opportunityService;
        this.analyticsService = analyticsService;
    }

    // Lead Management Endpoints
    @PostMapping("/leads")
    public ResponseEntity<LeadDto> createLead(@Valid @RequestBody LeadCreateRequest request) {
        LeadDto createdLead = leadService.createLead(request);
        return new ResponseEntity<>(createdLead, HttpStatus.CREATED);
    }

    @GetMapping("/leads/{id}")
    public ResponseEntity<LeadDto> getLeadById(@PathVariable Long id) {
        LeadDto lead = leadService.getLeadById(id);
        return ResponseEntity.ok(lead);
    }

    @GetMapping("/leads")
    public ResponseEntity<Page<LeadDto>> getAllLeads(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Page<LeadDto> leads = leadService.getAllLeads(page, size, sortBy, sortDir);
        return ResponseEntity.ok(leads);
    }

    @PutMapping("/leads/{id}")
    public ResponseEntity<LeadDto> updateLead(@PathVariable Long id, 
                                             @Valid @RequestBody LeadCreateRequest request) {
        LeadDto updatedLead = leadService.updateLead(id, request);
        return ResponseEntity.ok(updatedLead);
    }

    @DeleteMapping("/leads/{id}")
    public ResponseEntity<Void> deleteLead(@PathVariable Long id) {
        leadService.deleteLead(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/leads/status/{status}")
    public ResponseEntity<List<LeadDto>> getLeadsByStatus(@PathVariable LeadStatus status) {
        List<LeadDto> leads = leadService.getLeadsByStatus(status);
        return ResponseEntity.ok(leads);
    }

    @GetMapping("/leads/assigned/{userId}")
    public ResponseEntity<List<LeadDto>> getLeadsByAssignedUser(@PathVariable Long userId) {
        List<LeadDto> leads = leadService.getLeadsByAssignedUser(userId);
        return ResponseEntity.ok(leads);
    }

    @PostMapping("/leads/{id}/convert")
    public ResponseEntity<LeadDto> convertLeadToOpportunity(@PathVariable Long id) {
        LeadDto convertedLead = leadService.convertLeadToOpportunity(id);
        return ResponseEntity.ok(convertedLead);
    }

    @PostMapping("/leads/{id}/qualify")
    public ResponseEntity<LeadDto> qualifyLead(@PathVariable Long id, 
                                              @RequestParam Integer qualificationScore) {
        LeadDto qualifiedLead = leadService.qualifyLead(id, qualificationScore);
        return ResponseEntity.ok(qualifiedLead);
    }

    @GetMapping("/leads/follow-up")
    public ResponseEntity<List<LeadDto>> getLeadsRequiringFollowUp(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<LeadDto> leads = leadService.getLeadsRequiringFollowUp(startDate, endDate);
        return ResponseEntity.ok(leads);
    }

    @GetMapping("/leads/search")
    public ResponseEntity<Page<LeadDto>> searchLeads(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String company,
            @RequestParam(required = false) LeadStatus status,
            @RequestParam(required = false) Long assignedTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<LeadDto> leads = leadService.searchLeads(name, email, company, status, assignedTo, pageable);
        return ResponseEntity.ok(leads);
    }

    // Opportunity Management Endpoints
    @PostMapping("/opportunities")
    public ResponseEntity<OpportunityDto> createOpportunity(@Valid @RequestBody OpportunityCreateRequest request) {
        OpportunityDto createdOpportunity = opportunityService.createOpportunity(request);
        return new ResponseEntity<>(createdOpportunity, HttpStatus.CREATED);
    }

    @GetMapping("/opportunities/{id}")
    public ResponseEntity<OpportunityDto> getOpportunityById(@PathVariable Long id) {
        OpportunityDto opportunity = opportunityService.getOpportunityById(id);
        return ResponseEntity.ok(opportunity);
    }

    @GetMapping("/opportunities")
    public ResponseEntity<Page<OpportunityDto>> getAllOpportunities(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        Page<OpportunityDto> opportunities = opportunityService.getAllOpportunities(page, size, sortBy, sortDir);
        return ResponseEntity.ok(opportunities);
    }

    @PutMapping("/opportunities/{id}")
    public ResponseEntity<OpportunityDto> updateOpportunity(@PathVariable Long id, 
                                                           @Valid @RequestBody OpportunityCreateRequest request) {
        OpportunityDto updatedOpportunity = opportunityService.updateOpportunity(id, request);
        return ResponseEntity.ok(updatedOpportunity);
    }

    @DeleteMapping("/opportunities/{id}")
    public ResponseEntity<Void> deleteOpportunity(@PathVariable Long id) {
        opportunityService.deleteOpportunity(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/opportunities/stage/{stage}")
    public ResponseEntity<List<OpportunityDto>> getOpportunitiesByStage(@PathVariable SalesStage stage) {
        List<OpportunityDto> opportunities = opportunityService.getOpportunitiesByStage(stage);
        return ResponseEntity.ok(opportunities);
    }

    @GetMapping("/opportunities/customer/{customerId}")
    public ResponseEntity<List<OpportunityDto>> getOpportunitiesByCustomer(@PathVariable Long customerId) {
        List<OpportunityDto> opportunities = opportunityService.getOpportunitiesByCustomer(customerId);
        return ResponseEntity.ok(opportunities);
    }

    @GetMapping("/opportunities/assigned/{userId}")
    public ResponseEntity<List<OpportunityDto>> getOpportunitiesByAssignedUser(@PathVariable Long userId) {
        List<OpportunityDto> opportunities = opportunityService.getOpportunitiesByAssignedUser(userId);
        return ResponseEntity.ok(opportunities);
    }

    @PostMapping("/opportunities/{id}/advance")
    public ResponseEntity<OpportunityDto> moveOpportunityToNextStage(@PathVariable Long id) {
        OpportunityDto updatedOpportunity = opportunityService.moveToNextStage(id);
        return ResponseEntity.ok(updatedOpportunity);
    }

    @PutMapping("/opportunities/{id}/stage")
    public ResponseEntity<OpportunityDto> updateOpportunityStage(@PathVariable Long id, 
                                                                @RequestParam SalesStage stage) {
        OpportunityDto updatedOpportunity = opportunityService.updateStage(id, stage);
        return ResponseEntity.ok(updatedOpportunity);
    }

    @GetMapping("/opportunities/closing-soon")
    public ResponseEntity<List<OpportunityDto>> getOpportunitiesClosingSoon(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<OpportunityDto> opportunities = opportunityService.getOpportunitiesClosingSoon(startDate, endDate);
        return ResponseEntity.ok(opportunities);
    }

    @GetMapping("/opportunities/overdue")
    public ResponseEntity<List<OpportunityDto>> getOverdueOpportunities() {
        List<OpportunityDto> opportunities = opportunityService.getOverdueOpportunities();
        return ResponseEntity.ok(opportunities);
    }

    @GetMapping("/opportunities/search")
    public ResponseEntity<Page<OpportunityDto>> searchOpportunities(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) SalesStage stage,
            @RequestParam(required = false) Long assignedTo,
            @RequestParam(required = false) BigDecimal minValue,
            @RequestParam(required = false) BigDecimal maxValue,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<OpportunityDto> opportunities = opportunityService.searchOpportunities(name, stage, assignedTo, minValue, maxValue, pageable);
        return ResponseEntity.ok(opportunities);
    }

    // Analytics Endpoints
    @GetMapping("/analytics/pipeline")
    public ResponseEntity<PipelineAnalyticsDto> getPipelineAnalytics() {
        PipelineAnalyticsDto analytics = analyticsService.getPipelineAnalytics();
        return ResponseEntity.ok(analytics);
    }

    @GetMapping("/analytics/performance/{userId}")
    public ResponseEntity<Map<String, Object>> getSalesPerformanceMetrics(@PathVariable Long userId) {
        Map<String, Object> metrics = analyticsService.getSalesPerformanceMetrics(userId);
        return ResponseEntity.ok(metrics);
    }

    // Health Check
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "sales-pipeline-service"));
    }
}