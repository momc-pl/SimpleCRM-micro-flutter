package com.simplecrm.service;

import com.simplecrm.entity.Customer;
import com.simplecrm.entity.CustomerStatus;
import com.simplecrm.entity.CustomerType;
import com.simplecrm.repository.CustomerRepository;
import com.simplecrm.dto.CustomerDto;
import com.simplecrm.dto.CustomerCreateRequest;
import com.simplecrm.dto.CustomerUpdateRequest;
import com.simplecrm.exception.CustomerNotFoundException;
import com.simplecrm.exception.DuplicateEmailException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CustomerService {

    private final CustomerRepository customerRepository;

    @Autowired
    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    public CustomerDto createCustomer(CustomerCreateRequest request, Long userId) {
        // Check if email already exists
        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Customer with email " + request.getEmail() + " already exists");
        }

        Customer customer = new Customer();
        customer.setName(request.getName());
        customer.setEmail(request.getEmail());
        customer.setPhone(request.getPhone());
        customer.setCompany(request.getCompany());
        customer.setCustomerType(request.getCustomerType());
        customer.setNotes(request.getNotes());
        customer.setUserId(userId);

        Customer savedCustomer = customerRepository.save(customer);
        return convertToDto(savedCustomer);
    }

    public CustomerDto updateCustomer(Long customerId, CustomerUpdateRequest request, Long userId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new CustomerNotFoundException("Customer not found with id: " + customerId));

        // Check if user owns this customer
        if (!customer.getUserId().equals(userId)) {
            throw new CustomerNotFoundException("Customer not found with id: " + customerId);
        }

        // Check if email is being changed and if it already exists
        if (!customer.getEmail().equals(request.getEmail()) && 
            customerRepository.existsByEmailAndIdNot(request.getEmail(), customerId)) {
            throw new DuplicateEmailException("Customer with email " + request.getEmail() + " already exists");
        }

        customer.setName(request.getName());
        customer.setEmail(request.getEmail());
        customer.setPhone(request.getPhone());
        customer.setCompany(request.getCompany());
        customer.setCustomerType(request.getCustomerType());
        customer.setStatus(request.getStatus());
        customer.setNotes(request.getNotes());

        Customer updatedCustomer = customerRepository.save(customer);
        return convertToDto(updatedCustomer);
    }

    @Transactional(readOnly = true)
    public CustomerDto getCustomerById(Long customerId, Long userId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new CustomerNotFoundException("Customer not found with id: " + customerId));

        // Check if user owns this customer
        if (!customer.getUserId().equals(userId)) {
            throw new CustomerNotFoundException("Customer not found with id: " + customerId);
        }

        return convertToDto(customer);
    }

    @Transactional(readOnly = true)
    public Page<CustomerDto> getCustomers(Long userId, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return customerRepository.findByUserId(userId, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<CustomerDto> searchCustomers(Long userId, String search, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return customerRepository.findByUserIdAndSearchTerm(userId, search, pageable)
                .map(this::convertToDto);
    }

    @Transactional(readOnly = true)
    public Page<CustomerDto> getCustomersByStatus(Long userId, CustomerStatus status, int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        return customerRepository.findByUserIdAndStatus(userId, status, pageable)
                .map(this::convertToDto);
    }

    public void deleteCustomer(Long customerId, Long userId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new CustomerNotFoundException("Customer not found with id: " + customerId));

        // Check if user owns this customer
        if (!customer.getUserId().equals(userId)) {
            throw new CustomerNotFoundException("Customer not found with id: " + customerId);
        }

        customerRepository.delete(customer);
    }

    @Transactional(readOnly = true)
    public Long getCustomerCount(Long userId) {
        return customerRepository.countByUserId(userId);
    }

    @Transactional(readOnly = true)
    public Long getCustomerCountByStatus(Long userId, CustomerStatus status) {
        return customerRepository.countByUserIdAndStatus(userId, status);
    }

    private CustomerDto convertToDto(Customer customer) {
        return new CustomerDto(
                customer.getId(),
                customer.getName(),
                customer.getEmail(),
                customer.getPhone(),
                customer.getCompany(),
                customer.getCustomerType(),
                customer.getStatus(),
                customer.getNotes(),
                customer.getCreatedAt(),
                customer.getUpdatedAt()
        );
    }
}