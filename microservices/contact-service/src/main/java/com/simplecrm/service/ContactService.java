package com.simplecrm.service;

import com.simplecrm.dto.ContactCreateRequest;
import com.simplecrm.dto.ContactDto;
import com.simplecrm.dto.ContactUpdateRequest;
import com.simplecrm.entity.Contact;
import com.simplecrm.entity.ContactStatus;
import com.simplecrm.entity.ContactType;
import com.simplecrm.exception.ContactNotFoundException;
import com.simplecrm.exception.DuplicateEmailException;
import com.simplecrm.repository.ContactRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ContactService {

    private static final Logger logger = LoggerFactory.getLogger(ContactService.class);

    @Autowired
    private ContactRepository contactRepository;

    public Page<ContactDto> getAllContacts(Long userId, Pageable pageable) {
        logger.info("Fetching all contacts for user {} with pagination", userId);
        return contactRepository.findByUserId(userId, pageable)
                .map(this::convertToDto);
    }

    public ContactDto getContactById(Long id, Long userId) {
        logger.info("Fetching contact by id: {} for user: {}", id, userId);
        Contact contact = contactRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with id: " + id));
        return convertToDto(contact);
    }

    public ContactDto getContactByEmail(String email, Long userId) {
        logger.info("Fetching contact by email: {} for user: {}", email, userId);
        Contact contact = contactRepository.findByEmailAndUserId(email, userId)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with email: " + email));
        return convertToDto(contact);
    }

    public List<ContactDto> getContactsByCustomerId(Long customerId, Long userId) {
        logger.info("Fetching contacts for customer id: {} and user: {}", customerId, userId);
        return contactRepository.findByCustomerIdAndUserId(customerId, userId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public Page<ContactDto> getContactsByStatus(ContactStatus status, Long userId, Pageable pageable) {
        logger.info("Fetching contacts by status: {} for user: {}", status, userId);
        return contactRepository.findByStatusAndUserId(status, userId, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> getContactsByType(ContactType contactType, Long userId, Pageable pageable) {
        logger.info("Fetching contacts by type: {} for user: {}", contactType, userId);
        return contactRepository.findByContactTypeAndUserId(contactType, userId, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> getContactsByCompany(String company, Long userId, Pageable pageable) {
        logger.info("Fetching contacts by company: {} for user: {}", company, userId);
        return contactRepository.findByCompanyAndUserId(company, userId, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> searchContacts(String keyword, Long userId, Pageable pageable) {
        logger.info("Searching contacts with keyword: {} for user: {}", keyword, userId);
        return contactRepository.searchContactsByUserId(keyword, userId, pageable)
                .map(this::convertToDto);
    }

    public ContactDto createContact(ContactCreateRequest request, Long userId) {
        logger.info("Creating new contact with email: {} for user: {}", request.getEmail(), userId);
        
        // Check for duplicate email for this user
        if (request.getEmail() != null && contactRepository.existsByEmailAndUserId(request.getEmail(), userId)) {
            throw new DuplicateEmailException("Contact already exists with email: " + request.getEmail());
        }

        Contact contact = convertToEntity(request);
        contact.setUserId(userId);
        
        // Set default values
        if (contact.getContactType() == null) {
            contact.setContactType(ContactType.LEAD);
        }
        if (contact.getStatus() == null) {
            contact.setStatus(ContactStatus.ACTIVE);
        }

        Contact savedContact = contactRepository.save(contact);
        logger.info("Contact created successfully with id: {} for user: {}", savedContact.getId(), userId);
        
        return convertToDto(savedContact);
    }

    public ContactDto updateContact(Long id, ContactUpdateRequest request, Long userId) {
        logger.info("Updating contact with id: {} for user: {}", id, userId);
        
        Contact existingContact = contactRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with id: " + id));

        // Check for duplicate email if email is being updated
        if (request.getEmail() != null && 
            !request.getEmail().equals(existingContact.getEmail()) &&
            contactRepository.existsByEmailAndUserId(request.getEmail(), userId)) {
            throw new DuplicateEmailException("Contact already exists with email: " + request.getEmail());
        }

        updateContactFromRequest(existingContact, request);
        Contact updatedContact = contactRepository.save(existingContact);
        
        logger.info("Contact updated successfully with id: {} for user: {}", updatedContact.getId(), userId);
        return convertToDto(updatedContact);
    }

    public void deleteContact(Long id, Long userId) {
        logger.info("Deleting contact with id: {} for user: {}", id, userId);
        
        Contact contact = contactRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with id: " + id));
        
        contactRepository.delete(contact);
        logger.info("Contact deleted successfully with id: {} for user: {}", id, userId);
    }

    public long getContactCountByType(ContactType contactType, Long userId) {
        return contactRepository.countByContactTypeAndUserId(contactType, userId);
    }

    public long getContactCountByStatus(ContactStatus status, Long userId) {
        return contactRepository.countByStatusAndUserId(status, userId);
    }

    public List<ContactDto> getRecentContacts(Long userId) {
        logger.info("Fetching recent contacts for user: {}", userId);
        return contactRepository.findTop10ByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private ContactDto convertToDto(Contact contact) {
        ContactDto dto = new ContactDto();
        dto.setId(contact.getId());
        dto.setFirstName(contact.getFirstName());
        dto.setLastName(contact.getLastName());
        dto.setEmail(contact.getEmail());
        dto.setPhone(contact.getPhone());
        dto.setMobile(contact.getMobile());
        dto.setJobTitle(contact.getJobTitle());
        dto.setDepartment(contact.getDepartment());
        dto.setCompany(contact.getCompany());
        dto.setContactType(contact.getContactType());
        dto.setStatus(contact.getStatus());
        dto.setCustomerId(contact.getCustomerId());
        dto.setUserId(contact.getUserId());
        dto.setNotes(contact.getNotes());
        dto.setAddressLine1(contact.getAddressLine1());
        dto.setAddressLine2(contact.getAddressLine2());
        dto.setCity(contact.getCity());
        dto.setState(contact.getState());
        dto.setPostalCode(contact.getPostalCode());
        dto.setCountry(contact.getCountry());
        dto.setCreatedAt(contact.getCreatedAt());
        dto.setUpdatedAt(contact.getUpdatedAt());
        return dto;
    }

    private Contact convertToEntity(ContactCreateRequest request) {
        Contact contact = new Contact();
        contact.setFirstName(request.getFirstName());
        contact.setLastName(request.getLastName());
        contact.setEmail(request.getEmail());
        contact.setPhone(request.getPhone());
        contact.setMobile(request.getMobile());
        contact.setJobTitle(request.getJobTitle());
        contact.setDepartment(request.getDepartment());
        contact.setCompany(request.getCompany());
        contact.setContactType(request.getContactType());
        contact.setStatus(request.getStatus());
        contact.setCustomerId(request.getCustomerId());
        contact.setNotes(request.getNotes());
        contact.setAddressLine1(request.getAddressLine1());
        contact.setAddressLine2(request.getAddressLine2());
        contact.setCity(request.getCity());
        contact.setState(request.getState());
        contact.setPostalCode(request.getPostalCode());
        contact.setCountry(request.getCountry());
        return contact;
    }

    private void updateContactFromRequest(Contact contact, ContactUpdateRequest request) {
        if (request.getFirstName() != null) {
            contact.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            contact.setLastName(request.getLastName());
        }
        if (request.getEmail() != null) {
            contact.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            contact.setPhone(request.getPhone());
        }
        if (request.getMobile() != null) {
            contact.setMobile(request.getMobile());
        }
        if (request.getJobTitle() != null) {
            contact.setJobTitle(request.getJobTitle());
        }
        if (request.getDepartment() != null) {
            contact.setDepartment(request.getDepartment());
        }
        if (request.getCompany() != null) {
            contact.setCompany(request.getCompany());
        }
        if (request.getContactType() != null) {
            contact.setContactType(request.getContactType());
        }
        if (request.getStatus() != null) {
            contact.setStatus(request.getStatus());
        }
        if (request.getCustomerId() != null) {
            contact.setCustomerId(request.getCustomerId());
        }
        if (request.getNotes() != null) {
            contact.setNotes(request.getNotes());
        }
        if (request.getAddressLine1() != null) {
            contact.setAddressLine1(request.getAddressLine1());
        }
        if (request.getAddressLine2() != null) {
            contact.setAddressLine2(request.getAddressLine2());
        }
        if (request.getCity() != null) {
            contact.setCity(request.getCity());
        }
        if (request.getState() != null) {
            contact.setState(request.getState());
        }
        if (request.getPostalCode() != null) {
            contact.setPostalCode(request.getPostalCode());
        }
        if (request.getCountry() != null) {
            contact.setCountry(request.getCountry());
        }
    }
}