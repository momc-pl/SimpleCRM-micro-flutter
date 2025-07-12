package com.simplecrm.repository;

import com.simplecrm.entity.Pipeline;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PipelineRepository extends JpaRepository<Pipeline, Long> {
    
    List<Pipeline> findByIsActiveTrue();
    
    Optional<Pipeline> findByIsDefaultTrue();
    
    Optional<Pipeline> findByNameIgnoreCase(String name);
    
    @Query("SELECT p FROM Pipeline p WHERE p.isActive = true ORDER BY p.isDefault DESC, p.name ASC")
    List<Pipeline> findActivePipelinesOrderByDefault();
}