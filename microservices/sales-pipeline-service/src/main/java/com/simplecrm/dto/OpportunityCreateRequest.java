package com.simplecrm.dto;

import com.simplecrm.entity.OpportunityPriority;
import com.simplecrm.entity.SalesStage;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class OpportunityCreateRequest {
    @NotBlank(message = "Opportunity name is required")
    private String name;

    private String description;

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    private Long leadId;

    @NotNull(message = "Value is required")
    @Positive(message = "Value must be positive")
    private BigDecimal value;

    private SalesStage stage;
    private Integer probability;
    private LocalDateTime expectedCloseDate;
    private Long assignedTo;
    private OpportunityPriority priority;
    private String nextStep;
    private String competitor;
    private String notes;

    // Constructors
    public OpportunityCreateRequest() {}

    // Getters and Setters
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
}