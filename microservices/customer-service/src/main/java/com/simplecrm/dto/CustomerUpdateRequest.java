package com.simplecrm.dto;

import com.simplecrm.entity.CustomerStatus;
import com.simplecrm.entity.CustomerType;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

public class CustomerUpdateRequest {
    @NotBlank(message = "Customer name is required")
    @Size(min = 2, max = 100, message = "Customer name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phone;

    @Size(max = 100, message = "Company name must not exceed 100 characters")
    private String company;

    private CustomerType customerType = CustomerType.INDIVIDUAL;

    private CustomerStatus status = CustomerStatus.ACTIVE;

    private String notes;

    // Constructors
    public CustomerUpdateRequest() {}

    public CustomerUpdateRequest(String name, String email, String phone, String company, 
                               CustomerType customerType, CustomerStatus status, String notes) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.company = company;
        this.customerType = customerType;
        this.status = status;
        this.notes = notes;
    }

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public CustomerType getCustomerType() {
        return customerType;
    }

    public void setCustomerType(CustomerType customerType) {
        this.customerType = customerType;
    }

    public CustomerStatus getStatus() {
        return status;
    }

    public void setStatus(CustomerStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}