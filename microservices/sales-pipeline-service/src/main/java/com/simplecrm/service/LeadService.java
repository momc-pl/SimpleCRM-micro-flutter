package com.simplecrm.service;

import com.simplecrm.dto.LeadCreateRequest;
import com.simplecrm.dto.LeadDto;
import com.simplecrm.entity.Lead;
import com.simplecrm.entity.LeadStatus;
import com.simplecrm.entity.LeadSource;
import com.simplecrm.exception.DuplicateEmailException;
import com.simplecrm.exception.LeadNotFoundException;
import com.simplecrm.repository.LeadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class LeadService {

    private final LeadRepository leadRepository;

    @Autowired
    public LeadService(LeadRepository leadRepository) {
        this.leadRepository = leadRepository;
    }

    public LeadDto createLead(LeadCreateRequest request) {
        // Check for duplicate email
        if (request.getEmail() != null && leadRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateEmailException("Lead with email " + request.getEmail() + " already exists");
        }

        Lead lead = mapToEntity(request);
        lead.setStatus(request.getStatus() != null ? request.getStatus() : LeadStatus.NEW);
        
        Lead savedLead = leadRepository.save(lead);
        return mapToDto(savedLead);
    }

    @Transactional(readOnly = true)
    public LeadDto getLeadById(Long id) {
        Lead lead = leadRepository.findById(id)
                .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + id));
        return mapToDto(lead);
    }

    @Transactional(readOnly = true)
    public Page<LeadDto> getAllLeads(int page, int size, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
                   Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return leadRepository.findAll(pageable).map(this::mapToDto);
    }

    public LeadDto updateLead(Long id, LeadCreateRequest request) {
        Lead existingLead = leadRepository.findById(id)
                .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + id));

        // Check for duplicate email if email is being updated
        if (request.getEmail() != null && !request.getEmail().equals(existingLead.getEmail())) {
            if (leadRepository.findByEmail(request.getEmail()).isPresent()) {
                throw new DuplicateEmailException("Lead with email " + request.getEmail() + " already exists");
            }
        }

        updateLeadFromRequest(existingLead, request);
        Lead updatedLead = leadRepository.save(existingLead);
        return mapToDto(updatedLead);
    }

    public void deleteLead(Long id) {
        if (!leadRepository.existsById(id)) {
            throw new LeadNotFoundException("Lead not found with id: " + id);
        }
        leadRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<LeadDto> getLeadsByStatus(LeadStatus status) {
        return leadRepository.findByStatus(status)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LeadDto> getLeadsByAssignedUser(Long userId) {
        return leadRepository.findByAssignedTo(userId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LeadDto> getLeadsRequiringFollowUp(LocalDateTime startDate, LocalDateTime endDate) {
        return leadRepository.findLeadsRequiringFollowUp(startDate, endDate)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LeadDto> getQualifiedLeads(Integer minScore) {
        return leadRepository.findQualifiedLeads(minScore)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public LeadDto convertLeadToOpportunity(Long leadId) {
        Lead lead = leadRepository.findById(leadId)
                .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + leadId));
        
        lead.setStatus(LeadStatus.CONVERTED);
        Lead convertedLead = leadRepository.save(lead);
        return mapToDto(convertedLead);
    }

    public LeadDto qualifyLead(Long leadId, Integer qualificationScore) {
        Lead lead = leadRepository.findById(leadId)
                .orElseThrow(() -> new LeadNotFoundException("Lead not found with id: " + leadId));
        
        lead.setQualificationScore(qualificationScore);
        lead.setStatus(qualificationScore >= 70 ? LeadStatus.QUALIFIED : LeadStatus.UNQUALIFIED);
        
        Lead qualifiedLead = leadRepository.save(lead);
        return mapToDto(qualifiedLead);
    }

    @Transactional(readOnly = true)
    public Page<LeadDto> searchLeads(String name, String email, String company, 
                                    LeadStatus status, Long assignedTo, Pageable pageable) {
        return leadRepository.searchLeads(name, email, company, status, assignedTo, pageable)
                .map(this::mapToDto);
    }

    private Lead mapToEntity(LeadCreateRequest request) {
        Lead lead = new Lead();
        lead.setFirstName(request.getFirstName());
        lead.setLastName(request.getLastName());
        lead.setEmail(request.getEmail());
        lead.setPhone(request.getPhone());
        lead.setCompany(request.getCompany());
        lead.setJobTitle(request.getJobTitle());
        lead.setSource(request.getSource());
        lead.setEstimatedValue(request.getEstimatedValue());
        lead.setNotes(request.getNotes());
        lead.setAssignedTo(request.getAssignedTo());
        lead.setQualificationScore(request.getQualificationScore());
        lead.setConversionProbability(request.getConversionProbability());
        lead.setNextFollowUpDate(request.getNextFollowUpDate());
        return lead;
    }

    private void updateLeadFromRequest(Lead lead, LeadCreateRequest request) {
        if (request.getFirstName() != null) lead.setFirstName(request.getFirstName());
        if (request.getLastName() != null) lead.setLastName(request.getLastName());
        if (request.getEmail() != null) lead.setEmail(request.getEmail());
        if (request.getPhone() != null) lead.setPhone(request.getPhone());
        if (request.getCompany() != null) lead.setCompany(request.getCompany());
        if (request.getJobTitle() != null) lead.setJobTitle(request.getJobTitle());
        if (request.getStatus() != null) lead.setStatus(request.getStatus());
        if (request.getSource() != null) lead.setSource(request.getSource());
        if (request.getEstimatedValue() != null) lead.setEstimatedValue(request.getEstimatedValue());
        if (request.getNotes() != null) lead.setNotes(request.getNotes());
        if (request.getAssignedTo() != null) lead.setAssignedTo(request.getAssignedTo());
        if (request.getQualificationScore() != null) lead.setQualificationScore(request.getQualificationScore());
        if (request.getConversionProbability() != null) lead.setConversionProbability(request.getConversionProbability());
        if (request.getNextFollowUpDate() != null) lead.setNextFollowUpDate(request.getNextFollowUpDate());
    }

    private LeadDto mapToDto(Lead lead) {
        LeadDto dto = new LeadDto();
        dto.setId(lead.getId());
        dto.setFirstName(lead.getFirstName());
        dto.setLastName(lead.getLastName());
        dto.setEmail(lead.getEmail());
        dto.setPhone(lead.getPhone());
        dto.setCompany(lead.getCompany());
        dto.setJobTitle(lead.getJobTitle());
        dto.setStatus(lead.getStatus());
        dto.setSource(lead.getSource());
        dto.setEstimatedValue(lead.getEstimatedValue());
        dto.setNotes(lead.getNotes());
        dto.setAssignedTo(lead.getAssignedTo());
        dto.setQualificationScore(lead.getQualificationScore());
        dto.setConversionProbability(lead.getConversionProbability());
        dto.setLastContactDate(lead.getLastContactDate());
        dto.setNextFollowUpDate(lead.getNextFollowUpDate());
        dto.setCreatedAt(lead.getCreatedAt());
        dto.setUpdatedAt(lead.getUpdatedAt());
        return dto;
    }
}