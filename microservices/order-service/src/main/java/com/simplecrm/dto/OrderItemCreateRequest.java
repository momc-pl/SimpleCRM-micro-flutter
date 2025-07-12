package com.simplecrm.dto;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.math.BigDecimal;

public class OrderItemCreateRequest {

    @NotNull(message = "Product ID is required")
    private Long productId;

    @NotBlank(message = "Product name is required")
    @Size(max = 255, message = "Product name must not exceed 255 characters")
    private String productName;

    @NotBlank(message = "Product SKU is required")
    @Size(max = 100, message = "Product SKU must not exceed 100 characters")
    private String productSku;

    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity;

    @NotNull(message = "Unit price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Unit price must be positive")
    private BigDecimal unitPriceNet;

    @NotNull(message = "VAT rate is required")
    @DecimalMin(value = "0.0", message = "VAT rate must be non-negative")
    private BigDecimal vatRate;

    @Size(max = 1000, message = "Notes must not exceed 1000 characters")
    private String notes;

    // Constructors
    public OrderItemCreateRequest() {}

    public OrderItemCreateRequest(Long productId, String productName, String productSku,
                                 Integer quantity, BigDecimal unitPriceNet, BigDecimal vatRate) {
        this.productId = productId;
        this.productName = productName;
        this.productSku = productSku;
        this.quantity = quantity;
        this.unitPriceNet = unitPriceNet;
        this.vatRate = vatRate;
    }

    public OrderItemCreateRequest(Long productId, String productName, String productSku,
                                 Integer quantity, BigDecimal unitPriceNet, BigDecimal vatRate,
                                 String notes) {
        this.productId = productId;
        this.productName = productName;
        this.productSku = productSku;
        this.quantity = quantity;
        this.unitPriceNet = unitPriceNet;
        this.vatRate = vatRate;
        this.notes = notes;
    }

    // Getters and Setters
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
    }

    public BigDecimal getUnitPriceNet() {
        return unitPriceNet;
    }

    public void setUnitPriceNet(BigDecimal unitPriceNet) {
        this.unitPriceNet = unitPriceNet;
    }

    public BigDecimal getVatRate() {
        return vatRate;
    }

    public void setVatRate(BigDecimal vatRate) {
        this.vatRate = vatRate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    // Business methods
    public BigDecimal calculateLineVat() {
        if (quantity != null && unitPriceNet != null && vatRate != null) {
            BigDecimal lineNetTotal = unitPriceNet.multiply(BigDecimal.valueOf(quantity));
            return lineNetTotal.multiply(vatRate).setScale(2, BigDecimal.ROUND_HALF_UP);
        }
        return BigDecimal.ZERO;
    }

    public BigDecimal calculateLineTotalGross() {
        if (quantity != null && unitPriceNet != null && vatRate != null) {
            BigDecimal lineNetTotal = unitPriceNet.multiply(BigDecimal.valueOf(quantity));
            BigDecimal lineVat = lineNetTotal.multiply(vatRate).setScale(2, BigDecimal.ROUND_HALF_UP);
            return lineNetTotal.add(lineVat).setScale(2, BigDecimal.ROUND_HALF_UP);
        }
        return BigDecimal.ZERO;
    }
}