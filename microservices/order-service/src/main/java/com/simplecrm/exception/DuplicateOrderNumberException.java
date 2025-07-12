package com.simplecrm.exception;

public class DuplicateOrderNumberException extends RuntimeException {
    
    public DuplicateOrderNumberException(String message) {
        super(message);
    }
    
    public DuplicateOrderNumberException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public DuplicateOrderNumberException(String orderNumber) {
        super("Order with number " + orderNumber + " already exists");
    }
}