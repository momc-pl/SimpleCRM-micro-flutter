package com.simplecrm.repository;

import com.simplecrm.entity.SalesActivity;
import com.simplecrm.entity.ActivityType;
import com.simplecrm.entity.ActivityStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SalesActivityRepository extends JpaRepository<SalesActivity, Long> {
    
    List<SalesActivity> findByLeadId(Long leadId);
    
    List<SalesActivity> findByOpportunityId(Long opportunityId);
    
    List<SalesActivity> findByCustomerId(Long customerId);
    
    List<SalesActivity> findByAssignedTo(Long assignedTo);
    
    List<SalesActivity> findByType(ActivityType type);
    
    List<SalesActivity> findByStatus(ActivityStatus status);
    
    @Query("SELECT a FROM SalesActivity a WHERE a.activityDate BETWEEN :startDate AND :endDate")
    List<SalesActivity> findActivitiesInDateRange(@Param("startDate") LocalDateTime startDate, 
                                                  @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM SalesActivity a WHERE a.assignedTo = :assignedTo AND a.activityDate BETWEEN :startDate AND :endDate")
    List<SalesActivity> findUserActivitiesInDateRange(@Param("assignedTo") Long assignedTo,
                                                      @Param("startDate") LocalDateTime startDate, 
                                                      @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM SalesActivity a WHERE a.status = 'PLANNED' AND a.activityDate < :currentDate")
    List<SalesActivity> findOverdueActivities(@Param("currentDate") LocalDateTime currentDate);
    
    @Query("SELECT COUNT(a) FROM SalesActivity a WHERE a.type = :type AND a.status = 'COMPLETED'")
    Long countCompletedActivitiesByType(@Param("type") ActivityType type);
    
    Page<SalesActivity> findByAssignedToOrderByActivityDateDesc(Long assignedTo, Pageable pageable);
}