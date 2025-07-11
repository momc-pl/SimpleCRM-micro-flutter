# Simple CRM Microservices - Service Blueprints

## 🎯 Service Design Patterns and Implementation Blueprints

This document provides detailed blueprints for implementing each microservice, including code structure, patterns, and best practices.

---

## 🔐 Auth Service Blueprint

### Service Architecture
```
auth-service/
├── src/main/java/com/simplecrm/auth/
│   ├── AuthServiceApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── JwtConfig.java
│   │   └── OAuth2Config.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   └── UserController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   ├── UserService.java
│   │   ├── JwtService.java
│   │   └── OAuth2UserService.java
│   ├── entity/
│   │   ├── User.java
│   │   ├── Role.java
│   │   └── UserSession.java
│   ├── dto/
│   │   ├── LoginRequest.java
│   │   ├── LoginResponse.java
│   │   ├── RefreshTokenRequest.java
│   │   └── UserProfileDto.java
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── RoleRepository.java
│   │   └── UserSessionRepository.java
│   └── exception/
│       ├── AuthenticationException.java
│       └── AuthorizationException.java
├── src/main/resources/
│   ├── application.yml
│   ├── application-kubernetes.yml
│   └── db/migration/
│       ├── V1__create_users_table.sql
│       ├── V2__create_roles_table.sql
│       └── V3__create_user_sessions_table.sql
└── pom.xml
```

### Core Implementation Classes

#### User Entity
```java
@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    private String name;

    @Column(name = "google_id", unique = true)
    private String googleId;

    @Enumerated(EnumType.STRING)
    private UserStatus status = UserStatus.ACTIVE;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
```

#### JWT Service
```java
@Service
public class JwtService {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private long jwtExpiration;
    
    public String generateToken(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("email", user.getEmail());
        claims.put("name", user.getName());
        claims.put("roles", user.getRoles().stream()
            .map(Role::getName)
            .collect(Collectors.toList()));
        
        return Jwts.builder()
            .setClaims(claims)
            .setSubject(user.getId().toString())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
            .signWith(SignatureAlgorithm.HS256, jwtSecret)
            .compact();
    }
    
    public Claims extractClaims(String token) {
        return Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody();
    }
    
    public boolean isTokenValid(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

#### Auth Controller
```java
@RestController
@RequestMapping("/auth")
@Validated
public class AuthController {
    
    private final AuthService authService;
    
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.authenticateWithGoogle(request.getGoogleToken());
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/profile")
    public ResponseEntity<UserProfileDto> getProfile(@AuthenticationPrincipal User user) {
        UserProfileDto profile = UserProfileDto.from(user);
        return ResponseEntity.ok(profile);
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@AuthenticationPrincipal User user) {
        authService.logout(user);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateToken(@RequestParam String token) {
        boolean isValid = authService.validateToken(token);
        Map<String, Object> response = Map.of("valid", isValid);
        return ResponseEntity.ok(response);
    }
}
```

---

## 👥 Customer Service Blueprint

### Service Architecture
```
customer-service/
├── src/main/java/com/simplecrm/customer/
│   ├── CustomerServiceApplication.java
│   ├── config/
│   │   ├── DatabaseConfig.java
│   │   ├── CacheConfig.java
│   │   └── ValidationConfig.java
│   ├── controller/
│   │   ├── CustomerController.java
│   │   └── AddressController.java
│   ├── service/
│   │   ├── CustomerService.java
│   │   ├── AddressService.java
│   │   └── CustomerValidationService.java
│   ├── entity/
│   │   ├── Customer.java
│   │   ├── Address.java
│   │   ├── CustomerType.java
│   │   └── CustomerStatus.java
│   ├── dto/
│   │   ├── CustomerDto.java
│   │   ├── CustomerCreateRequest.java
│   │   ├── CustomerUpdateRequest.java
│   │   ├── AddressDto.java
│   │   └── CustomerSearchRequest.java
│   ├── repository/
│   │   ├── CustomerRepository.java
│   │   └── AddressRepository.java
│   ├── mapper/
│   │   ├── CustomerMapper.java
│   │   └── AddressMapper.java
│   └── exception/
│       ├── CustomerNotFoundException.java
│       ├── DuplicateEmailException.java
│       └── InvalidCustomerDataException.java
```

### Core Implementation Classes

#### Customer Service with Caching
```java
@Service
@Transactional
public class CustomerService {
    
