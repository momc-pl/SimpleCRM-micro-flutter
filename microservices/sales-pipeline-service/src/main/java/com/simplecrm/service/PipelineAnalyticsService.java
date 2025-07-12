package com.simplecrm.service;

import com.simplecrm.dto.PipelineAnalyticsDto;
import com.simplecrm.entity.SalesStage;
import com.simplecrm.repository.OpportunityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Service
@Transactional(readOnly = true)
public class PipelineAnalyticsService {

    private final OpportunityRepository opportunityRepository;

    @Autowired
    public PipelineAnalyticsService(OpportunityRepository opportunityRepository) {
        this.opportunityRepository = opportunityRepository;
    }

    public PipelineAnalyticsDto getPipelineAnalytics() {
        PipelineAnalyticsDto analytics = new PipelineAnalyticsDto();
        
        // Total opportunities count
        analytics.setTotalOpportunities(opportunityRepository.count());
        
        // Total pipeline value
        BigDecimal totalValue = calculateTotalPipelineValue();
        analytics.setTotalValue(totalValue);
        
        // Weighted pipeline value
        BigDecimal weightedValue = opportunityRepository.getWeightedPipelineValue();
        analytics.setWeightedValue(weightedValue != null ? weightedValue : BigDecimal.ZERO);
        
        // Average deal size
        Double averageDealSize = opportunityRepository.getAverageDealSize();
        analytics.setAverageDealSize(averageDealSize != null ? averageDealSize : 0.0);
        
        // Win rate
        Double winRate = opportunityRepository.getWinRate();
        analytics.setWinRate(winRate != null ? winRate : 0.0);
        
        // Average sales cycle (simplified calculation)
        analytics.setAverageSalesCycle(calculateAverageSalesCycle());
        
        // Opportunities by stage
        analytics.setOpportunitiesByStage(getOpportunitiesCountByStage());
        
        // Value by stage
        analytics.setValueByStage(getValueByStage());
        
        // Conversion rates
        analytics.setConversionRates(calculateConversionRates());
        
        return analytics;
    }

    private BigDecimal calculateTotalPipelineValue() {
        BigDecimal total = BigDecimal.ZERO;
        for (SalesStage stage : SalesStage.values()) {
            if (stage != SalesStage.LOST) { // Exclude lost opportunities
                BigDecimal stageValue = opportunityRepository.getTotalValueByStage(stage);
                if (stageValue != null) {
                    total = total.add(stageValue);
                }
            }
        }
        return total;
    }

    private Map<String, Long> getOpportunitiesCountByStage() {
        Map<String, Long> counts = new HashMap<>();
        for (SalesStage stage : SalesStage.values()) {
            Long count = opportunityRepository.countByStage(stage);
            counts.put(stage.name(), count != null ? count : 0L);
        }
        return counts;
    }

    private Map<String, BigDecimal> getValueByStage() {
        Map<String, BigDecimal> values = new HashMap<>();
        for (SalesStage stage : SalesStage.values()) {
            BigDecimal value = opportunityRepository.getTotalValueByStage(stage);
            values.put(stage.name(), value != null ? value : BigDecimal.ZERO);
        }
        return values;
    }

    private Map<String, Double> calculateConversionRates() {
        Map<String, Double> conversionRates = new HashMap<>();
        
        // Get counts for each stage
        Map<String, Long> stageCounts = getOpportunitiesCountByStage();
        
        // Calculate conversion rates between consecutive stages
        SalesStage[] stages = SalesStage.values();
        for (int i = 0; i < stages.length - 1; i++) {
            SalesStage currentStage = stages[i];
            SalesStage nextStage = stages[i + 1];
            
            Long currentCount = stageCounts.get(currentStage.name());
            Long nextCount = stageCounts.get(nextStage.name());
            
            if (currentCount != null && currentCount > 0) {
                double rate = (nextCount != null ? nextCount.doubleValue() : 0.0) / currentCount.doubleValue() * 100.0;
                conversionRates.put(currentStage.name() + "_to_" + nextStage.name(), rate);
            }
        }
        
        return conversionRates;
    }

    private Double calculateAverageSalesCycle() {
        // Simplified calculation - in a real implementation, this would calculate
        // the average time from opportunity creation to close
        // For now, return a placeholder value
        return 30.0; // 30 days average
    }

    public Map<String, Object> getSalesPerformanceMetrics(Long assignedTo) {
        Map<String, Object> metrics = new HashMap<>();
        
        // This would contain user-specific metrics
        // For now, return basic structure
        metrics.put("totalOpportunities", 0L);
        metrics.put("totalValue", BigDecimal.ZERO);
        metrics.put("winRate", 0.0);
        metrics.put("averageDealSize", 0.0);
        
        return metrics;
    }
}