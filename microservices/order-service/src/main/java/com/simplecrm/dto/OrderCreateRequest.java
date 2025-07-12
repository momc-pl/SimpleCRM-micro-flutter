package com.simplecrm.dto;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public class OrderCreateRequest {

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @Size(max = 2000, message = "Notes must not exceed 2000 characters")
    private String notes;

    @Size(max = 2000, message = "Internal notes must not exceed 2000 characters")
    private String internalNotes;

    private String shippingAddress; // JSON string

    private String billingAddress; // JSON string

    private BigDecimal shippingCost = BigDecimal.ZERO;

    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Valid
    @NotNull(message = "Order items are required")
    @Size(min = 1, message = "At least one order item is required")
    private List<OrderItemCreateRequest> orderItems;

    // Constructors
    public OrderCreateRequest() {}

    public OrderCreateRequest(Long customerId, String notes, String shippingAddress, 
                             String billingAddress, BigDecimal shippingCost, 
                             BigDecimal discountAmount, List<OrderItemCreateRequest> orderItems) {
        this.customerId = customerId;
        this.notes = notes;
        this.shippingAddress = shippingAddress;
        this.billingAddress = billingAddress;
        this.shippingCost = shippingCost;
        this.discountAmount = discountAmount;
        this.orderItems = orderItems;
    }

    // Getters and Setters
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

    public String getInternalNotes() {
        return internalNotes;
    }

    public void setInternalNotes(String internalNotes) {
        this.internalNotes = internalNotes;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public BigDecimal getShippingCost() {
        return shippingCost;
    }

    public void setShippingCost(BigDecimal shippingCost) {
        this.shippingCost = shippingCost;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public List<OrderItemCreateRequest> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItemCreateRequest> orderItems) {
        this.orderItems = orderItems;
    }
}