    private final CustomerRepository customerRepository;
    private final CustomerMapper customerMapper;
    private final CustomerValidationService validationService;
    
    @Cacheable(value = "customers", key = "#id")
    public CustomerDto findById(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new CustomerNotFoundException("Customer not found with id: " + id));
        return customerMapper.toDto(customer);
    }
    
    @Cacheable(value = "customers", key = "'search:' + #request.hashCode()")
    public Page<CustomerDto> searchCustomers(CustomerSearchRequest request, Pageable pageable) {
        Specification<Customer> spec = CustomerSpecification.build(request);
        Page<Customer> customers = customerRepository.findAll(spec, pageable);
        return customers.map(customerMapper::toDto);
    }
    
    @CacheEvict(value = "customers", allEntries = true)
    public CustomerDto createCustomer(CustomerCreateRequest request) {
        validationService.validateCreateRequest(request);
        
        Customer customer = customerMapper.toEntity(request);
        customer.setStatus(CustomerStatus.ACTIVE);
        customer.setCreatedAt(LocalDateTime.now());
        
        Customer savedCustomer = customerRepository.save(customer);
        
        // Publish event
        eventPublisher.publishEvent(new CustomerCreatedEvent(savedCustomer.getId()));
        
        return customerMapper.toDto(savedCustomer);
    }
    
    @CacheEvict(value = "customers", key = "#id")
    public CustomerDto updateCustomer(Long id, CustomerUpdateRequest request) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new CustomerNotFoundException("Customer not found with id: " + id));
        
        customerMapper.updateFromDto(request, customer);
        customer.setUpdatedAt(LocalDateTime.now());
        
        Customer updatedCustomer = customerRepository.save(customer);
        
        // Publish event
        eventPublisher.publishEvent(new CustomerUpdatedEvent(id));
        
        return customerMapper.toDto(updatedCustomer);
    }
}
```

#### Customer Repository with Custom Queries
```java
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long>, JpaSpecificationExecutor<Customer> {
    
    @Query("SELECT c FROM Customer c WHERE c.email = :email AND c.status = 'ACTIVE'")
    Optional<Customer> findActiveByEmail(@Param("email") String email);
    
    @Query("SELECT c FROM Customer c WHERE c.status = 'ACTIVE' ORDER BY c.createdAt DESC")
    Page<Customer> findActiveCustomers(Pageable pageable);
    
    @Query("SELECT COUNT(c) FROM Customer c WHERE c.status = 'ACTIVE' AND c.createdAt >= :date")
    long countActiveCustomersSince(@Param("date") LocalDateTime date);
    
    @Modifying
    @Query("UPDATE Customer c SET c.status = 'INACTIVE' WHERE c.id = :id")
    void softDeleteById(@Param("id") Long id);
    
    @Query(value = """
        SELECT c.* FROM customers c 
        WHERE UPPER(c.name) LIKE UPPER(CONCAT('%', :searchTerm, '%'))
           OR UPPER(c.email) LIKE UPPER(CONCAT('%', :searchTerm, '%'))
           OR UPPER(c.company) LIKE UPPER(CONCAT('%', :searchTerm, '%'))
        ORDER BY c.created_at DESC
        """, nativeQuery = true)
    Page<Customer> findBySearchTerm(@Param("searchTerm") String searchTerm, Pageable pageable);
}
```

---

## 📦 Product Service Blueprint

### Service Architecture with Advanced Features
```java
@Service
@Transactional
public class ProductService {
    
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final PriceHistoryRepository priceHistoryRepository;
    private final InventoryServiceClient inventoryServiceClient;
    
    @Cacheable(value = "products", key = "#id")
    public ProductDto findById(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ProductNotFoundException("Product not found: " + id));
        
        ProductDto dto = ProductMapper.toDto(product);
        
