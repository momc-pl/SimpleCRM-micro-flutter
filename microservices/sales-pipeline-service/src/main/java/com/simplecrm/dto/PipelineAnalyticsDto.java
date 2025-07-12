package com.simplecrm.dto;

import java.math.BigDecimal;
import java.util.Map;

public class PipelineAnalyticsDto {
    private Long totalOpportunities;
    private BigDecimal totalValue;
    private BigDecimal weightedValue;
    private Double averageDealSize;
    private Double winRate;
    private Double averageSalesCycle;
    private Map<String, Long> opportunitiesByStage;
    private Map<String, BigDecimal> valueByStage;
    private Map<String, Double> conversionRates;

    // Constructors
    public PipelineAnalyticsDto() {}

    // Getters and Setters
    public Long getTotalOpportunities() { return totalOpportunities; }
    public void setTotalOpportunities(Long totalOpportunities) { this.totalOpportunities = totalOpportunities; }

    public BigDecimal getTotalValue() { return totalValue; }
    public void setTotalValue(BigDecimal totalValue) { this.totalValue = totalValue; }

    public BigDecimal getWeightedValue() { return weightedValue; }
    public void setWeightedValue(BigDecimal weightedValue) { this.weightedValue = weightedValue; }

    public Double getAverageDealSize() { return averageDealSize; }
    public void setAverageDealSize(Double averageDealSize) { this.averageDealSize = averageDealSize; }

    public Double getWinRate() { return winRate; }
    public void setWinRate(Double winRate) { this.winRate = winRate; }

    public Double getAverageSalesCycle() { return averageSalesCycle; }
    public void setAverageSalesCycle(Double averageSalesCycle) { this.averageSalesCycle = averageSalesCycle; }

    public Map<String, Long> getOpportunitiesByStage() { return opportunitiesByStage; }
    public void setOpportunitiesByStage(Map<String, Long> opportunitiesByStage) { this.opportunitiesByStage = opportunitiesByStage; }

    public Map<String, BigDecimal> getValueByStage() { return valueByStage; }
    public void setValueByStage(Map<String, BigDecimal> valueByStage) { this.valueByStage = valueByStage; }

    public Map<String, Double> getConversionRates() { return conversionRates; }
    public void setConversionRates(Map<String, Double> conversionRates) { this.conversionRates = conversionRates; }
}