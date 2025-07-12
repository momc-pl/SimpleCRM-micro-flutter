package com.simplecrm.dto;

import com.simplecrm.entity.OrderStatus;
import com.simplecrm.entity.PaymentStatus;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.Size;
import java.math.BigDecimal;

public class OrderUpdateRequest {

    @Size(max = 2000, message = "Notes must not exceed 2000 characters")
    private String notes;

    @Size(max = 2000, message = "Internal notes must not exceed 2000 characters")
    private String internalNotes;

    private String shippingAddress; // JSON string

    private String billingAddress; // JSON string

    @DecimalMin(value = "0.0", message = "Shipping cost must be non-negative")
    private BigDecimal shippingCost;

    @DecimalMin(value = "0.0", message = "Discount amount must be non-negative")
    private BigDecimal discountAmount;

    private OrderStatus status;

    private PaymentStatus paymentStatus;

    // Constructors
    public OrderUpdateRequest() {}

    public OrderUpdateRequest(String notes, String internalNotes, String shippingAddress,
                             String billingAddress, BigDecimal shippingCost, 
                             BigDecimal discountAmount, OrderStatus status, 
                             PaymentStatus paymentStatus) {
        this.notes = notes;
        this.internalNotes = internalNotes;
        this.shippingAddress = shippingAddress;
        this.billingAddress = billingAddress;
        this.shippingCost = shippingCost;
        this.discountAmount = discountAmount;
        this.status = status;
        this.paymentStatus = paymentStatus;
    }

    // Getters and Setters
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

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

    public PaymentStatus getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
}