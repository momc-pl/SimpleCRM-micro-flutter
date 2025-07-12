package com.simplecrm.entity;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Entity
@Table(name = "opportunities")
public class Opportunity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @NotNull
    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lead_id")
    private Lead lead;

    @NotNull
    @Column(name = "value", precision = 19, scale = 2, nullable = false)
    private BigDecimal value;

    @Enumerated(EnumType.STRING)
    @Column(name = "stage", nullable = false)
    private SalesStage stage = SalesStage.PROSPECTING;

    @Column(name = "probability")
    private Integer probability;

    @Column(name = "expected_close_date")
    private LocalDateTime expectedCloseDate;

    @Column(name = "actual_close_date")
    private LocalDateTime actualCloseDate;

    @Column(name = "assigned_to")
    private Long assignedTo;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority")
    private OpportunityPriority priority = OpportunityPriority.MEDIUM;

    @Column(name = "next_step")
    private String nextStep;

    @Column(name = "competitor")
    private String competitor;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Constructors
    public Opportunity() {}

    public Opportunity(String name, Long customerId, BigDecimal value) {
        this.name = name;
        this.customerId = customerId;
        this.value = value;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public Lead getLead() { return lead; }
    public void setLead(Lead lead) { this.lead = lead; }

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