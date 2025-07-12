package com.simplecrm.controller;

import com.simplecrm.dto.*;
import com.simplecrm.entity.OrderStatus;
import com.simplecrm.service.OrderService;
import com.simplecrm.shared.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@Validated
public class OrderController {

    private final OrderService orderService;

    @Autowired
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    /**
     * Create a new order
     */
    @PostMapping
    public ResponseEntity<ApiResponse<OrderDto>> createOrder(
            @Valid @RequestBody OrderCreateRequest request,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto createdOrder = orderService.createOrder(request, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order created successfully", createdOrder);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    /**
     * Get order by ID
     */
    @GetMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderDto>> getOrderById(
            @PathVariable Long orderId,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto order = orderService.getOrderById(orderId, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order retrieved successfully", order);
        return ResponseEntity.ok(response);
    }

    /**
     * Get order by order number
     */
    @GetMapping("/number/{orderNumber}")
    public ResponseEntity<ApiResponse<OrderDto>> getOrderByNumber(
            @PathVariable @NotBlank String orderNumber,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto order = orderService.getOrderByNumber(orderNumber, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order retrieved successfully", order);
        return ResponseEntity.ok(response);
    }

    /**
     * Get all orders with pagination
     */
    @GetMapping
    public ResponseEntity<ApiResponse<Page<OrderDto>>> getOrders(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "10") @Min(1) int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        Page<OrderDto> orders = orderService.getOrders(userId, page, size, sortBy, sortDirection);
        
        ApiResponse<Page<OrderDto>> response = new ApiResponse<>(
            true, "Orders retrieved successfully", orders);
        return ResponseEntity.ok(response);
    }

    /**
     * Get orders by customer
     */
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<ApiResponse<Page<OrderDto>>> getOrdersByCustomer(
            @PathVariable Long customerId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "10") @Min(1) int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        Page<OrderDto> orders = orderService.getOrdersByCustomer(
            customerId, userId, page, size, sortBy, sortDirection);
        
        ApiResponse<Page<OrderDto>> response = new ApiResponse<>(
            true, "Customer orders retrieved successfully", orders);
        return ResponseEntity.ok(response);
    }

    /**
     * Get orders by status
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<Page<OrderDto>>> getOrdersByStatus(
            @PathVariable OrderStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "10") @Min(1) int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        Page<OrderDto> orders = orderService.getOrdersByStatus(
            status, userId, page, size, sortBy, sortDirection);
        
        ApiResponse<Page<OrderDto>> response = new ApiResponse<>(
            true, "Orders by status retrieved successfully", orders);
        return ResponseEntity.ok(response);
    }

    /**
     * Search orders
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<Page<OrderDto>>> searchOrders(
            @RequestParam @NotBlank String q,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "10") @Min(1) int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        Page<OrderDto> orders = orderService.searchOrders(
            q, userId, page, size, sortBy, sortDirection);
        
        ApiResponse<Page<OrderDto>> response = new ApiResponse<>(
            true, "Orders search completed successfully", orders);
        return ResponseEntity.ok(response);
    }

    /**
     * Update order
     */
    @PutMapping("/{orderId}")
    public ResponseEntity<ApiResponse<OrderDto>> updateOrder(
            @PathVariable Long orderId,
            @Valid @RequestBody OrderUpdateRequest request,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto updatedOrder = orderService.updateOrder(orderId, request, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order updated successfully", updatedOrder);
        return ResponseEntity.ok(response);
    }

    /**
     * Confirm order
     */
    @PostMapping("/{orderId}/confirm")
    public ResponseEntity<ApiResponse<OrderDto>> confirmOrder(
            @PathVariable Long orderId,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto confirmedOrder = orderService.confirmOrder(orderId, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order confirmed successfully", confirmedOrder);
        return ResponseEntity.ok(response);
    }

    /**
     * Ship order
     */
    @PostMapping("/{orderId}/ship")
    public ResponseEntity<ApiResponse<OrderDto>> shipOrder(
            @PathVariable Long orderId,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto shippedOrder = orderService.shipOrder(orderId, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order shipped successfully", shippedOrder);
        return ResponseEntity.ok(response);
    }

    /**
     * Deliver order
     */
    @PostMapping("/{orderId}/deliver")
    public ResponseEntity<ApiResponse<OrderDto>> deliverOrder(
            @PathVariable Long orderId,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto deliveredOrder = orderService.deliverOrder(orderId, userId);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order delivered successfully", deliveredOrder);
        return ResponseEntity.ok(response);
    }

    /**
     * Cancel order
     */
    @PostMapping("/{orderId}/cancel")
    public ResponseEntity<ApiResponse<OrderDto>> cancelOrder(
            @PathVariable Long orderId,
            @RequestParam(required = false) String reason,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderDto cancelledOrder = orderService.cancelOrder(orderId, userId, reason);
        
        ApiResponse<OrderDto> response = new ApiResponse<>(
            true, "Order cancelled successfully", cancelledOrder);
        return ResponseEntity.ok(response);
    }

    /**
     * Delete order
     */
    @DeleteMapping("/{orderId}")
    public ResponseEntity<ApiResponse<Void>> deleteOrder(
            @PathVariable Long orderId,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        orderService.deleteOrder(orderId, userId);
        
        ApiResponse<Void> response = new ApiResponse<>(
            true, "Order deleted successfully", null);
        return ResponseEntity.ok(response);
    }

    /**
     * Get order statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<OrderService.OrderStatsDto>> getOrderStatistics(
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        OrderService.OrderStatsDto stats = orderService.getOrderStatistics(userId);
        
        ApiResponse<OrderService.OrderStatsDto> response = new ApiResponse<>(
            true, "Order statistics retrieved successfully", stats);
        return ResponseEntity.ok(response);
    }

    /**
     * Get daily sales report
     */
    @GetMapping("/reports/daily-sales")
    public ResponseEntity<ApiResponse<List<OrderService.DailySalesDto>>> getDailySalesReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            HttpServletRequest httpRequest) {
        
        Long userId = getUserId(httpRequest);
        List<OrderService.DailySalesDto> report = orderService.getDailySalesReport(userId, startDate, endDate);
        
        ApiResponse<List<OrderService.DailySalesDto>> response = new ApiResponse<>(
            true, "Daily sales report retrieved successfully", report);
        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        ApiResponse<String> response = new ApiResponse<>(
            true, "Order service is healthy", "OK");
        return ResponseEntity.ok(response);
    }

    // Helper method to extract user ID from request headers
    private Long getUserId(HttpServletRequest request) {
        String userIdHeader = request.getHeader("User-ID");
        if (userIdHeader == null || userIdHeader.trim().isEmpty()) {
            throw new IllegalArgumentException("User-ID header is required");
        }
        
        try {
            return Long.parseLong(userIdHeader.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid User-ID header format");
        }
    }
}