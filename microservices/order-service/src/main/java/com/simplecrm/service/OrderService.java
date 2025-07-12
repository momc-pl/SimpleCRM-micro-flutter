package com.simplecrm.service;

import com.simplecrm.dto.*;
import com.simplecrm.entity.*;
import com.simplecrm.exception.*;
import com.simplecrm.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final RestTemplate restTemplate;

    @Autowired
    public OrderService(OrderRepository orderRepository, RestTemplate restTemplate) {
        this.orderRepository = orderRepository;
        this.restTemplate = restTemplate;
    }

    /**
     * Create a new order
     */
    public OrderDto createOrder(OrderCreateRequest request, Long userId) {
        // Validate customer exists (call to customer-service)
        validateCustomerExists(request.getCustomerId(), userId);

        // Validate products and stock availability
        validateProductsAndStock(request.getOrderItems(), userId);

        // Generate unique order number
        String orderNumber = generateOrderNumber();
        while (orderRepository.existsByUserIdAndOrderNumber(userId, orderNumber)) {
            orderNumber = generateOrderNumber();
        }

        // Create order entity
        Order order = new Order(orderNumber, request.getCustomerId(), userId);
        order.setNotes(request.getNotes());
        order.setInternalNotes(request.getInternalNotes());
        order.setShippingAddress(request.getShippingAddress());
        order.setBillingAddress(request.getBillingAddress());
        order.setShippingCost(request.getShippingCost() != null ? request.getShippingCost() : BigDecimal.ZERO);
        order.setDiscountAmount(request.getDiscountAmount() != null ? request.getDiscountAmount() : BigDecimal.ZERO);

        // Add order items
        for (OrderItemCreateRequest itemRequest : request.getOrderItems()) {
            OrderItem orderItem = new OrderItem(
                itemRequest.getProductId(),
                itemRequest.getProductName(),
                itemRequest.getProductSku(),
                itemRequest.getQuantity(),
                itemRequest.getUnitPriceNet(),
                itemRequest.getVatRate()
            );
            orderItem.setNotes(itemRequest.getNotes());
            order.addOrderItem(orderItem);
        }

        // Save order
        Order savedOrder = orderRepository.save(order);

        // Reserve stock in product service
        reserveStock(savedOrder.getOrderItems(), userId);

        return convertToDto(savedOrder, true);
    }

    /**
     * Update an existing order (only if in PENDING status)
     */
    public OrderDto updateOrder(Long orderId, OrderUpdateRequest request, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (!order.canBeModified()) {
            throw new InvalidOrderStateException(
                "Order cannot be modified in status: " + order.getStatus());
        }

        // Update fields if provided
        if (request.getNotes() != null) {
            order.setNotes(request.getNotes());
        }
        if (request.getInternalNotes() != null) {
            order.setInternalNotes(request.getInternalNotes());
        }
        if (request.getShippingAddress() != null) {
            order.setShippingAddress(request.getShippingAddress());
        }
        if (request.getBillingAddress() != null) {
            order.setBillingAddress(request.getBillingAddress());
        }
        if (request.getShippingCost() != null) {
            order.setShippingCost(request.getShippingCost());
            order.recalculateTotals();
        }
        if (request.getDiscountAmount() != null) {
            order.setDiscountAmount(request.getDiscountAmount());
            order.recalculateTotals();
        }
        if (request.getPaymentStatus() != null) {
            order.setPaymentStatus(request.getPaymentStatus());
        }

        Order updatedOrder = orderRepository.save(order);
        return convertToDto(updatedOrder, true);
    }

    /**
     * Get order by ID
     */
    @Transactional(readOnly = true)
    public OrderDto getOrderById(Long orderId, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        return convertToDto(order, true);
    }

    /**
     * Get order by order number
     */
    @Transactional(readOnly = true)
    public OrderDto getOrderByNumber(String orderNumber, Long userId) {
        Order order = orderRepository.findByUserIdAndOrderNumber(userId, orderNumber)
                .orElseThrow(() -> new OrderNotFoundException(orderNumber, "order number"));

        return convertToDto(order, true);
    }

    /**
     * Get all orders with pagination
     */
    @Transactional(readOnly = true)
    public Page<OrderDto> getOrders(Long userId, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return orderRepository.findByUserId(userId, pageable)
                .map(order -> convertToDto(order, false));
    }

    /**
     * Get orders by customer
     */
    @Transactional(readOnly = true)
    public Page<OrderDto> getOrdersByCustomer(Long customerId, Long userId, int page, int size, 
                                             String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return orderRepository.findByUserIdAndCustomerId(userId, customerId, pageable)
                .map(order -> convertToDto(order, false));
    }

    /**
     * Get orders by status
     */
    @Transactional(readOnly = true)
    public Page<OrderDto> getOrdersByStatus(OrderStatus status, Long userId, int page, int size, 
                                           String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return orderRepository.findByUserIdAndStatus(userId, status, pageable)
                .map(order -> convertToDto(order, false));
    }

    /**
     * Search orders
     */
    @Transactional(readOnly = true)
    public Page<OrderDto> searchOrders(String searchTerm, Long userId, int page, int size, 
                                      String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return orderRepository.findByUserIdAndSearchTerm(userId, searchTerm, pageable)
                .map(order -> convertToDto(order, false));
    }

    /**
     * Confirm order (change status from PENDING to CONFIRMED)
     */
    public OrderDto confirmOrder(Long orderId, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (order.getStatus() != OrderStatus.PENDING) {
            throw new InvalidOrderStateException("Only pending orders can be confirmed");
        }

        order.confirm();
        Order savedOrder = orderRepository.save(order);

        return convertToDto(savedOrder, true);
    }

    /**
     * Ship order
     */
    public OrderDto shipOrder(Long orderId, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (!order.canBeShipped()) {
            throw new InvalidOrderStateException(
                "Order cannot be shipped in status: " + order.getStatus());
        }

        order.ship();
        Order savedOrder = orderRepository.save(order);

        return convertToDto(savedOrder, true);
    }

    /**
     * Deliver order
     */
    public OrderDto deliverOrder(Long orderId, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (!order.canBeDelivered()) {
            throw new InvalidOrderStateException(
                "Order cannot be delivered in status: " + order.getStatus());
        }

        order.deliver();
        Order savedOrder = orderRepository.save(order);

        return convertToDto(savedOrder, true);
    }

    /**
     * Cancel order
     */
    public OrderDto cancelOrder(Long orderId, Long userId, String reason) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (!order.canBeCancelled()) {
            throw new InvalidOrderStateException(
                "Order cannot be cancelled in status: " + order.getStatus());
        }

        // Release reserved stock
        releaseStock(order.getOrderItems(), userId);

        order.cancel();
        if (reason != null) {
            order.setInternalNotes((order.getInternalNotes() != null ? order.getInternalNotes() + "\n" : "") 
                                  + "Cancelled: " + reason);
        }

        Order savedOrder = orderRepository.save(order);
        return convertToDto(savedOrder, true);
    }

    /**
     * Delete order (only if PENDING or CANCELLED)
     */
    public void deleteOrder(Long orderId, Long userId) {
        Order order = orderRepository.findByUserIdAndId(userId, orderId)
                .orElseThrow(() -> new OrderNotFoundException(orderId));

        if (order.getStatus() != OrderStatus.PENDING && order.getStatus() != OrderStatus.CANCELLED) {
            throw new InvalidOrderStateException(
                "Only pending or cancelled orders can be deleted");
        }

        // Release stock if order was pending
        if (order.getStatus() == OrderStatus.PENDING) {
            releaseStock(order.getOrderItems(), userId);
        }

        orderRepository.delete(order);
    }

    // Reporting and analytics methods

    /**
     * Get order statistics
     */
    @Transactional(readOnly = true)
    public OrderStatsDto getOrderStatistics(Long userId) {
        long totalOrders = orderRepository.countByUserId(userId);
        long pendingOrders = orderRepository.countByUserIdAndStatus(userId, OrderStatus.PENDING);
        long confirmedOrders = orderRepository.countByUserIdAndStatus(userId, OrderStatus.CONFIRMED);
        long shippedOrders = orderRepository.countByUserIdAndStatus(userId, OrderStatus.SHIPPED);
        long deliveredOrders = orderRepository.countByUserIdAndStatus(userId, OrderStatus.DELIVERED);
        long cancelledOrders = orderRepository.countByUserIdAndStatus(userId, OrderStatus.CANCELLED);
        
        BigDecimal totalRevenue = orderRepository.sumTotalRevenueByUserId(userId);
        BigDecimal averageOrderValue = orderRepository.getAverageOrderValueByUserId(userId);

        return new OrderStatsDto(totalOrders, pendingOrders, confirmedOrders, shippedOrders,
                               deliveredOrders, cancelledOrders, totalRevenue, averageOrderValue);
    }

    /**
     * Get daily sales report
     */
    @Transactional(readOnly = true)
    public List<DailySalesDto> getDailySalesReport(Long userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Object[]> results = orderRepository.getDailySalesReport(userId, startDate, endDate);
        
        return results.stream()
                .map(row -> new DailySalesDto(
                    (String) row[0],  // sale_date
                    (Long) row[1],    // order_count
                    (BigDecimal) row[2], // total_revenue
                    (BigDecimal) row[3]  // avg_order_value
                ))
                .collect(Collectors.toList());
    }

    // Private helper methods

    private String generateOrderNumber() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int randomPart = new Random().nextInt(9999) + 1;
        return String.format("ORD-%s-%04d", dateStr, randomPart);
    }

    private void validateCustomerExists(Long customerId, Long userId) {
        try {
            // Call customer service to validate customer exists and belongs to user
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-ID", userId.toString());
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            
            ResponseEntity<Object> response = restTemplate.exchange(
                "http://customer-service:8081/api/v1/customers/" + customerId,
                HttpMethod.GET,
                entity,
                Object.class
            );
            
            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new IllegalArgumentException("Customer not found: " + customerId);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to validate customer: " + customerId, e);
        }
    }

    private void validateProductsAndStock(List<OrderItemCreateRequest> orderItems, Long userId) {
        for (OrderItemCreateRequest item : orderItems) {
            try {
                // Call product service to validate product and check stock
                HttpHeaders headers = new HttpHeaders();
                headers.set("User-ID", userId.toString());
                HttpEntity<Void> entity = new HttpEntity<>(headers);
                
                ResponseEntity<Object> response = restTemplate.exchange(
                    "http://product-service:8083/api/v1/products/" + item.getProductId(),
                    HttpMethod.GET,
                    entity,
                    Object.class
                );
                
                if (!response.getStatusCode().is2xxSuccessful()) {
                    throw new IllegalArgumentException("Product not found: " + item.getProductId());
                }
                
                // Here you would parse the response and check stock levels
                // For now, we'll assume the product service validates stock
                
            } catch (Exception e) {
                throw new IllegalArgumentException("Failed to validate product: " + item.getProductId(), e);
            }
        }
    }

    private void reserveStock(List<OrderItem> orderItems, Long userId) {
        // Call product service to reserve stock for each item
        for (OrderItem item : orderItems) {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.set("User-ID", userId.toString());
                headers.set("Content-Type", "application/json");
                
                String requestBody = String.format("{\"quantity\": %d, \"operation\": \"reserve\"}", 
                                                 item.getQuantity());
                HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);
                
                restTemplate.exchange(
                    "http://product-service:8083/api/v1/products/" + item.getProductId() + "/stock",
                    HttpMethod.PUT,
                    entity,
                    Object.class
                );
            } catch (Exception e) {
                // Log error but don't fail order creation
                System.err.println("Failed to reserve stock for product " + item.getProductId() + ": " + e.getMessage());
            }
        }
    }

    private void releaseStock(List<OrderItem> orderItems, Long userId) {
        // Call product service to release reserved stock
        for (OrderItem item : orderItems) {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.set("User-ID", userId.toString());
                headers.set("Content-Type", "application/json");
                
                String requestBody = String.format("{\"quantity\": %d, \"operation\": \"release\"}", 
                                                 item.getQuantity());
                HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);
                
                restTemplate.exchange(
                    "http://product-service:8083/api/v1/products/" + item.getProductId() + "/stock",
                    HttpMethod.PUT,
                    entity,
                    Object.class
                );
            } catch (Exception e) {
                // Log error but don't fail operation
                System.err.println("Failed to release stock for product " + item.getProductId() + ": " + e.getMessage());
            }
        }
    }

    private OrderDto convertToDto(Order order, boolean includeItems) {
        OrderDto dto = new OrderDto(
            order.getId(),
            order.getOrderNumber(),
            order.getCustomerId(),
            null, // Customer name will be fetched separately if needed
            null, // Customer email will be fetched separately if needed
            order.getStatus(),
            order.getPaymentStatus(),
            order.getSubtotalNet(),
            order.getTotalVat(),
            order.getTotalGross(),
            order.getShippingCost(),
            order.getDiscountAmount(),
            order.getNotes(),
            order.getInternalNotes(),
            order.getShippingAddress(),
            order.getBillingAddress(),
            order.getCreatedAt(),
            order.getUpdatedAt(),
            order.getConfirmedAt(),
            order.getShippedAt(),
            order.getDeliveredAt()
        );

        if (includeItems) {
            List<OrderItemDto> itemDtos = order.getOrderItems().stream()
                .map(this::convertItemToDto)
                .collect(Collectors.toList());
            dto.setOrderItems(itemDtos);
            dto.setTotalItemCount(itemDtos.size());
            dto.setTotalQuantity(order.getTotalItemCount());
        }

        return dto;
    }

    private OrderItemDto convertItemToDto(OrderItem item) {
        return new OrderItemDto(
            item.getId(),
            item.getProductId(),
            item.getProductName(),
            item.getProductSku(),
            item.getQuantity(),
            item.getUnitPriceNet(),
            item.getVatRate(),
            item.getLineVat(),
            item.getLineTotalGross(),
            item.getNotes(),
            item.getCreatedAt()
        );
    }

    // Inner DTOs for reporting
    public static class OrderStatsDto {
        private final long totalOrders;
        private final long pendingOrders;
        private final long confirmedOrders;
        private final long shippedOrders;
        private final long deliveredOrders;
        private final long cancelledOrders;
        private final BigDecimal totalRevenue;
        private final BigDecimal averageOrderValue;

        public OrderStatsDto(long totalOrders, long pendingOrders, long confirmedOrders, 
                           long shippedOrders, long deliveredOrders, long cancelledOrders,
                           BigDecimal totalRevenue, BigDecimal averageOrderValue) {
            this.totalOrders = totalOrders;
            this.pendingOrders = pendingOrders;
            this.confirmedOrders = confirmedOrders;
            this.shippedOrders = shippedOrders;
            this.deliveredOrders = deliveredOrders;
            this.cancelledOrders = cancelledOrders;
            this.totalRevenue = totalRevenue;
            this.averageOrderValue = averageOrderValue;
        }

        // Getters
        public long getTotalOrders() { return totalOrders; }
        public long getPendingOrders() { return pendingOrders; }
        public long getConfirmedOrders() { return confirmedOrders; }
        public long getShippedOrders() { return shippedOrders; }
        public long getDeliveredOrders() { return deliveredOrders; }
        public long getCancelledOrders() { return cancelledOrders; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public BigDecimal getAverageOrderValue() { return averageOrderValue; }
    }

    public static class DailySalesDto {
        private final String saleDate;
        private final Long orderCount;
        private final BigDecimal totalRevenue;
        private final BigDecimal averageOrderValue;

        public DailySalesDto(String saleDate, Long orderCount, BigDecimal totalRevenue, BigDecimal averageOrderValue) {
            this.saleDate = saleDate;
            this.orderCount = orderCount;
            this.totalRevenue = totalRevenue;
            this.averageOrderValue = averageOrderValue;
        }

        // Getters
        public String getSaleDate() { return saleDate; }
        public Long getOrderCount() { return orderCount; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public BigDecimal getAverageOrderValue() { return averageOrderValue; }
    }
}