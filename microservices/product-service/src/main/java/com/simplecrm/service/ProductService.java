package com.simplecrm.service;

import com.simplecrm.entity.Product;
import com.simplecrm.entity.ProductCategory;
import com.simplecrm.entity.ProductStatus;
import com.simplecrm.repository.ProductRepository;
import com.simplecrm.dto.ProductDto;
import com.simplecrm.dto.ProductCreateRequest;
import com.simplecrm.dto.ProductUpdateRequest;
import com.simplecrm.exception.ProductNotFoundException;
import com.simplecrm.exception.DuplicateSkuException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final EntityManager entityManager;

    @Autowired
    public ProductService(ProductRepository productRepository, EntityManager entityManager) {
        this.productRepository = productRepository;
        this.entityManager = entityManager;
    }

    public ProductDto createProduct(ProductCreateRequest request, Long userId) {
        // Check if SKU already exists
        if (productRepository.existsBySku(request.getSku())) {
            throw new DuplicateSkuException("Product with SKU " + request.getSku() + " already exists");
        }

        Product product = new Product();
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice());
        product.setQuantityInStock(request.getQuantityInStock());
        product.setMinStockLevel(request.getMinStockLevel());
        product.setBrand(request.getBrand());
        product.setUnitOfMeasure(request.getUnitOfMeasure());
        product.setWeight(request.getWeight());
        product.setImageUrl(request.getImageUrl());
        product.setIsFeatured(request.getIsFeatured());
        product.setUserId(userId);

        // Set category if provided
        if (request.getCategoryId() != null) {
            ProductCategory category = entityManager.getReference(ProductCategory.class, request.getCategoryId());
            product.setCategory(category);
        }

        Product savedProduct = productRepository.save(product);
        return convertToDto(savedProduct);
    }

    public ProductDto updateProduct(Long productId, ProductUpdateRequest request, Long userId) {
        Product product = productRepository.findByUserIdAndId(userId, productId)
                .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + productId));

        // Check if SKU is being changed and if it already exists
        if (!product.getSku().equals(request.getSku()) && 
            productRepository.existsBySkuAndIdNot(request.getSku(), productId)) {
            throw new DuplicateSkuException("Product with SKU " + request.getSku() + " already exists");
        }

        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice());
        product.setQuantityInStock(request.getQuantityInStock());
        product.setMinStockLevel(request.getMinStockLevel());
        product.setStatus(request.getStatus());
        product.setBrand(request.getBrand());
        product.setUnitOfMeasure(request.getUnitOfMeasure());
        product.setWeight(request.getWeight());
        product.setImageUrl(request.getImageUrl());
        product.setIsFeatured(request.getIsFeatured());

        // Update category if provided
        if (request.getCategoryId() != null) {
            ProductCategory category = entityManager.getReference(ProductCategory.class, request.getCategoryId());
            product.setCategory(category);
        } else {
            product.setCategory(null);
        }

        Product updatedProduct = productRepository.save(product);
        return convertToDto(updatedProduct);
    }

    @Transactional(readOnly = true)
    public ProductDto getProductById(Long productId, Long userId) {
        Product product = productRepository.findByUserIdAndId(userId, productId)
                .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + productId));

        return convertToDto(product);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProducts(Long userId, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserId(userId, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> searchProducts(Long userId, String search, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserIdAndSearchTerm(userId, search, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProductsByStatus(Long userId, ProductStatus status, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserIdAndStatus(userId, status, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProductsByCategory(Long userId, Long categoryId, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserIdAndCategoryId(userId, categoryId, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getFeaturedProducts(Long userId, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserIdAndIsFeatured(userId, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProductsByPriceRange(Long userId, BigDecimal minPrice, BigDecimal maxPrice, 
                                                   int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return productRepository.findByUserIdAndPriceBetween(userId, minPrice, maxPrice, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getLowStockProducts(Long userId) {
        return productRepository.findLowStockProducts(userId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getOutOfStockProducts(Long userId) {
        return productRepository.findOutOfStockProducts(userId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public void deleteProduct(Long productId, Long userId) {
        Product product = productRepository.findByUserIdAndId(userId, productId)
                .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + productId));

        productRepository.delete(product);
    }

    public ProductDto updateStock(Long productId, Integer quantity, Long userId) {
        Product product = productRepository.findByUserIdAndId(userId, productId)
                .orElseThrow(() -> new ProductNotFoundException("Product not found with id: " + productId));

        product.setQuantityInStock(quantity);
        
        // Update status based on stock level
        if (quantity <= 0) {
            product.setStatus(ProductStatus.OUT_OF_STOCK);
        } else if (product.getStatus() == ProductStatus.OUT_OF_STOCK) {
            product.setStatus(ProductStatus.ACTIVE);
        }

        Product updatedProduct = productRepository.save(product);
        return convertToDto(updatedProduct);
    }

    @Transactional(readOnly = true)
    public Long getProductCount(Long userId) {
        return productRepository.countByUserId(userId);
    }

    @Transactional(readOnly = true)
    public Long getProductCountByStatus(Long userId, ProductStatus status) {
        return productRepository.countByUserIdAndStatus(userId, status);
    }

    @Transactional(readOnly = true)
    public Long getProductCountByCategory(Long userId, Long categoryId) {
        return productRepository.countByUserIdAndCategoryId(userId, categoryId);
    }

    private ProductDto convertToDto(Product product) {
        return new ProductDto(
                product.getId(),
                product.getName(),
                product.getDescription(),
                product.getSku(),
                product.getPrice(),
                product.getQuantityInStock(),
                product.getMinStockLevel(),
                product.getStatus(),
                product.getCategory() != null ? product.getCategory().getId() : null,
                product.getCategory() != null ? product.getCategory().getName() : null,
                product.getBrand(),
                product.getUnitOfMeasure(),
                product.getWeight(),
                product.getImageUrl(),
                product.getIsFeatured(),
                product.getCreatedAt(),
                product.getUpdatedAt()
        );
    }
}