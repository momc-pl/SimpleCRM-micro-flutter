package com.simplecrm.entity;

public enum CustomerType {
    INDIVIDUAL("Individual"),
    BUSINESS("Business"),
    ENTERPRISE("Enterprise");

    private final String displayName;

    CustomerType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }
}