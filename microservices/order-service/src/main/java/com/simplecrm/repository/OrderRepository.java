package com.simplecrm.repository;

import com.simplecrm.entity.Order;
import com.simplecrm.entity.OrderStatus;
import com.simplecrm.entity.PaymentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // Multi-tenant queries - all include userId for tenant isolation
    
    /**
     * Find order by ID and user (multi-tenant)
     */
    Optional<Order> findByUserIdAndId(Long userId, Long id);

    /**
     * Find order by order number and user (multi-tenant)
     */
    Optional<Order> findByUserIdAndOrderNumber(Long userId, String orderNumber);

    /**
     * Find all orders for a user with pagination
     */
    Page<Order> findByUserId(Long userId, Pageable pageable);

    /**
     * Find orders by customer and user
     */
    Page<Order> findByUserIdAndCustomerId(Long userId, Long customerId, Pageable pageable);

    /**
     * Find orders by status and user
     */
    Page<Order> findByUserIdAndStatus(Long userId, OrderStatus status, Pageable pageable);

    /**
     * Find orders by payment status and user
     */
    Page<Order> findByUserIdAndPaymentStatus(Long userId, PaymentStatus paymentStatus, Pageable pageable);

    /**
     * Find orders by status and payment status
     */
    Page<Order> findByUserIdAndStatusAndPaymentStatus(Long userId, OrderStatus status, 
                                                     PaymentStatus paymentStatus, Pageable pageable);

    /**
     * Find orders created within date range
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.createdAt BETWEEN :startDate AND :endDate")
    Page<Order> findByUserIdAndCreatedAtBetween(@Param("userId") Long userId, 
                                               @Param("startDate") LocalDateTime startDate,
                                               @Param("endDate") LocalDateTime endDate, 
                                               Pageable pageable);

    /**
     * Find orders by total amount range
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.totalGross BETWEEN :minAmount AND :maxAmount")
    Page<Order> findByUserIdAndTotalGrossBetween(@Param("userId") Long userId,
                                                @Param("minAmount") BigDecimal minAmount,
                                                @Param("maxAmount") BigDecimal maxAmount,
                                                Pageable pageable);

    /**
     * Search orders by order number or customer reference
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND " +
           "(LOWER(o.orderNumber) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(o.notes) LIKE LOWER(CONCAT('%', :searchTerm, '%')))")
    Page<Order> findByUserIdAndSearchTerm(@Param("userId") Long userId, 
                                         @Param("searchTerm") String searchTerm, 
                                         Pageable pageable);

    /**
     * Find pending orders (older than specified hours)
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.status = 'PENDING' AND " +
           "o.createdAt < :cutoffTime")
    List<Order> findPendingOrdersOlderThan(@Param("userId") Long userId, 
                                          @Param("cutoffTime") LocalDateTime cutoffTime);

    /**
     * Find orders requiring attention (pending payment, processing delays)
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND " +
           "((o.status = 'CONFIRMED' AND o.paymentStatus = 'PENDING' AND o.confirmedAt < :paymentCutoff) OR " +
           "(o.status = 'PROCESSING' AND o.confirmedAt < :processingCutoff))")
    List<Order> findOrdersRequiringAttention(@Param("userId") Long userId,
                                            @Param("paymentCutoff") LocalDateTime paymentCutoff,
                                            @Param("processingCutoff") LocalDateTime processingCutoff);

    // Aggregate queries for reporting

    /**
     * Count orders by user
     */
    long countByUserId(Long userId);

    /**
     * Count orders by status and user
     */
    long countByUserIdAndStatus(Long userId, OrderStatus status);

    /**
     * Count orders by payment status and user
     */
    long countByUserIdAndPaymentStatus(Long userId, PaymentStatus paymentStatus);

    /**
     * Sum total revenue for user
     */
    @Query("SELECT COALESCE(SUM(o.totalGross), 0) FROM Order o WHERE o.userId = :userId AND " +
           "o.status NOT IN ('CANCELLED', 'REFUNDED')")
    BigDecimal sumTotalRevenueByUserId(@Param("userId") Long userId);

    /**
     * Sum revenue by date range
     */
    @Query("SELECT COALESCE(SUM(o.totalGross), 0) FROM Order o WHERE o.userId = :userId AND " +
           "o.status NOT IN ('CANCELLED', 'REFUNDED') AND o.createdAt BETWEEN :startDate AND :endDate")
    BigDecimal sumRevenueByUserIdAndDateRange(@Param("userId") Long userId,
                                             @Param("startDate") LocalDateTime startDate,
                                             @Param("endDate") LocalDateTime endDate);

    /**
     * Get average order value for user
     */
    @Query("SELECT AVG(o.totalGross) FROM Order o WHERE o.userId = :userId AND " +
           "o.status NOT IN ('CANCELLED', 'REFUNDED')")
    BigDecimal getAverageOrderValueByUserId(@Param("userId") Long userId);

    /**
     * Find top customers by order value
     */
    @Query("SELECT o.customerId, COUNT(o.id) as orderCount, SUM(o.totalGross) as totalSpent " +
           "FROM Order o WHERE o.userId = :userId AND o.status NOT IN ('CANCELLED', 'REFUNDED') " +
           "GROUP BY o.customerId ORDER BY SUM(o.totalGross) DESC")
    List<Object[]> findTopCustomersBySpending(@Param("userId") Long userId, Pageable pageable);

    /**
     * Daily sales report
     */
    @Query("SELECT DATE(o.createdAt) as saleDate, COUNT(o.id) as orderCount, " +
           "SUM(o.totalGross) as totalRevenue, AVG(o.totalGross) as avgOrderValue " +
           "FROM Order o WHERE o.userId = :userId AND o.status NOT IN ('CANCELLED', 'REFUNDED') " +
           "AND o.createdAt BETWEEN :startDate AND :endDate " +
           "GROUP BY DATE(o.createdAt) ORDER BY DATE(o.createdAt) DESC")
    List<Object[]> getDailySalesReport(@Param("userId") Long userId,
                                      @Param("startDate") LocalDateTime startDate,
                                      @Param("endDate") LocalDateTime endDate);

    /**
     * Monthly sales report
     */
    @Query("SELECT YEAR(o.createdAt) as year, MONTH(o.createdAt) as month, " +
           "COUNT(o.id) as orderCount, SUM(o.totalGross) as totalRevenue " +
           "FROM Order o WHERE o.userId = :userId AND o.status NOT IN ('CANCELLED', 'REFUNDED') " +
           "GROUP BY YEAR(o.createdAt), MONTH(o.createdAt) " +
           "ORDER BY YEAR(o.createdAt) DESC, MONTH(o.createdAt) DESC")
    List<Object[]> getMonthlySalesReport(@Param("userId") Long userId);

    /**
     * Order status distribution
     */
    @Query("SELECT o.status, COUNT(o.id) FROM Order o WHERE o.userId = :userId " +
           "GROUP BY o.status")
    List<Object[]> getOrderStatusDistribution(@Param("userId") Long userId);

    /**
     * Check if order number exists for user (for uniqueness validation)
     */
    boolean existsByUserIdAndOrderNumber(Long userId, String orderNumber);

    /**
     * Find recent orders for customer
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.customerId = :customerId " +
           "ORDER BY o.createdAt DESC")
    List<Order> findRecentOrdersByCustomer(@Param("userId") Long userId, 
                                          @Param("customerId") Long customerId, 
                                          Pageable pageable);

    /**
     * Find orders with specific product
     */
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi " +
           "WHERE o.userId = :userId AND oi.productId = :productId")
    List<Order> findOrdersWithProduct(@Param("userId") Long userId, @Param("productId") Long productId);

    /**
     * Delete orders older than specified date (for cleanup)
     */
    void deleteByUserIdAndCreatedAtBefore(Long userId, LocalDateTime cutoffDate);
}