        // Enrich with inventory data
        try {
            InventoryDto inventory = inventoryServiceClient.getInventory(id);
            dto.setAvailableStock(inventory.getAvailableStock());
        } catch (FeignException e) {
            log.warn("Failed to fetch inventory for product {}: {}", id, e.getMessage());
            dto.setAvailableStock(0);
        }
        
        return dto;
    }
    
    @CacheEvict(value = "products", allEntries = true)
    public ProductDto createProduct(ProductCreateRequest request) {
        validateProductData(request);
        
        Product product = ProductMapper.toEntity(request);
        product.setStatus(ProductStatus.ACTIVE);
        product.setCreatedAt(LocalDateTime.now());
        
        // Calculate price with VAT
        BigDecimal grossPrice = calculateGrossPrice(product.getPriceNet(), product.getVatRate());
        product.setPriceGross(grossPrice);
        
        Product savedProduct = productRepository.save(product);
        
        // Save price history
        savePriceHistory(savedProduct);
        
        // Publish event
        eventPublisher.publishEvent(new ProductCreatedEvent(savedProduct.getId()));
        
        return ProductMapper.toDto(savedProduct);
    }
    
    private void savePriceHistory(Product product) {
        PriceHistory priceHistory = new PriceHistory();
        priceHistory.setProduct(product);
        priceHistory.setPriceNet(product.getPriceNet());
        priceHistory.setPriceGross(product.getPriceGross());
        priceHistory.setVatRate(product.getVatRate());
        priceHistory.setEffectiveDate(LocalDateTime.now());
        priceHistoryRepository.save(priceHistory);
    }
}
```

#### Product Search with Elasticsearch
```java
@Service
public class ProductSearchService {
    
    private final ElasticsearchOperations elasticsearchOperations;
    
    public Page<ProductDto> searchProducts(ProductSearchRequest request, Pageable pageable) {
        BoolQueryBuilder queryBuilder = QueryBuilders.boolQuery();
        
        // Text search
        if (StringUtils.hasText(request.getQuery())) {
            queryBuilder.must(QueryBuilders.multiMatchQuery(request.getQuery())
                .field("name", 2.0f)
                .field("description", 1.0f)
                .field("category", 1.5f)
                .type(MultiMatchQueryBuilder.Type.BEST_FIELDS));
        }
        
        // Category filter
        if (StringUtils.hasText(request.getCategory())) {
            queryBuilder.filter(QueryBuilders.termQuery("category.keyword", request.getCategory()));
        }
        
        // Price range filter
        if (request.getMinPrice() != null || request.getMaxPrice() != null) {
            RangeQueryBuilder priceRange = QueryBuilders.rangeQuery("priceNet");
            if (request.getMinPrice() != null) {
                priceRange.gte(request.getMinPrice());
            }
            if (request.getMaxPrice() != null) {
                priceRange.lte(request.getMaxPrice());
            }
            queryBuilder.filter(priceRange);
        }
        
        // Status filter
        queryBuilder.filter(QueryBuilders.termQuery("status", "ACTIVE"));
        
        NativeSearchQuery searchQuery = new NativeSearchQueryBuilder()
            .withQuery(queryBuilder)
            .withPageable(pageable)
            .withSort(SortBuilders.scoreSort().order(SortOrder.DESC))
            .build();
        
        SearchHits<ProductDocument> searchHits = elasticsearchOperations.search(searchQuery, ProductDocument.class);
        
        List<ProductDto> products = searchHits.stream()
            .map(hit -> ProductMapper.toDto(hit.getContent()))
            .collect(Collectors.toList());
        
        return new PageImpl<>(products, pageable, searchHits.getTotalHits());
    }
}
```

---

## 🛒 Order Service Blueprint

### Service Architecture with Saga Pattern
```java
@Service
@Transactional
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final CustomerServiceClient customerServiceClient;
    private final ProductServiceClient productServiceClient;
    private final InventoryServiceClient inventoryServiceClient;
    private final OrderSagaOrchestrator sagaOrchestrator;
    
    public OrderDto createOrder(OrderCreateRequest request) {
        // Start order creation saga
        OrderSaga saga = new OrderSaga(request);
        sagaOrchestrator.execute(saga);
        
        if (saga.isSuccessful()) {
            Order order = saga.getOrder();
            return OrderMapper.toDto(order);
        } else {
            throw new OrderCreationException("Failed to create order: " + saga.getFailureReason());
        }
    }
}

