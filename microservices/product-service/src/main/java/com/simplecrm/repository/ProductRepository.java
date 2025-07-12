package com.simplecrm.repository;

import com.simplecrm.entity.Product;
import com.simplecrm.entity.ProductStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    Optional<Product> findBySku(String sku);

    List<Product> findByUserId(Long userId);

    List<Product> findByStatus(ProductStatus status);

    List<Product> findByCategoryId(Long categoryId);

    Page<Product> findByUserId(Long userId, Pageable pageable);

    Page<Product> findByStatus(ProductStatus status, Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.status = :status")
    Page<Product> findByUserIdAndStatus(@Param("userId") Long userId, 
                                       @Param("status") ProductStatus status, 
                                       Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND " +
           "(LOWER(p.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.description) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.sku) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(p.brand) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Product> findByUserIdAndSearchTerm(@Param("userId") Long userId, 
                                           @Param("search") String search, 
                                           Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.category.id = :categoryId")
    Page<Product> findByUserIdAndCategoryId(@Param("userId") Long userId, 
                                           @Param("categoryId") Long categoryId, 
                                           Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.isFeatured = true")
    Page<Product> findByUserIdAndIsFeatured(@Param("userId") Long userId, Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.quantityInStock <= p.minStockLevel")
    List<Product> findLowStockProducts(@Param("userId") Long userId);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.quantityInStock = 0")
    List<Product> findOutOfStockProducts(@Param("userId") Long userId);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.price BETWEEN :minPrice AND :maxPrice")
    Page<Product> findByUserIdAndPriceBetween(@Param("userId") Long userId, 
                                             @Param("minPrice") BigDecimal minPrice, 
                                             @Param("maxPrice") BigDecimal maxPrice, 
                                             Pageable pageable);

    @Query("SELECT COUNT(p) FROM Product p WHERE p.userId = :userId")
    Long countByUserId(@Param("userId") Long userId);

    @Query("SELECT COUNT(p) FROM Product p WHERE p.userId = :userId AND p.status = :status")
    Long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") ProductStatus status);

    @Query("SELECT COUNT(p) FROM Product p WHERE p.userId = :userId AND p.category.id = :categoryId")
    Long countByUserIdAndCategoryId(@Param("userId") Long userId, @Param("categoryId") Long categoryId);

    boolean existsBySku(String sku);

    boolean existsBySkuAndIdNot(String sku, Long id);

    @Query("SELECT p FROM Product p WHERE p.userId = :userId AND p.id = :id")
    Optional<Product> findByUserIdAndId(@Param("userId") Long userId, @Param("id") Long id);
}