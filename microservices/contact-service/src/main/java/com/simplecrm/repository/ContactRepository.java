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

    Optional<Contact> findByEmail(String email);

    List<Contact> findByCustomerId(Long customerId);

    Page<Contact> findByStatus(ContactStatus status, Pageable pageable);

    Page<Contact> findByContactType(ContactType contactType, Pageable pageable);

    Page<Contact> findByCompany(String company, Pageable pageable);

    @Query("SELECT c FROM Contact c WHERE " +
           "LOWER(c.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.company) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Contact> searchContacts(@Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT c FROM Contact c WHERE c.customerId = :customerId AND c.status = :status")
    List<Contact> findByCustomerIdAndStatus(@Param("customerId") Long customerId, 
                                           @Param("status") ContactStatus status);

    @Query("SELECT COUNT(c) FROM Contact c WHERE c.contactType = :contactType")
    long countByContactType(@Param("contactType") ContactType contactType);

    @Query("SELECT COUNT(c) FROM Contact c WHERE c.status = :status")
    long countByStatus(@Param("status") ContactStatus status);

    boolean existsByEmail(String email);

    List<Contact> findTop10ByOrderByCreatedAtDesc();
}