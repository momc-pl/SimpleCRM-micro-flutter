package com.simplecrm.repository;

import com.simplecrm.entity.Contact;
import com.simplecrm.entity.ContactStatus;
import com.simplecrm.entity.ContactType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ContactRepository extends JpaRepository<Contact, Long> {

    // User-specific queries
    Page<Contact> findByUserId(Long userId, Pageable pageable);

    Optional<Contact> findByIdAndUserId(Long id, Long userId);

    Optional<Contact> findByEmailAndUserId(String email, Long userId);

    List<Contact> findByCustomerIdAndUserId(Long customerId, Long userId);

    Page<Contact> findByStatusAndUserId(ContactStatus status, Long userId, Pageable pageable);

    Page<Contact> findByContactTypeAndUserId(ContactType contactType, Long userId, Pageable pageable);

    Page<Contact> findByCompanyAndUserId(String company, Long userId, Pageable pageable);

    @Query("SELECT c FROM Contact c WHERE c.userId = :userId AND (" +
           "LOWER(c.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.company) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Contact> searchContactsByUserId(@Param("keyword") String keyword, @Param("userId") Long userId, Pageable pageable);

    @Query("SELECT c FROM Contact c WHERE c.customerId = :customerId AND c.status = :status AND c.userId = :userId")
    List<Contact> findByCustomerIdAndStatusAndUserId(@Param("customerId") Long customerId, 
                                                    @Param("status") ContactStatus status,
                                                    @Param("userId") Long userId);

    @Query("SELECT COUNT(c) FROM Contact c WHERE c.contactType = :contactType AND c.userId = :userId")
    long countByContactTypeAndUserId(@Param("contactType") ContactType contactType, @Param("userId") Long userId);

    @Query("SELECT COUNT(c) FROM Contact c WHERE c.status = :status AND c.userId = :userId")
    long countByStatusAndUserId(@Param("status") ContactStatus status, @Param("userId") Long userId);

    boolean existsByEmailAndUserId(String email, Long userId);

    List<Contact> findTop10ByUserIdOrderByCreatedAtDesc(Long userId);

    // Original non-user-specific methods (for backward compatibility during migration)
    Optional<Contact> findByEmail(String email);
    boolean existsByEmail(String email);
    
    @Query("SELECT c FROM Contact c WHERE " +
           "LOWER(c.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.company) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Contact> searchContacts(@Param("keyword") String keyword, Pageable pageable);
}