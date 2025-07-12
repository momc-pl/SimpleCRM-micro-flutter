package com.simplecrm.exception;

public class OrderNotFoundException extends RuntimeException {
    
    public OrderNotFoundException(String message) {
        super(message);
    }
    
    public OrderNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public OrderNotFoundException(Long orderId) {
        super("Order not found with id: " + orderId);
    }
    
    public OrderNotFoundException(String orderNumber, String field) {
        super("Order not found with " + field + ": " + orderNumber);
    }
}