@Component
public class OrderSagaOrchestrator {
    
    private final List<SagaStep> sagaSteps;
    
    public void execute(OrderSaga saga) {
        for (SagaStep step : sagaSteps) {
            try {
                step.execute(saga);
                saga.markStepCompleted(step.getName());
            } catch (Exception e) {
                log.error("Saga step {} failed: {}", step.getName(), e.getMessage());
                compensate(saga, step);
                saga.markAsFailed(e.getMessage());
                break;
            }
        }
    }
    
    private void compensate(OrderSaga saga, SagaStep failedStep) {
        List<String> completedSteps = saga.getCompletedSteps();
        Collections.reverse(completedSteps);
        
        for (String stepName : completedSteps) {
            SagaStep step = findStepByName(stepName);
            try {
                step.compensate(saga);
            } catch (Exception e) {
                log.error("Compensation failed for step {}: {}", stepName, e.getMessage());
            }
        }
    }
}

@Component
public class ValidateCustomerStep implements SagaStep {
    
    private final CustomerServiceClient customerServiceClient;
    
    @Override
    public void execute(OrderSaga saga) {
        CustomerDto customer = customerServiceClient.getCustomer(saga.getCustomerId());
        if (customer == null || !customer.getStatus().equals("ACTIVE")) {
            throw new InvalidCustomerException("Customer is not active");
        }
        saga.setCustomer(customer);
    }
    
    @Override
    public void compensate(OrderSaga saga) {
        // No compensation needed for validation
    }
    
    @Override
    public String getName() {
        return "ValidateCustomer";
    }
}

@Component
public class ReserveInventoryStep implements SagaStep {
    
    private final InventoryServiceClient inventoryServiceClient;
    
    @Override
    public void execute(OrderSaga saga) {
        InventoryReservationRequest request = new InventoryReservationRequest();
        request.setOrderId(saga.getOrderId());
        request.setItems(saga.getOrderItems());
        
        InventoryReservationResponse response = inventoryServiceClient.reserveInventory(request);
        if (!response.isSuccessful()) {
            throw new InsufficientInventoryException("Insufficient inventory for order");
        }
        saga.setReservationId(response.getReservationId());
    }
    
    @Override
    public void compensate(OrderSaga saga) {
        if (saga.getReservationId() != null) {
            inventoryServiceClient.releaseReservation(saga.getReservationId());
        }
    }
    
    @Override
    public String getName() {
        return "ReserveInventory";
    }
}
```

#### Order Calculation Service
```java
@Service
public class OrderCalculationService {
    
    public OrderTotals calculateTotals(List<OrderLineDto> orderLines) {
        BigDecimal totalNet = BigDecimal.ZERO;
        BigDecimal totalVat = BigDecimal.ZERO;
        
        for (OrderLineDto line : orderLines) {
            BigDecimal lineNet = line.getUnitPriceNet().multiply(BigDecimal.valueOf(line.getQuantity()));
            BigDecimal vatAmount = lineNet.multiply(line.getVatRate().divide(BigDecimal.valueOf(100)));
            
            totalNet = totalNet.add(lineNet);
            totalVat = totalVat.add(vatAmount);
            
            line.setLineNet(lineNet);
            line.setLineVat(vatAmount);
            line.setLineGross(lineNet.add(vatAmount));
        }
        
        BigDecimal totalGross = totalNet.add(totalVat);
        
        return new OrderTotals(totalNet, totalVat, totalGross);
    }
    
    public void applyDiscounts(OrderDto order, List<DiscountRule> discountRules) {
        for (DiscountRule rule : discountRules) {
            if (rule.isApplicable(order)) {
                BigDecimal discountAmount = rule.calculateDiscount(order);
                order.addDiscount(new OrderDiscount(rule.getName(), discountAmount));
            }
        }
        
        // Recalculate totals after discounts
        recalculateWithDiscounts(order);
    }
}
```

---

## 📊 Inventory Service Blueprint

### Service Architecture with Event Sourcing
```java
@Service
public class InventoryService {
    
