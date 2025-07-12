package com.simplecrm.entity;

import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Entity
@Table(name = "leads")
public class Lead {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "first_name", nullable = false)
    private String firstName;

    @NotBlank
    @Column(name = "last_name", nullable = false)
    private String lastName;

    @Email
    @Column(name = "email", unique = true)
    private String email;

    @Column(name = "phone")
    private String phone;

    @Column(name = "company")
    private String company;

    @Column(name = "job_title")
    private String jobTitle;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private LeadStatus status = LeadStatus.NEW;

    @Enumerated(EnumType.STRING)
    @Column(name = "source")
    private LeadSource source;

    @Column(name = "estimated_value", precision = 19, scale = 2)
    private BigDecimal estimatedValue;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "assigned_to")
    private Long assignedTo;

    @Column(name = "qualification_score")
    private Integer qualificationScore;

    @Column(name = "conversion_probability")
    private Integer conversionProbability;

    @Column(name = "last_contact_date")
    private LocalDateTime lastContactDate;

    @Column(name = "next_follow_up_date")
    private LocalDateTime nextFollowUpDate;

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
    public Lead() {}

    public Lead(String firstName, String lastName, String email) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }

    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }

    public LeadStatus getStatus() { return status; }
    public void setStatus(LeadStatus status) { this.status = status; }

    public LeadSource getSource() { return source; }
    public void setSource(LeadSource source) { this.source = source; }

    public BigDecimal getEstimatedValue() { return estimatedValue; }
    public void setEstimatedValue(BigDecimal estimatedValue) { this.estimatedValue = estimatedValue; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Long getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Long assignedTo) { this.assignedTo = assignedTo; }

    public Integer getQualificationScore() { return qualificationScore; }
    public void setQualificationScore(Integer qualificationScore) { this.qualificationScore = qualificationScore; }

    public Integer getConversionProbability() { return conversionProbability; }
    public void setConversionProbability(Integer conversionProbability) { this.conversionProbability = conversionProbability; }

    public LocalDateTime getLastContactDate() { return lastContactDate; }
    public void setLastContactDate(LocalDateTime lastContactDate) { this.lastContactDate = lastContactDate; }

    public LocalDateTime getNextFollowUpDate() { return nextFollowUpDate; }
    public void setNextFollowUpDate(LocalDateTime nextFollowUpDate) { this.nextFollowUpDate = nextFollowUpDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}