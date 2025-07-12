package com.simplecrm.dto;

import com.simplecrm.entity.LeadSource;
import com.simplecrm.entity.LeadStatus;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class LeadCreateRequest {
    @NotBlank(message = "First name is required")
    private String firstName;

    @NotBlank(message = "Last name is required")
    private String lastName;

    @Email(message = "Valid email is required")
    private String email;

    private String phone;
    private String company;
    private String jobTitle;
    private LeadStatus status;
    private LeadSource source;
    private BigDecimal estimatedValue;
    private String notes;
    private Long assignedTo;
    private Integer qualificationScore;
    private Integer conversionProbability;
    private LocalDateTime nextFollowUpDate;

    // Constructors
    public LeadCreateRequest() {}

    // Getters and Setters
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

    public LocalDateTime getNextFollowUpDate() { return nextFollowUpDate; }
    public void setNextFollowUpDate(LocalDateTime nextFollowUpDate) { this.nextFollowUpDate = nextFollowUpDate; }
}