    private final InventoryEventStore eventStore;
    private final InventoryProjectionService projectionService;
    private final InventoryEventPublisher eventPublisher;
    
    public void adjustStock(Long productId, int quantity, InventoryAdjustmentReason reason, String notes) {
        // Create and store event
        InventoryAdjustedEvent event = new InventoryAdjustedEvent(
            UUID.randomUUID().toString(),
            productId,
            quantity,
            reason,
            notes,
            LocalDateTime.now()
        );
        
        eventStore.save(event);
        
        // Update projection
        projectionService.apply(event);
        
        // Publish to external systems
        eventPublisher.publish(event);
        
        // Check for low stock alerts
        checkLowStockAlert(productId);
    }
    
    public InventoryReservationResponse reserveStock(InventoryReservationRequest request) {
        String reservationId = UUID.randomUUID().toString();
        
        for (InventoryReservationItem item : request.getItems()) {
            InventoryProjection currentStock = projectionService.getProjection(item.getProductId());
            
            if (currentStock.getAvailableStock() < item.getQuantity()) {
                throw new InsufficientStockException(
                    "Insufficient stock for product " + item.getProductId() + 
                    ". Available: " + currentStock.getAvailableStock() + 
                    ", Requested: " + item.getQuantity()
                );
            }
            
            // Create reservation event
            StockReservedEvent event = new StockReservedEvent(
                UUID.randomUUID().toString(),
                item.getProductId(),
                item.getQuantity(),
                reservationId,
                request.getOrderId(),
                LocalDateTime.now()
            );
            
            eventStore.save(event);
            projectionService.apply(event);
        }
        
        return new InventoryReservationResponse(reservationId, true);
    }
    
    private void checkLowStockAlert(Long productId) {
        InventoryProjection projection = projectionService.getProjection(productId);
        
        if (projection.getTotalStock() <= projection.getReorderLevel()) {
            LowStockAlert alert = new LowStockAlert(
                productId,
                projection.getTotalStock(),
                projection.getReorderLevel(),
                determineSeverity(projection)
            );
            
            eventPublisher.publishAlert(alert);
        }
    }
}
```

#### Inventory Event Store
```java
@Repository
public class InventoryEventStore {
    
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    
    public void save(InventoryEvent event) {
        String sql = """
            INSERT INTO inventory_events (event_id, product_id, event_type, event_data, created_at)
            VALUES (?, ?, ?, ?, ?)
            """;
        
        try {
            String eventData = objectMapper.writeValueAsString(event);
            jdbcTemplate.update(sql, 
                event.getEventId(),
                event.getProductId(),
                event.getClass().getSimpleName(),
                eventData,
                event.getCreatedAt()
            );
        } catch (JsonProcessingException e) {
            throw new EventSerializationException("Failed to serialize event", e);
        }
    }
    
    public List<InventoryEvent> findByProductId(Long productId) {
        String sql = """
            SELECT event_id, product_id, event_type, event_data, created_at
            FROM inventory_events
            WHERE product_id = ?
            ORDER BY created_at ASC
            """;
        
        return jdbcTemplate.query(sql, this::mapRowToEvent, productId);
    }
    
    private InventoryEvent mapRowToEvent(ResultSet rs, int rowNum) throws SQLException {
        String eventType = rs.getString("event_type");
        String eventData = rs.getString("event_data");
        
        try {
            Class<? extends InventoryEvent> eventClass = getEventClass(eventType);
            return objectMapper.readValue(eventData, eventClass);
        } catch (Exception e) {
            throw new EventDeserializationException("Failed to deserialize event", e);
        }
    }
}
```

---

## 🎯 Sales Pipeline Service Blueprint

### Service Architecture with ML Integration
```java
@Service
public class LeadScoringService {
    
    private final MachineLearningClient mlClient;
    private final LeadRepository leadRepository;
    
