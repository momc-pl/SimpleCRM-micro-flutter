package com.simplecrm.repository;

import com.simplecrm.entity.Opportunity;
import com.simplecrm.entity.SalesStage;
import com.simplecrm.entity.OpportunityPriority;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OpportunityRepository extends JpaRepository<Opportunity, Long> {
    
    List<Opportunity> findByStage(SalesStage stage);
    
    List<Opportunity> findByCustomerId(Long customerId);
    
    List<Opportunity> findByAssignedTo(Long assignedTo);
    
    List<Opportunity> findByPriority(OpportunityPriority priority);
    
    Page<Opportunity> findByStageAndAssignedTo(SalesStage stage, Long assignedTo, Pageable pageable);
    
    @Query("SELECT o FROM Opportunity o WHERE o.expectedCloseDate BETWEEN :startDate AND :endDate")
    List<Opportunity> findOpportunitiesClosingInDateRange(@Param("startDate") LocalDateTime startDate, 
                                                          @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT o FROM Opportunity o WHERE o.stage = :stage AND o.expectedCloseDate < :currentDate")
    List<Opportunity> findOverdueOpportunities(@Param("stage") SalesStage stage, 
                                               @Param("currentDate") LocalDateTime currentDate);
    
    @Query("SELECT SUM(o.value) FROM Opportunity o WHERE o.stage = :stage")
    BigDecimal getTotalValueByStage(@Param("stage") SalesStage stage);
    
    @Query("SELECT COUNT(o) FROM Opportunity o WHERE o.stage = :stage")
    Long countByStage(@Param("stage") SalesStage stage);
    
    @Query("SELECT SUM(o.value * o.probability / 100.0) FROM Opportunity o WHERE o.stage NOT IN ('WON', 'LOST')")
    BigDecimal getWeightedPipelineValue();
    
    @Query("SELECT AVG(o.value) FROM Opportunity o WHERE o.stage = 'WON'")
    Double getAverageDealSize();
    
    @Query("SELECT COUNT(o) * 100.0 / (SELECT COUNT(o2) FROM Opportunity o2) FROM Opportunity o WHERE o.stage = 'WON'")
    Double getWinRate();
    
    @Query("SELECT o FROM Opportunity o WHERE " +
           "(:name IS NULL OR LOWER(o.name) LIKE LOWER(CONCAT('%', :name, '%'))) AND " +
           "(:stage IS NULL OR o.stage = :stage) AND " +
           "(:assignedTo IS NULL OR o.assignedTo = :assignedTo) AND " +
           "(:minValue IS NULL OR o.value >= :minValue) AND " +
           "(:maxValue IS NULL OR o.value <= :maxValue)")
    Page<Opportunity> searchOpportunities(@Param("name") String name,
                                         @Param("stage") SalesStage stage,
                                         @Param("assignedTo") Long assignedTo,
                                         @Param("minValue") BigDecimal minValue,
                                         @Param("maxValue") BigDecimal maxValue,
                                         Pageable pageable);
}