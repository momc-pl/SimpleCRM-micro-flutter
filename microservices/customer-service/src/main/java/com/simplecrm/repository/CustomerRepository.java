package com.simplecrm.repository;

import com.simplecrm.entity.Customer;
import com.simplecrm.entity.CustomerStatus;
import com.simplecrm.entity.CustomerType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Optional<Customer> findByEmail(String email);

    List<Customer> findByUserId(Long userId);

    List<Customer> findByStatus(CustomerStatus status);

    List<Customer> findByCustomerType(CustomerType customerType);

    Page<Customer> findByUserId(Long userId, Pageable pageable);

    Page<Customer> findByStatus(CustomerStatus status, Pageable pageable);

    @Query("SELECT c FROM Customer c WHERE c.userId = :userId AND c.status = :status")
    Page<Customer> findByUserIdAndStatus(@Param("userId") Long userId, 
                                       @Param("status") CustomerStatus status, 
                                       Pageable pageable);

    @Query("SELECT c FROM Customer c WHERE c.userId = :userId AND " +
           "(LOWER(c.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(c.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(c.company) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Customer> findByUserIdAndSearchTerm(@Param("userId") Long userId, 
                                           @Param("search") String search, 
                                           Pageable pageable);

    @Query("SELECT COUNT(c) FROM Customer c WHERE c.userId = :userId")
    Long countByUserId(@Param("userId") Long userId);

    @Query("SELECT COUNT(c) FROM Customer c WHERE c.userId = :userId AND c.status = :status")
    Long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") CustomerStatus status);

    boolean existsByEmail(String email);

    boolean existsByEmailAndIdNot(String email, Long id);
}