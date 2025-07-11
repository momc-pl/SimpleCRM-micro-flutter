package com.simplecrm.entity;

import com.simplecrm.shared.entity.BaseEntity;

import javax.persistence.*;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product extends BaseEntity {

    @NotBlank
    @Size(max = 200)
    @Column(name = "name", nullable = false)
    private String name;

    @Size(max = 1000)
    @Column(name = "description")
    private String description;

    @NotBlank
    @Size(max = 50)
    @Column(name = "sku", nullable = false, unique = true)
    private String sku;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    @Column(name = "price", nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @NotNull
    @Column(name = "quantity_in_stock", nullable = false)
    private Integer quantityInStock;

    @NotNull
    @Column(name = "min_stock_level", nullable = false)
    private Integer minStockLevel = 0;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ProductStatus status = ProductStatus.ACTIVE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ProductCategory category;

    @Size(max = 100)
    @Column(name = "brand")
    private String brand;

    @Size(max = 50)
    @Column(name = "unit_of_measure")
    private String unitOfMeasure;

    @Column(name = "weight", precision = 8, scale = 2)
    private BigDecimal weight;

    @Size(max = 500)
    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "is_featured")
    private Boolean isFeatured = false;

    // Default constructor
    public Product() {}

    // Constructor with essential fields
    public Product(String name, String sku, BigDecimal price, Integer quantityInStock) {
        this.name = name;
        this.sku = sku;
        this.price = price;
        this.quantityInStock = quantityInStock;
    }

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Integer getQuantityInStock() {
        return quantityInStock;
    }

    public void setQuantityInStock(Integer quantityInStock) {
        this.quantityInStock = quantityInStock;
    }

    public Integer getMinStockLevel() {
        return minStockLevel;
    }

    public void setMinStockLevel(Integer minStockLevel) {
        this.minStockLevel = minStockLevel;
    }

    public ProductStatus getStatus() {
        return status;
    }

    public void setStatus(ProductStatus status) {
        this.status = status;
    }

    public ProductCategory getCategory() {
        return category;
    }

    public void setCategory(ProductCategory category) {
        this.category = category;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getUnitOfMeasure() {
        return unitOfMeasure;
    }

    public void setUnitOfMeasure(String unitOfMeasure) {
        this.unitOfMeasure = unitOfMeasure;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Boolean getIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(Boolean isFeatured) {
        this.isFeatured = isFeatured;
    }

    // Business methods
    public boolean isLowStock() {
        return quantityInStock <= minStockLevel;
    }

    public boolean isOutOfStock() {
        return quantityInStock <= 0;
    }

    public void reduceStock(Integer quantity) {
        if (quantity > quantityInStock) {
            throw new IllegalArgumentException("Insufficient stock");
        }
        this.quantityInStock -= quantity;
    }

    public void increaseStock(Integer quantity) {
        this.quantityInStock += quantity;
    }
}