    public void scoreLead(Lead lead) {
        LeadScoringRequest request = buildScoringRequest(lead);
        LeadScoringResponse response = mlClient.scoreLead(request);
        
        lead.setScore(response.getScore());
        lead.setScoreFactors(response.getFactors());
        lead.setScoredAt(LocalDateTime.now());
        
        leadRepository.save(lead);
        
        // Trigger actions based on score
        if (response.getScore() >= 80) {
            eventPublisher.publishEvent(new HighValueLeadEvent(lead.getId()));
        }
    }
    
    private LeadScoringRequest buildScoringRequest(Lead lead) {
        return LeadScoringRequest.builder()
            .email(lead.getEmail())
            .company(lead.getCompany())
            .source(lead.getSource())
            .engagementScore(calculateEngagementScore(lead))
            .demographicData(extractDemographicData(lead))
            .build();
    }
}

@Service
public class OpportunityService {
    
    private final OpportunityRepository opportunityRepository;
    private final ForecastingService forecastingService;
    
    @Transactional
    public OpportunityDto updateStage(Long opportunityId, OpportunityStage newStage) {
        Opportunity opportunity = opportunityRepository.findById(opportunityId)
            .orElseThrow(() -> new OpportunityNotFoundException("Opportunity not found: " + opportunityId));
        
        OpportunityStage oldStage = opportunity.getStage();
        opportunity.setStage(newStage);
        opportunity.setUpdatedAt(LocalDateTime.now());
        
        // Update probability based on stage
        opportunity.setProbability(getDefaultProbabilityForStage(newStage));
        
        // Create stage history entry
        createStageHistory(opportunity, oldStage, newStage);
        
        Opportunity savedOpportunity = opportunityRepository.save(opportunity);
        
        // Publish stage change event
        eventPublisher.publishEvent(new OpportunityStageChangedEvent(
            opportunityId, oldStage, newStage, LocalDateTime.now()
        ));
        
        // Update forecasts
        forecastingService.updateForecast(opportunity.getAssignedTo());
        
        return OpportunityMapper.toDto(savedOpportunity);
    }
}
```

---

## 📧 Notification Service Blueprint

### Service Architecture with Template Engine
```java
@Service
public class NotificationService {
    
    private final EmailService emailService;
    private final SmsService smsService;
    private final TemplateEngine templateEngine;
    private final NotificationRepository notificationRepository;
    
    @Async("notificationExecutor")
    public CompletableFuture<Void> sendEmailNotification(EmailNotificationRequest request) {
        try {
            // Render template
            String content = templateEngine.render(request.getTemplate(), request.getVariables());
            
            // Send email
            EmailMessage message = EmailMessage.builder()
                .to(request.getTo())
                .cc(request.getCc())
                .subject(request.getSubject())
                .content(content)
                .priority(request.getPriority())
                .build();
            
            String messageId = emailService.send(message);
            
            // Save notification record
            Notification notification = new Notification();
            notification.setType(NotificationType.EMAIL);
            notification.setRecipient(String.join(",", request.getTo()));
            notification.setSubject(request.getSubject());
            notification.setStatus(NotificationStatus.SENT);
            notification.setMessageId(messageId);
            notification.setSentAt(LocalDateTime.now());
            
            notificationRepository.save(notification);
            
            return CompletableFuture.completedFuture(null);
            
        } catch (Exception e) {
            log.error("Failed to send email notification", e);
            
            // Save failed notification
            saveFailedNotification(request, e.getMessage());
            
            throw new NotificationException("Failed to send email notification", e);
        }
    }
}

@Component
public class TemplateEngine {
    
    private final FreemarkerConfigurer freemarkerConfigurer;
    
    public String render(String templateName, Map<String, Object> variables) {
        try {
            Template template = freemarkerConfigurer.getConfiguration().getTemplate(templateName + ".ftl");
            
            StringWriter writer = new StringWriter();
            template.process(variables, writer);
            
            return writer.toString();
        } catch (Exception e) {
            throw new TemplateRenderingException("Failed to render template: " + templateName, e);
        }
    }
}
```

#### Event-Driven Notification Processing
```java
@Component
public class NotificationEventHandler {
    
    private final NotificationService notificationService;
    
