package com.simplecrm.repository;

import com.simplecrm.entity.Lead;
import com.simplecrm.entity.LeadStatus;
import com.simplecrm.entity.LeadSource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface LeadRepository extends JpaRepository<Lead, Long> {
    
    Optional<Lead> findByEmail(String email);
    
    List<Lead> findByStatus(LeadStatus status);
    
    List<Lead> findBySource(LeadSource source);
    
    List<Lead> findByAssignedTo(Long assignedTo);
    
    Page<Lead> findByStatusAndAssignedTo(LeadStatus status, Long assignedTo, Pageable pageable);
    
    @Query("SELECT l FROM Lead l WHERE l.nextFollowUpDate BETWEEN :startDate AND :endDate")
    List<Lead> findLeadsRequiringFollowUp(@Param("startDate") LocalDateTime startDate, 
                                          @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT l FROM Lead l WHERE l.qualificationScore >= :minScore")
    List<Lead> findQualifiedLeads(@Param("minScore") Integer minScore);
    
    @Query("SELECT COUNT(l) FROM Lead l WHERE l.status = :status")
    Long countByStatus(@Param("status") LeadStatus status);
    
    @Query("SELECT COUNT(l) FROM Lead l WHERE l.createdAt BETWEEN :startDate AND :endDate")
    Long countLeadsCreatedInDateRange(@Param("startDate") LocalDateTime startDate, 
                                      @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT l FROM Lead l WHERE " +
           "(:name IS NULL OR LOWER(CONCAT(l.firstName, ' ', l.lastName)) LIKE LOWER(CONCAT('%', :name, '%'))) AND " +
           "(:email IS NULL OR LOWER(l.email) LIKE LOWER(CONCAT('%', :email, '%'))) AND " +
           "(:company IS NULL OR LOWER(l.company) LIKE LOWER(CONCAT('%', :company, '%'))) AND " +
           "(:status IS NULL OR l.status = :status) AND " +
           "(:assignedTo IS NULL OR l.assignedTo = :assignedTo)")
    Page<Lead> searchLeads(@Param("name") String name,
                          @Param("email") String email,
                          @Param("company") String company,
                          @Param("status") LeadStatus status,
                          @Param("assignedTo") Long assignedTo,
                          Pageable pageable);
}