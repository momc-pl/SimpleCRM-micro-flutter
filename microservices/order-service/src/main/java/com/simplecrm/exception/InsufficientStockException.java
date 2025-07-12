package com.simplecrm.exception;

public class InsufficientStockException extends RuntimeException {
    
    public InsufficientStockException(String message) {
        super(message);
    }
    
    public InsufficientStockException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public InsufficientStockException(String productSku, Integer requestedQuantity, Integer availableQuantity) {
        super(String.format("Insufficient stock for product %s. Requested: %d, Available: %d", 
              productSku, requestedQuantity, availableQuantity));
    }
}