package com.simplecrm.exception;

public class OpportunityNotFoundException extends RuntimeException {
    public OpportunityNotFoundException(String message) {
        super(message);
    }
}