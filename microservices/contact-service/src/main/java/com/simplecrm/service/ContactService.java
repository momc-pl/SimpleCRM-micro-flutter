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

    public Page<ContactDto> getAllContacts(Pageable pageable) {
        logger.info("Fetching all contacts with pagination");
        return contactRepository.findAll(pageable)
                .map(this::convertToDto);
    }

    public ContactDto getContactById(Long id) {
        logger.info("Fetching contact by id: {}", id);
        Contact contact = contactRepository.findById(id)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with id: " + id));
        return convertToDto(contact);
    }

    public ContactDto getContactByEmail(String email) {
        logger.info("Fetching contact by email: {}", email);
        Contact contact = contactRepository.findByEmail(email)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with email: " + email));
        return convertToDto(contact);
    }

    public List<ContactDto> getContactsByCustomerId(Long customerId) {
        logger.info("Fetching contacts for customer id: {}", customerId);
        return contactRepository.findByCustomerId(customerId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public Page<ContactDto> getContactsByStatus(ContactStatus status, Pageable pageable) {
        logger.info("Fetching contacts by status: {}", status);
        return contactRepository.findByStatus(status, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> getContactsByType(ContactType contactType, Pageable pageable) {
        logger.info("Fetching contacts by type: {}", contactType);
        return contactRepository.findByContactType(contactType, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> getContactsByCompany(String company, Pageable pageable) {
        logger.info("Fetching contacts by company: {}", company);
        return contactRepository.findByCompany(company, pageable)
                .map(this::convertToDto);
    }

    public Page<ContactDto> searchContacts(String keyword, Pageable pageable) {
        logger.info("Searching contacts with keyword: {}", keyword);
        return contactRepository.searchContacts(keyword, pageable)
                .map(this::convertToDto);
    }

    public ContactDto createContact(ContactCreateRequest request) {
        logger.info("Creating new contact with email: {}", request.getEmail());
        
        // Check for duplicate email
        if (request.getEmail() != null && contactRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Contact already exists with email: " + request.getEmail());
        }

        Contact contact = convertToEntity(request);
        
        // Set default values
        if (contact.getContactType() == null) {
            contact.setContactType(ContactType.LEAD);
        }
        if (contact.getStatus() == null) {
            contact.setStatus(ContactStatus.ACTIVE);
        }

        Contact savedContact = contactRepository.save(contact);
        logger.info("Contact created successfully with id: {}", savedContact.getId());
        
        return convertToDto(savedContact);
    }

    public ContactDto updateContact(Long id, ContactUpdateRequest request) {
        logger.info("Updating contact with id: {}", id);
        
        Contact existingContact = contactRepository.findById(id)
                .orElseThrow(() -> new ContactNotFoundException("Contact not found with id: " + id));

        // Check for duplicate email if email is being updated
        if (request.getEmail() != null && 
            !request.getEmail().equals(existingContact.getEmail()) &&
            contactRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Contact already exists with email: " + request.getEmail());
        }

        updateContactFromRequest(existingContact, request);
        Contact updatedContact = contactRepository.save(existingContact);
        
        logger.info("Contact updated successfully with id: {}", updatedContact.getId());
        return convertToDto(updatedContact);
    }

    public void deleteContact(Long id) {
        logger.info("Deleting contact with id: {}", id);
        
        if (!contactRepository.existsById(id)) {
            throw new ContactNotFoundException("Contact not found with id: " + id);
        }
        
        contactRepository.deleteById(id);
        logger.info("Contact deleted successfully with id: {}", id);
    }

    public long getContactCountByType(ContactType contactType) {
        return contactRepository.countByContactType(contactType);
    }

    public long getContactCountByStatus(ContactStatus status) {
        return contactRepository.countByStatus(status);
    }

    public List<ContactDto> getRecentContacts() {
        logger.info("Fetching recent contacts");
        return contactRepository.findTop10ByOrderByCreatedAtDesc()
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