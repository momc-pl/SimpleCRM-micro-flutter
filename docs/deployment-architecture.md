# Simple CRM Microservices Deployment Architecture

## 🚀 Deployment Overview

This document outlines the complete deployment strategy for the Simple CRM microservices architecture, including containerization, orchestration, monitoring, and CI/CD pipelines.

## 🐳 Containerization Strategy

### Docker Base Images

#### Java Services Base Image
```dockerfile
# Dockerfile.base-java
FROM openjdk:11-jre-slim

# Add application user
RUN addgroup --system app && adduser --system --group app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app
RUN chown -R app:app /app

# Switch to app user
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

EXPOSE 8080
```

#### Individual Service Dockerfiles
```dockerfile
# customer-service/Dockerfile
FROM simplecrm/base-java:latest

COPY target/customer-service-*.jar app.jar

ENV SERVICE_NAME=customer-service
ENV SERVER_PORT=8082

EXPOSE 8082

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### Container Image Tagging Strategy
```bash
# Development
simplecrm/customer-service:dev-abc123
simplecrm/customer-service:dev-latest

# Staging
simplecrm/customer-service:staging-v1.2.3
simplecrm/customer-service:staging-latest

# Production
simplecrm/customer-service:v1.2.3
simplecrm/customer-service:latest
```

### Multi-Stage Build Example
```dockerfile
# customer-service/Dockerfile.multi-stage
FROM maven:3.8-openjdk-11 AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM simplecrm/base-java:latest

COPY --from=builder /app/target/customer-service-*.jar app.jar

ENV SERVICE_NAME=customer-service
EXPOSE 8082

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

---

## ☸️ Kubernetes Deployment Configuration

### Namespace Configuration
```yaml
# k8s/namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: simplecrm-dev
  labels:
    environment: development
---
apiVersion: v1
kind: Namespace
metadata:
  name: simplecrm-staging
  labels:
    environment: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: simplecrm-prod
  labels:
    environment: production
```

### ConfigMap for Service Configuration
```yaml
# k8s/configmaps/customer-service-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: customer-service-config
  namespace: simplecrm-prod
data:
  application.yml: |
    server:
      port: 8082
    spring:
      application:
        name: customer-service
      datasource:
        url: jdbc:postgresql://customer-db:5432/customer_db
        username: ${DB_USERNAME}
        password: ${DB_PASSWORD}
      jpa:
        hibernate:
          ddl-auto: validate
        show-sql: false
    management:
      endpoints:
        web:
          exposure:
            include: health,info,metrics,prometheus
      endpoint:
        health:
          show-details: always
    logging:
      level:
        com.simplecrm: INFO
        org.springframework.security: DEBUG
```

### Secret Management
```yaml
# k8s/secrets/customer-service-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: customer-service-secrets
  namespace: simplecrm-prod
type: Opaque
data:
  DB_USERNAME: Y3VzdG9tZXJfdXNlcg== # customer_user (base64)
  DB_PASSWORD: c3VwZXJfc2VjcmV0X3Bhc3N3b3Jk # super_secret_password (base64)
  JWT_SECRET: and0X3NlY3JldF9mb3JfcHJvZHVjdGlvbg== # jwt_secret_for_production (base64)
```

### Service Deployment
```yaml
# k8s/deployments/customer-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-service
  namespace: simplecrm-prod
  labels:
    app: customer-service
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: customer-service
  template:
    metadata:
      labels:
        app: customer-service
        version: v1.0.0
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8082"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      serviceAccountName: customer-service-sa
      containers:
      - name: customer-service
        image: simplecrm/customer-service:v1.0.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8082
          protocol: TCP
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "kubernetes"
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: customer-service-secrets
              key: DB_USERNAME
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: customer-service-secrets
              key: DB_PASSWORD
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: customer-service-secrets
              key: JWT_SECRET
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
          readOnly: true
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8082
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8082
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /actuator/health
            port: 8082
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10
      volumes:
      - name: config-volume
        configMap:
          name: customer-service-config
      imagePullSecrets:
      - name: simplecrm-registry-secret
```

### Service Exposure
```yaml
# k8s/services/customer-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: customer-service
  namespace: simplecrm-prod
  labels:
    app: customer-service
spec:
  type: ClusterIP
  ports:
  - port: 8082
    targetPort: 8082
    protocol: TCP
    name: http
  selector:
    app: customer-service
```

