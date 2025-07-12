package com.simplecrm.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class OrderItemDto {
    private Long id;
    private Long productId;
    private String productName;
    private String productSku;
    private Integer quantity;
    private BigDecimal unitPriceNet;
    private BigDecimal vatRate;
    private BigDecimal lineVat;
    private BigDecimal lineTotalGross;
    private String notes;
    private LocalDateTime createdAt;

    // Derived fields for display
    private BigDecimal lineNetTotal;

    // Constructors
    public OrderItemDto() {}

    public OrderItemDto(Long id, Long productId, String productName, String productSku,
                       Integer quantity, BigDecimal unitPriceNet, BigDecimal vatRate,
                       BigDecimal lineVat, BigDecimal lineTotalGross, String notes,
                       LocalDateTime createdAt) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.productSku = productSku;
        this.quantity = quantity;
        this.unitPriceNet = unitPriceNet;
        this.vatRate = vatRate;
        this.lineVat = lineVat;
        this.lineTotalGross = lineTotalGross;
        this.notes = notes;
        this.createdAt = createdAt;
        
        // Calculate derived field
        this.lineNetTotal = unitPriceNet != null && quantity != null ? 
                           unitPriceNet.multiply(BigDecimal.valueOf(quantity)) : BigDecimal.ZERO;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductSku() {
        return productSku;
    }

    public void setProductSku(String productSku) {
        this.productSku = productSku;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
        // Recalculate derived field
        this.lineNetTotal = unitPriceNet != null && quantity != null ? 
                           unitPriceNet.multiply(BigDecimal.valueOf(quantity)) : BigDecimal.ZERO;
    }

    public BigDecimal getUnitPriceNet() {
        return unitPriceNet;
    }

    public void setUnitPriceNet(BigDecimal unitPriceNet) {
        this.unitPriceNet = unitPriceNet;
        // Recalculate derived field
        this.lineNetTotal = unitPriceNet != null && quantity != null ? 
                           unitPriceNet.multiply(BigDecimal.valueOf(quantity)) : BigDecimal.ZERO;
    }

    public BigDecimal getVatRate() {
        return vatRate;
    }

    public void setVatRate(BigDecimal vatRate) {
        this.vatRate = vatRate;
    }

    public BigDecimal getLineVat() {
        return lineVat;
    }

    public void setLineVat(BigDecimal lineVat) {
        this.lineVat = lineVat;
    }

    public BigDecimal getLineTotalGross() {
        return lineTotalGross;
    }

    public void setLineTotalGross(BigDecimal lineTotalGross) {
        this.lineTotalGross = lineTotalGross;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public BigDecimal getLineNetTotal() {
        return lineNetTotal;
    }

    public void setLineNetTotal(BigDecimal lineNetTotal) {
        this.lineNetTotal = lineNetTotal;
    }
}