    @EventListener
    @Async
    public void handleCustomerCreated(CustomerCreatedEvent event) {
        EmailNotificationRequest request = EmailNotificationRequest.builder()
            .to(List.of(event.getCustomerEmail()))
            .template("welcome-customer")
            .subject("Welcome to Simple CRM")
            .variables(Map.of(
                "customerName", event.getCustomerName(),
                "companyName", "Simple CRM"
            ))
            .priority(NotificationPriority.NORMAL)
            .build();
        
        notificationService.sendEmailNotification(request);
    }
    
    @EventListener
    @Async
    public void handleOrderPlaced(OrderPlacedEvent event) {
        // Send order confirmation email
        EmailNotificationRequest customerEmail = EmailNotificationRequest.builder()
            .to(List.of(event.getCustomerEmail()))
            .template("order-confirmation")
            .subject("Order Confirmation - " + event.getOrderNumber())
            .variables(Map.of(
                "orderNumber", event.getOrderNumber(),
                "customerName", event.getCustomerName(),
                "totalAmount", event.getTotalAmount(),
                "orderItems", event.getOrderItems()
            ))
            .priority(NotificationPriority.HIGH)
            .build();
        
        notificationService.sendEmailNotification(customerEmail);
        
        // Send SMS notification for high-value orders
        if (event.getTotalAmount().compareTo(BigDecimal.valueOf(1000)) > 0) {
            SmsNotificationRequest smsRequest = SmsNotificationRequest.builder()
                .to(event.getCustomerPhone())
                .message("Your order " + event.getOrderNumber() + " worth $" + 
                        event.getTotalAmount() + " has been confirmed. Thank you!")
                .priority(NotificationPriority.HIGH)
                .build();
            
            notificationService.sendSmsNotification(smsRequest);
        }
    }
}
```

---

## 🔄 Cross-Cutting Concerns

### Circuit Breaker Pattern
```java
@Component
public class CircuitBreakerConfig {
    
    @Bean
    public CircuitBreaker customerServiceCircuitBreaker() {
        return CircuitBreaker.ofDefaults("customerService");
    }
    
    @Bean
    public CircuitBreaker productServiceCircuitBreaker() {
        return CircuitBreaker.ofDefaults("productService");
    }
}

@Service
public class CustomerServiceClient {
    
    private final WebClient webClient;
    private final CircuitBreaker circuitBreaker;
    
    public CustomerDto getCustomer(Long customerId) {
        return circuitBreaker.executeSupplier(() -> {
            return webClient.get()
                .uri("/customers/{id}", customerId)
                .retrieve()
                .bodyToMono(CustomerDto.class)
                .block();
        });
    }
}
```

### Distributed Tracing
```java
@RestController
public class CustomerController {
    
    @GetMapping("/{id}")
    @NewSpan("get-customer")
    public ResponseEntity<CustomerDto> getCustomer(@PathVariable Long id, @SpanTag("customer.id") Long customerId) {
        CustomerDto customer = customerService.findById(id);
        return ResponseEntity.ok(customer);
    }
}
```

### Metrics and Monitoring
```java
@Component
public class CustomMetrics {
    
    private final Counter customerCreatedCounter;
    private final Timer orderProcessingTimer;
    private final Gauge activeCustomersGauge;
    
    public CustomMetrics(MeterRegistry meterRegistry) {
        this.customerCreatedCounter = Counter.builder("customers.created.total")
            .description("Total number of customers created")
            .register(meterRegistry);
            
        this.orderProcessingTimer = Timer.builder("orders.processing.time")
            .description("Order processing time")
            .register(meterRegistry);
            
        this.activeCustomersGauge = Gauge.builder("customers.active.count")
            .description("Number of active customers")
            .register(meterRegistry, this, CustomMetrics::getActiveCustomerCount);
    }
    
    public void incrementCustomerCreated() {
        customerCreatedCounter.increment();
    }
    
    public void recordOrderProcessingTime(Duration duration) {
        orderProcessingTimer.record(duration);
    }
    
    private double getActiveCustomerCount() {
        return customerRepository.countActiveCustomers();
    }
}
```

This comprehensive service blueprint provides detailed implementation patterns, best practices, and code examples for building robust, scalable microservices with proper error handling, monitoring, and cross-cutting concerns.