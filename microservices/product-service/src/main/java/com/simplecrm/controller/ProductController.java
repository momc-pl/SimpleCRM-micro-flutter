package com.simplecrm.controller;

import com.simplecrm.dto.ProductCreateRequest;
import com.simplecrm.dto.ProductDto;
import com.simplecrm.dto.ProductUpdateRequest;
import com.simplecrm.entity.ProductStatus;
import com.simplecrm.service.ProductService;
import com.simplecrm.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/products")
@Validated
public class ProductController {

    private final ProductService productService;
    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public ProductController(ProductService productService, JwtTokenProvider jwtTokenProvider) {
        this.productService = productService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @PostMapping
    public ResponseEntity<ProductDto> createProduct(@Valid @RequestBody ProductCreateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ProductDto createdProduct = productService.createProduct(request, userId);
        return new ResponseEntity<>(createdProduct, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductDto> getProduct(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ProductDto product = productService.getProductById(id, userId);
        return ResponseEntity.ok(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductDto> updateProduct(@PathVariable Long id,
                                                   @Valid @RequestBody ProductUpdateRequest request,
                                                   HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ProductDto updatedProduct = productService.updateProduct(id, request, userId);
        return ResponseEntity.ok(updatedProduct);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        productService.deleteProduct(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<Page<ProductDto>> getProducts(
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.getProducts(userId, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<ProductDto>> searchProducts(
            @RequestParam("q") @NotBlank String query,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.searchProducts(userId, query, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<Page<ProductDto>> getProductsByStatus(
            @PathVariable ProductStatus status,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.getProductsByStatus(userId, status, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<Page<ProductDto>> getProductsByCategory(
            @PathVariable Long categoryId,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.getProductsByCategory(userId, categoryId, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/featured")
    public ResponseEntity<Page<ProductDto>> getFeaturedProducts(
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.getFeaturedProducts(userId, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/price-range")
    public ResponseEntity<Page<ProductDto>> getProductsByPriceRange(
            @RequestParam BigDecimal minPrice,
            @RequestParam BigDecimal maxPrice,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "size", defaultValue = "10") @Min(1) int size,
            @RequestParam(value = "sortBy", defaultValue = "createdAt") String sortBy,
            @RequestParam(value = "sortDirection", defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Page<ProductDto> products = productService.getProductsByPriceRange(userId, minPrice, maxPrice, page, size, sortBy, sortDirection);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/low-stock")
    public ResponseEntity<List<ProductDto>> getLowStockProducts(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        List<ProductDto> products = productService.getLowStockProducts(userId);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/out-of-stock")
    public ResponseEntity<List<ProductDto>> getOutOfStockProducts(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        List<ProductDto> products = productService.getOutOfStockProducts(userId);
        return ResponseEntity.ok(products);
    }

    @PutMapping("/{id}/stock")
    public ResponseEntity<ProductDto> updateStock(@PathVariable Long id,
                                                 @RequestParam Integer quantity,
                                                 HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        ProductDto updatedProduct = productService.updateStock(id, quantity, userId);
        return ResponseEntity.ok(updatedProduct);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getProductStats(HttpServletRequest httpRequest) {
        Long userId = getUserIdFromRequest(httpRequest);
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalProducts", productService.getProductCount(userId));
        stats.put("activeProducts", productService.getProductCountByStatus(userId, ProductStatus.ACTIVE));
        stats.put("inactiveProducts", productService.getProductCountByStatus(userId, ProductStatus.INACTIVE));
        stats.put("discontinuedProducts", productService.getProductCountByStatus(userId, ProductStatus.DISCONTINUED));
        stats.put("outOfStockProducts", productService.getProductCountByStatus(userId, ProductStatus.OUT_OF_STOCK));
        stats.put("backOrderProducts", productService.getProductCountByStatus(userId, ProductStatus.BACK_ORDER));
        stats.put("lowStockCount", productService.getLowStockProducts(userId).size());
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("service", "product-service");
        return ResponseEntity.ok(status);
    }

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String token = jwtTokenProvider.getTokenFromRequest(request);
        return jwtTokenProvider.getUserIdFromToken(token);
    }
}