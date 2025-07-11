package com.simplecrm.dto;

import com.simplecrm.entity.ContactStatus;
import com.simplecrm.entity.ContactType;

import javax.validation.constraints.Email;
import javax.validation.constraints.Size;

public class ContactUpdateRequest {

    @Size(max = 100, message = "First name must be less than 100 characters")
    private String firstName;

    @Size(max = 100, message = "Last name must be less than 100 characters")
    private String lastName;

    @Email(message = "Email must be valid")
    @Size(max = 200, message = "Email must be less than 200 characters")
    private String email;

    @Size(max = 20, message = "Phone must be less than 20 characters")
    private String phone;

    @Size(max = 20, message = "Mobile must be less than 20 characters")
    private String mobile;

    @Size(max = 100, message = "Job title must be less than 100 characters")
    private String jobTitle;

    @Size(max = 100, message = "Department must be less than 100 characters")
    private String department;

    @Size(max = 100, message = "Company must be less than 100 characters")
    private String company;

    private ContactType contactType;

    private ContactStatus status;

    private Long customerId;

    @Size(max = 500, message = "Notes must be less than 500 characters")
    private String notes;

    @Size(max = 200, message = "Address line 1 must be less than 200 characters")
    private String addressLine1;

    @Size(max = 200, message = "Address line 2 must be less than 200 characters")
    private String addressLine2;

    @Size(max = 100, message = "City must be less than 100 characters")
    private String city;

    @Size(max = 100, message = "State must be less than 100 characters")
    private String state;

    @Size(max = 20, message = "Postal code must be less than 20 characters")
    private String postalCode;

    @Size(max = 100, message = "Country must be less than 100 characters")
    private String country;

    // Default constructor
    public ContactUpdateRequest() {}

    // Getters and Setters
    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
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

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public ContactType getContactType() {
        return contactType;
    }

    public void setContactType(ContactType contactType) {
        this.contactType = contactType;
    }

    public ContactStatus getStatus() {
        return status;
    }

    public void setStatus(ContactStatus status) {
        this.status = status;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getAddressLine1() {
        return addressLine1;
    }

    public void setAddressLine1(String addressLine1) {
        this.addressLine1 = addressLine1;
    }

    public String getAddressLine2() {
        return addressLine2;
    }

    public void setAddressLine2(String addressLine2) {
        this.addressLine2 = addressLine2;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }
}