### Horizontal Pod Autoscaler
```yaml
# k8s/hpa/customer-service-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: customer-service-hpa
  namespace: simplecrm-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: customer-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

---

## 🌐 API Gateway Deployment

### Nginx Ingress Controller
```yaml
# k8s/ingress/api-gateway-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  namespace: simplecrm-prod
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - api.simplecrm.com
    secretName: api-simplecrm-tls
  rules:
  - host: api.simplecrm.com
    http:
      paths:
      - path: /api/auth(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: auth-service
            port:
              number: 8081
      - path: /api/customers(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: customer-service
            port:
              number: 8082
      - path: /api/products(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 8083
      - path: /api/orders(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8084
      - path: /api/inventory(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: inventory-service
            port:
              number: 8085
      - path: /api/sales(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: sales-pipeline-service
            port:
              number: 8086
      - path: /api/notifications(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: notification-service
            port:
              number: 8087
```

### API Gateway Service (Spring Cloud Gateway)
```yaml
# k8s/deployments/api-gateway.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: simplecrm-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: simplecrm/api-gateway:v1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "kubernetes"
        - name: EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE
          value: "http://eureka-server:8761/eureka"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

---

## 🗄️ Database Deployment

### PostgreSQL StatefulSet for Customer Service
```yaml
# k8s/databases/customer-db.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: customer-db
  namespace: simplecrm-prod
spec:
  serviceName: customer-db
  replicas: 1
  selector:
    matchLabels:
      app: customer-db
  template:
    metadata:
      labels:
        app: customer-db
    spec:
      containers:
      - name: postgresql
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: customer_db
        - name: POSTGRES_USER
          value: customer_user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: customer-db-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: customer-db-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
  volumeClaimTemplates:
  - metadata:
      name: customer-db-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
      storageClassName: fast-ssd
---
apiVersion: v1
kind: Service
metadata:
  name: customer-db
  namespace: simplecrm-prod
spec:
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: customer-db
  clusterIP: None
```

### Redis Cache Deployment
```yaml
# k8s/cache/redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
  namespace: simplecrm-prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      containers:
      - name: redis
        image: redis:6-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: redis-data
          mountPath: /data
      volumes:
      - name: redis-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: redis-cache
  namespace: simplecrm-prod
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis-cache
```

---

## 📊 Monitoring and Observability

### Prometheus Configuration
```yaml
# k8s/monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "/etc/prometheus/rules/*.yml"
    
    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name
    
    - job_name: 'customer-service'
      static_configs:
      - targets: ['customer-service:8082']
      metrics_path: '/actuator/prometheus'
      scrape_interval: 30s
```

### Grafana Dashboard
```yaml
# k8s/monitoring/grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:8.3.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-secret
              key: admin-password
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-config
        configMap:
          name: grafana-config
```

---

## 🔄 CI/CD Pipeline

### Jenkins Pipeline Configuration
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'simplecrm-registry.com'
        KUBECONFIG_CREDENTIAL = 'kubernetes-config'
        DOCKER_CREDENTIAL = 'docker-registry-creds'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Test') {
            parallel {
                stage('Customer Service') {
                    steps {
                        dir('microservices/customer-service') {
                            sh 'mvn clean test'
                            sh 'mvn package -DskipTests'
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: '**/target/surefire-reports/*.xml'
                            publishCoverage adapters: [jacocoAdapter('**/target/site/jacoco/jacoco.xml')]
                        }
                    }
                }
                
                stage('Order Service') {
                    steps {
                        dir('microservices/order-service') {
                            sh 'mvn clean test'
                            sh 'mvn package -DskipTests'
                        }
                    }
                }
                
                stage('Product Service') {
                    steps {
                        dir('microservices/product-service') {
                            sh 'mvn clean test'
                            sh 'mvn package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    def services = ['customer-service', 'order-service', 'product-service', 'auth-service', 'inventory-service', 'sales-pipeline-service', 'notification-service', 'api-gateway']
                    
                    services.each { service ->
                        dir("microservices/${service}") {
                            sh "docker build -t ${DOCKER_REGISTRY}/${service}:${env.BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${service}:${env.BUILD_NUMBER} ${DOCKER_REGISTRY}/${service}:latest"
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh 'trivy image --format json --output trivy-report.json ${DOCKER_REGISTRY}/customer-service:${BUILD_NUMBER}'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy-report.json',
                        reportName: 'Trivy Security Report'
                    ])
                }
            }
        }
        
        stage('Push Images') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIAL}") {
                        def services = ['customer-service', 'order-service', 'product-service', 'auth-service', 'inventory-service', 'sales-pipeline-service', 'notification-service', 'api-gateway']
                        
                        services.each { service ->
                            docker.image("${DOCKER_REGISTRY}/${service}:${env.BUILD_NUMBER}").push()
                            docker.image("${DOCKER_REGISTRY}/${service}:latest").push()
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${KUBECONFIG_CREDENTIAL}"]) {
                        sh '''
                            # Update image tags in staging manifests
                            sed -i "s/image: simplecrm\\/customer-service:.*/image: simplecrm\\/customer-service:${BUILD_NUMBER}/" k8s/staging/customer-service.yaml
                            
                            # Apply staging configurations
                            kubectl apply -f k8s/staging/ -n simplecrm-staging
                            
                            # Wait for rollout
                            kubectl rollout status deployment/customer-service -n simplecrm-staging --timeout=300s
                        '''
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                dir('integration-tests') {
                    sh 'mvn test -Dtest.environment=staging'
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'integration-tests/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                script {
                    withKubeConfig([credentialsId: "${KUBECONFIG_CREDENTIAL}"]) {
                        sh '''
                            # Update image tags in production manifests
                            sed -i "s/image: simplecrm\\/customer-service:.*/image: simplecrm\\/customer-service:${BUILD_NUMBER}/" k8s/production/customer-service.yaml
                            
                            # Apply production configurations
                            kubectl apply -f k8s/production/ -n simplecrm-prod
                            
                            # Wait for rollout
                            kubectl rollout status deployment/customer-service -n simplecrm-prod --timeout=600s
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                channel: '#deployments',
                color: 'good',
                message: "✅ Deployment successful for build ${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                channel: '#deployments',
                color: 'danger',
                message: "❌ Deployment failed for build ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

### GitLab CI/CD Configuration
```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - security
  - deploy-staging
  - integration-test
  - deploy-production

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"

cache:
  paths:
    - .m2/repository/

test:
  stage: test
  image: maven:3.8-openjdk-11
  script:
    - cd microservices/customer-service
    - mvn clean test
  artifacts:
    reports:
      junit:
        - microservices/*/target/surefire-reports/TEST-*.xml
    paths:
      - microservices/*/target/

build:
  stage: build
  image: docker:20.10.7
  services:
    - docker:20.10.7-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - |
      for service in customer-service order-service product-service auth-service inventory-service sales-pipeline-service notification-service api-gateway; do
        cd microservices/$service
        docker build -t $CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA .
        docker push $CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA
        cd ../..
      done

security-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE/customer-service:$CI_COMMIT_SHA

deploy-staging:
  stage: deploy-staging
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context $KUBE_CONTEXT_STAGING
    - |
      for service in customer-service order-service product-service auth-service inventory-service sales-pipeline-service notification-service api-gateway; do
        kubectl set image deployment/$service $service=$CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA -n simplecrm-staging
        kubectl rollout status deployment/$service -n simplecrm-staging --timeout=300s
      done
  environment:
    name: staging
    url: https://staging-api.simplecrm.com

integration-test:
  stage: integration-test
  image: maven:3.8-openjdk-11
  script:
    - cd integration-tests
    - mvn test -Dtest.environment=staging
  dependencies:
    - deploy-staging

deploy-production:
  stage: deploy-production
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context $KUBE_CONTEXT_PRODUCTION
    - |
      for service in customer-service order-service product-service auth-service inventory-service sales-pipeline-service notification-service api-gateway; do
        kubectl set image deployment/$service $service=$CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA -n simplecrm-prod
        kubectl rollout status deployment/$service -n simplecrm-prod --timeout=600s
      done
  environment:
    name: production
    url: https://api.simplecrm.com
  when: manual
  only:
    - main
```

---

## 🔒 Security Configuration

### Network Policies
```yaml
# k8s/security/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: customer-service-netpol
  namespace: simplecrm-prod
spec:
  podSelector:
    matchLabels:
      app: customer-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    - podSelector:
        matchLabels:
          app: order-service
    ports:
    - protocol: TCP
      port: 8082
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: customer-db
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: auth-service
    ports:
    - protocol: TCP
      port: 8081
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

### Pod Security Policy
```yaml
# k8s/security/pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: simplecrm-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  runAsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

### Service Account and RBAC
```yaml
# k8s/security/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: customer-service-sa
  namespace: simplecrm-prod
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: simplecrm-prod
  name: customer-service-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: customer-service-rolebinding
  namespace: simplecrm-prod
subjects:
- kind: ServiceAccount
  name: customer-service-sa
  namespace: simplecrm-prod
roleRef:
  kind: Role
  name: customer-service-role
  apiGroup: rbac.authorization.k8s.io
```

This comprehensive deployment architecture provides a robust, scalable, and secure foundation for the Simple CRM microservices system with proper containerization, orchestration, monitoring, and CI/CD practices.