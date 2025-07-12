package com.simplecrm.service;

import com.simplecrm.dto.OpportunityCreateRequest;
import com.simplecrm.dto.OpportunityDto;
import com.simplecrm.entity.Opportunity;
import com.simplecrm.entity.Lead;
import com.simplecrm.entity.SalesStage;
import com.simplecrm.entity.OpportunityPriority;
import com.simplecrm.exception.OpportunityNotFoundException;
import com.simplecrm.exception.LeadNotFoundException;
import com.simplecrm.repository.OpportunityRepository;
import com.simplecrm.repository.LeadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class OpportunityService {

    private final OpportunityRepository opportunityRepository;
    private final LeadRepository leadRepository;

    @Autowired
    public OpportunityService(OpportunityRepository opportunityRepository, LeadRepository leadRepository) {
        this.opportunityRepository = opportunityRepository;
        this.leadRepository = leadRepository;
    }

    public OpportunityDto createOpportunity(OpportunityCreateRequest request) {
        Opportunity opportunity = mapToEntity(request);
        
        // Set default stage if not provided
        if (opportunity.getStage() == null) {
            opportunity.setStage(SalesStage.PROSPECTING);
        }
        
        // Set default priority if not provided
        if (opportunity.getPriority() == null) {
            opportunity.setPriority(OpportunityPriority.MEDIUM);
        }
        
        // Link to lead if leadId is provided
        if (request.getLeadId() != null) {
            Lead lead = leadRepository.findById(request.getLeadId())
                    .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + request.getLeadId()));
            opportunity.setLead(lead);
        }
        
        Opportunity savedOpportunity = opportunityRepository.save(opportunity);
        return mapToDto(savedOpportunity);
    }

    @Transactional(readOnly = true)
    public OpportunityDto getOpportunityById(Long id) {
        Opportunity opportunity = opportunityRepository.findById(id)
                .orElseThrow(() -> new OpportunityNotFoundException("Opportunity not found with id: " + id));
        return mapToDto(opportunity);
    }

    @Transactional(readOnly = true)
    public Page<OpportunityDto> getAllOpportunities(int page, int size, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
                   Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return opportunityRepository.findAll(pageable).map(this::mapToDto);
    }

    public OpportunityDto updateOpportunity(Long id, OpportunityCreateRequest request) {
        Opportunity existingOpportunity = opportunityRepository.findById(id)
                .orElseThrow(() -> new OpportunityNotFoundException("Opportunity not found with id: " + id));

        updateOpportunityFromRequest(existingOpportunity, request);
        
        // Update lead association if leadId is provided
        if (request.getLeadId() != null) {
            Lead lead = leadRepository.findById(request.getLeadId())
                    .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + request.getLeadId()));
            existingOpportunity.setLead(lead);
        }
        
        Opportunity updatedOpportunity = opportunityRepository.save(existingOpportunity);
        return mapToDto(updatedOpportunity);
    }

    public void deleteOpportunity(Long id) {
        if (!opportunityRepository.existsById(id)) {
            throw new OpportunityNotFoundException("Opportunity not found with id: " + id);
        }
        opportunityRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<OpportunityDto> getOpportunitiesByStage(SalesStage stage) {
        return opportunityRepository.findByStage(stage)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<OpportunityDto> getOpportunitiesByCustomer(Long customerId) {
        return opportunityRepository.findByCustomerId(customerId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<OpportunityDto> getOpportunitiesByAssignedUser(Long userId) {
        return opportunityRepository.findByAssignedTo(userId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public OpportunityDto moveToNextStage(Long opportunityId) {
        Opportunity opportunity = opportunityRepository.findById(opportunityId)
                .orElseThrow(() -> new OpportunityNotFoundException("Opportunity not found with id: " + opportunityId));
        
        SalesStage currentStage = opportunity.getStage();
        SalesStage nextStage = getNextStage(currentStage);
        
        if (nextStage != null) {
            opportunity.setStage(nextStage);
            updateProbabilityBasedOnStage(opportunity, nextStage);
            
            if (nextStage == SalesStage.WON || nextStage == SalesStage.LOST) {
                opportunity.setActualCloseDate(LocalDateTime.now());
            }
        }
        
        Opportunity updatedOpportunity = opportunityRepository.save(opportunity);
        return mapToDto(updatedOpportunity);
    }

    public OpportunityDto updateStage(Long opportunityId, SalesStage newStage) {
        Opportunity opportunity = opportunityRepository.findById(opportunityId)
                .orElseThrow(() -> new OpportunityNotFoundException("Opportunity not found with id: " + opportunityId));
        
        opportunity.setStage(newStage);
        updateProbabilityBasedOnStage(opportunity, newStage);
        
        if (newStage == SalesStage.WON || newStage == SalesStage.LOST) {
            opportunity.setActualCloseDate(LocalDateTime.now());
        }
        
        Opportunity updatedOpportunity = opportunityRepository.save(opportunity);
        return mapToDto(updatedOpportunity);
    }

    @Transactional(readOnly = true)
    public List<OpportunityDto> getOpportunitiesClosingSoon(LocalDateTime startDate, LocalDateTime endDate) {
        return opportunityRepository.findOpportunitiesClosingInDateRange(startDate, endDate)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<OpportunityDto> getOverdueOpportunities() {
        return opportunityRepository.findOverdueOpportunities(SalesStage.CLOSING, LocalDateTime.now())
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<OpportunityDto> searchOpportunities(String name, SalesStage stage, Long assignedTo, 
                                                   BigDecimal minValue, BigDecimal maxValue, Pageable pageable) {
        return opportunityRepository.searchOpportunities(name, stage, assignedTo, minValue, maxValue, pageable)
                .map(this::mapToDto);
    }

    private SalesStage getNextStage(SalesStage currentStage) {
        switch (currentStage) {
            case PROSPECTING: return SalesStage.QUALIFICATION;
            case QUALIFICATION: return SalesStage.NEEDS_ANALYSIS;
            case NEEDS_ANALYSIS: return SalesStage.PROPOSAL;
            case PROPOSAL: return SalesStage.NEGOTIATION;
            case NEGOTIATION: return SalesStage.CLOSING;
            case CLOSING: return SalesStage.WON; // Default to won, could be lost based on business logic
            default: return null;
        }
    }

    private void updateProbabilityBasedOnStage(Opportunity opportunity, SalesStage stage) {
        switch (stage) {
            case PROSPECTING: opportunity.setProbability(10); break;
            case QUALIFICATION: opportunity.setProbability(25); break;
            case NEEDS_ANALYSIS: opportunity.setProbability(40); break;
            case PROPOSAL: opportunity.setProbability(60); break;
            case NEGOTIATION: opportunity.setProbability(80); break;
            case CLOSING: opportunity.setProbability(90); break;
            case WON: opportunity.setProbability(100); break;
            case LOST: opportunity.setProbability(0); break;
        }
    }

    private Opportunity mapToEntity(OpportunityCreateRequest request) {
        Opportunity opportunity = new Opportunity();
        opportunity.setName(request.getName());
        opportunity.setDescription(request.getDescription());
        opportunity.setCustomerId(request.getCustomerId());
        opportunity.setValue(request.getValue());
        opportunity.setStage(request.getStage());
        opportunity.setProbability(request.getProbability());
        opportunity.setExpectedCloseDate(request.getExpectedCloseDate());
        opportunity.setAssignedTo(request.getAssignedTo());
        opportunity.setPriority(request.getPriority());
        opportunity.setNextStep(request.getNextStep());
        opportunity.setCompetitor(request.getCompetitor());
        opportunity.setNotes(request.getNotes());
        return opportunity;
    }

    private void updateOpportunityFromRequest(Opportunity opportunity, OpportunityCreateRequest request) {
        if (request.getName() != null) opportunity.setName(request.getName());
        if (request.getDescription() != null) opportunity.setDescription(request.getDescription());
        if (request.getCustomerId() != null) opportunity.setCustomerId(request.getCustomerId());
        if (request.getValue() != null) opportunity.setValue(request.getValue());
        if (request.getStage() != null) opportunity.setStage(request.getStage());
        if (request.getProbability() != null) opportunity.setProbability(request.getProbability());
        if (request.getExpectedCloseDate() != null) opportunity.setExpectedCloseDate(request.getExpectedCloseDate());
        if (request.getAssignedTo() != null) opportunity.setAssignedTo(request.getAssignedTo());
        if (request.getPriority() != null) opportunity.setPriority(request.getPriority());
        if (request.getNextStep() != null) opportunity.setNextStep(request.getNextStep());
        if (request.getCompetitor() != null) opportunity.setCompetitor(request.getCompetitor());
        if (request.getNotes() != null) opportunity.setNotes(request.getNotes());
    }

    private OpportunityDto mapToDto(Opportunity opportunity) {
        OpportunityDto dto = new OpportunityDto();
        dto.setId(opportunity.getId());
        dto.setName(opportunity.getName());
        dto.setDescription(opportunity.getDescription());
        dto.setCustomerId(opportunity.getCustomerId());
        dto.setLeadId(opportunity.getLead() != null ? opportunity.getLead().getId() : null);
        dto.setValue(opportunity.getValue());
        dto.setStage(opportunity.getStage());
        dto.setProbability(opportunity.getProbability());
        dto.setExpectedCloseDate(opportunity.getExpectedCloseDate());
        dto.setActualCloseDate(opportunity.getActualCloseDate());
        dto.setAssignedTo(opportunity.getAssignedTo());
        dto.setPriority(opportunity.getPriority());
        dto.setNextStep(opportunity.getNextStep());
        dto.setCompetitor(opportunity.getCompetitor());
        dto.setNotes(opportunity.getNotes());
        dto.setCreatedAt(opportunity.getCreatedAt());
        dto.setUpdatedAt(opportunity.getUpdatedAt());
        return dto;
    }
}