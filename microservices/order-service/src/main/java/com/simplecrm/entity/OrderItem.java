package com.simplecrm.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "order_lines")
@EntityListeners(AuditingEntityListener.class)
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    @JsonIgnore
    private Order order;

    // Product information (denormalized for performance)
    @NotNull
    @Column(name = "product_id", nullable = false)
    private Long productId; // Reference to product-service

    @NotBlank
    @Size(max = 255)
    @Column(name = "product_name", nullable = false)
    private String productName;

    @NotBlank
    @Size(max = 100)
    @Column(name = "product_sku", nullable = false)
    private String productSku;

    // Pricing and quantity
    @NotNull
    @Min(1)
    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(name = "unit_price_net", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPriceNet;

    @NotNull
    @DecimalMin(value = "0.0")
    @Column(name = "vat_rate", nullable = false, precision = 5, scale = 4)
    private BigDecimal vatRate;

    @NotNull
    @DecimalMin(value = "0.0")
    @Column(name = "line_vat", nullable = false, precision = 10, scale = 2)
    private BigDecimal lineVat;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(name = "line_total_gross", nullable = false, precision = 10, scale = 2)
    private BigDecimal lineTotalGross;

    // Additional metadata
    @Size(max = 1000)
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // Constructors
    public OrderItem() {}

    public OrderItem(Long productId, String productName, String productSku, 
                    Integer quantity, BigDecimal unitPriceNet, BigDecimal vatRate) {
        this.productId = productId;
        this.productName = productName;
        this.productSku = productSku;
        this.quantity = quantity;
        this.unitPriceNet = unitPriceNet;
        this.vatRate = vatRate;
        calculateLineAmounts();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
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
        calculateLineAmounts();
    }

    public BigDecimal getUnitPriceNet() {
        return unitPriceNet;
    }

    public void setUnitPriceNet(BigDecimal unitPriceNet) {
        this.unitPriceNet = unitPriceNet;
        calculateLineAmounts();
    }

    public BigDecimal getVatRate() {
        return vatRate;
    }

    public void setVatRate(BigDecimal vatRate) {
        this.vatRate = vatRate;
        calculateLineAmounts();
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

    // Business methods
    private void calculateLineAmounts() {
        if (quantity != null && unitPriceNet != null && vatRate != null) {
            BigDecimal lineNetTotal = unitPriceNet.multiply(BigDecimal.valueOf(quantity));
            lineVat = lineNetTotal.multiply(vatRate).setScale(2, BigDecimal.ROUND_HALF_UP);
            lineTotalGross = lineNetTotal.add(lineVat).setScale(2, BigDecimal.ROUND_HALF_UP);
        }
    }

    public BigDecimal getLineNetTotal() {
        return unitPriceNet != null && quantity != null ? 
               unitPriceNet.multiply(BigDecimal.valueOf(quantity)) : BigDecimal.ZERO;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof OrderItem)) return false;
        OrderItem orderItem = (OrderItem) o;
        return id != null && id.equals(orderItem.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}