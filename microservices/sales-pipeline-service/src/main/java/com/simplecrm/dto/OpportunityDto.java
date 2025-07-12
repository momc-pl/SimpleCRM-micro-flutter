package com.simplecrm.dto;

import com.simplecrm.entity.OpportunityPriority;
import com.simplecrm.entity.SalesStage;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class OpportunityDto {
    private Long id;
    private String name;
    private String description;
    private Long customerId;
    private Long leadId;
    private BigDecimal value;
    private SalesStage stage;
    private Integer probability;
    private LocalDateTime expectedCloseDate;
    private LocalDateTime actualCloseDate;
    private Long assignedTo;
    private OpportunityPriority priority;
    private String nextStep;
    private String competitor;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public OpportunityDto() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public Long getLeadId() { return leadId; }
    public void setLeadId(Long leadId) { this.leadId = leadId; }

    public BigDecimal getValue() { return value; }
    public void setValue(BigDecimal value) { this.value = value; }

    public SalesStage getStage() { return stage; }
    public void setStage(SalesStage stage) { this.stage = stage; }

    public Integer getProbability() { return probability; }
    public void setProbability(Integer probability) { this.probability = probability; }

    public LocalDateTime getExpectedCloseDate() { return expectedCloseDate; }
    public void setExpectedCloseDate(LocalDateTime expectedCloseDate) { this.expectedCloseDate = expectedCloseDate; }

    public LocalDateTime getActualCloseDate() { return actualCloseDate; }
    public void setActualCloseDate(LocalDateTime actualCloseDate) { this.actualCloseDate = actualCloseDate; }

    public Long getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Long assignedTo) { this.assignedTo = assignedTo; }

    public OpportunityPriority getPriority() { return priority; }
    public void setPriority(OpportunityPriority priority) { this.priority = priority; }

    public String getNextStep() { return nextStep; }
    public void setNextStep(String nextStep) { this.nextStep = nextStep; }

    public String getCompetitor() { return competitor; }
    public void setCompetitor(String competitor) { this.competitor = competitor; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}