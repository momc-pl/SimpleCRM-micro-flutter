#!/bin/bash

# SimpleCRM macOS M3 Optimized Startup Script
# Configures and starts the entire CRM system optimized for MacBook Pro M3

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MICROSERVICES_DIR="$PROJECT_ROOT/microservices"
DOCKER_COMPOSE_FILE="$MICROSERVICES_DIR/docker-compose.m3.yml"
ENV_FILE="$PROJECT_ROOT/.env.m3"

# Function to print colored output
print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE} SimpleCRM M3 Deployment Manager${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Check if running on macOS ARM64
check_platform() {
    print_step "Checking platform compatibility..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS. Current OS: $OSTYPE"
        exit 1
    fi
    
    ARCH=$(uname -m)
    if [[ "$ARCH" != "arm64" ]]; then
        print_warning "This script is optimized for Apple Silicon (ARM64). Current arch: $ARCH"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Platform: macOS ARM64 (Apple Silicon)"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("Docker Desktop")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("Docker Compose")
    fi
    
    if ! command -v java &> /dev/null; then
        missing_tools+=("Java JDK")
    fi
    
    if ! command -v mvn &> /dev/null; then
        missing_tools+=("Maven")
    fi
    
    if ! command -v flutter &> /dev/null; then
        missing_tools+=("Flutter SDK")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        print_status "Install missing tools and re-run this script."
        exit 1
    fi
    
    # Check Docker buildx for multi-platform builds
    if ! docker buildx version &> /dev/null; then
        print_warning "Docker buildx not available. Multi-platform builds may not work."
    else
        print_success "Docker buildx available for ARM64 builds"
    fi
    
    print_success "All prerequisites satisfied"
}

# Check Docker Desktop settings
check_docker_settings() {
    print_step "Checking Docker Desktop settings..."
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    # Check available resources
    DOCKER_MEMORY=$(docker system info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
    DOCKER_CPUS=$(docker system info --format '{{.NCPU}}' 2>/dev/null || echo "0")
    
    print_status "Docker resources: ${DOCKER_CPUS} CPUs, $((DOCKER_MEMORY / 1024 / 1024 / 1024))GB RAM"
    
    if [ "$DOCKER_MEMORY" -lt 4294967296 ]; then  # 4GB
        print_warning "Docker has less than 4GB RAM allocated. Consider increasing for better performance."
    fi
    
    print_success "Docker Desktop ready"
}

# Setup environment variables for M3
setup_environment() {
    print_step "Setting up M3-optimized environment..."
    
    cat > "$ENV_FILE" << EOF
# SimpleCRM M3 Environment Configuration
# Optimized for MacBook Pro M3 (ARM64)

# Platform settings
PLATFORM=linux/arm64
COMPOSE_PROJECT_NAME=simplecrm-m3

# Database settings (ARM64 optimized)
POSTGRES_VERSION=15-alpine
POSTGRES_SHARED_BUFFERS=256MB
POSTGRES_EFFECTIVE_CACHE_SIZE=1GB
POSTGRES_WORK_MEM=8MB
POSTGRES_MAINTENANCE_WORK_MEM=128MB

# Java/JVM settings (ARM64 optimized)
JAVA_BASE_IMAGE=openjdk:17-jre-alpine
JAVA_OPTS_BASE=-Xms256m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+AlwaysPreTouch -XX:+UseStringDeduplication

# Service-specific JVM settings
AUTH_SERVICE_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx512m
CUSTOMER_SERVICE_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx512m
PRODUCT_SERVICE_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx512m
ORDER_SERVICE_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx512m
SALES_SERVICE_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx512m
API_GATEWAY_JAVA_OPTS=\${JAVA_OPTS_BASE} -Xmx768m

# Docker Compose settings
COMPOSE_HTTP_TIMEOUT=300
COMPOSE_PARALLEL_LIMIT=10

# Development settings
DEV_MODE=true
LOG_LEVEL=INFO
ENABLE_MONITORING=true

# Flutter settings
FLUTTER_WEB_PORT=3000
FLUTTER_WEB_HOSTNAME=0.0.0.0

# Network settings
NETWORK_SUBNET=172.20.0.0/16
EOF
    
    print_success "Environment configured: $ENV_FILE"
}

# Build services with ARM64 optimization
build_services() {
    print_step "Building services for ARM64..."
    
    cd "$MICROSERVICES_DIR"
    
    # Enable Docker buildx
    docker buildx create --name m3builder --use --bootstrap || true
    docker buildx inspect --bootstrap
    
    # Build shared library first
    if [ -d "shared-lib" ]; then
        print_status "Building shared library..."
        cd shared-lib
        mvn clean install -DskipTests -q
        cd ..
    fi
    
    # List of services to build
    SERVICES=("auth-service" "customer-service" "api-gateway")
    
    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ] && [ -f "$service/Dockerfile.m3" ]; then
            print_status "Building $service for ARM64..."
            cd "$service"
            
            # Build JAR if pom.xml exists
            if [ -f "pom.xml" ]; then
                mvn clean package -DskipTests -q
            fi
            
            # Build Docker image for ARM64
            docker buildx build \
                --platform linux/arm64 \
                -f Dockerfile.m3 \
                -t "simplecrm/$service:m3-latest" \
                --load \
                .
            
            cd ..
            print_success "$service built successfully"
        else
            print_warning "Skipping $service (no Dockerfile.m3 found)"
        fi
    done
    
    cd "$PROJECT_ROOT"
}

# Start services with monitoring
start_services() {
    print_step "Starting SimpleCRM services..."
    
    cd "$MICROSERVICES_DIR"
    
    # Load environment
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
    
    # Start services with M3-optimized compose file
    docker-compose -f docker-compose.m3.yml down --remove-orphans || true
    docker-compose -f docker-compose.m3.yml up -d
    
    print_success "Services started"
    cd "$PROJECT_ROOT"
}

# Health check and monitoring
health_check() {
    print_step "Performing health checks..."
    
    # Wait for services to be ready
    local max_attempts=30
    local attempt=1
    
    services=(
        "http://localhost:8080/api/v1/actuator/health:Auth Service"
        "http://localhost:8081/api/v1/actuator/health:Customer Service"
        "http://localhost:8090/actuator/health:API Gateway"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r url name <<< "$service_info"
        print_status "Checking $name..."
        
        attempt=1
        while [ $attempt -le $max_attempts ]; do
            if curl -sf "$url" > /dev/null 2>&1; then
                print_success "$name is healthy"
                break
            else
                if [ $attempt -eq $max_attempts ]; then
                    print_warning "$name health check failed after $max_attempts attempts"
                else
                    echo -n "."
                    sleep 2
                    ((attempt++))
                fi
            fi
        done
    done
}

# Setup development tools
setup_dev_tools() {
    print_step "Setting up development tools..."
    
    # Create monitoring configuration
    mkdir -p "$MICROSERVICES_DIR/monitoring"
    
    cat > "$MICROSERVICES_DIR/monitoring/prometheus.yml" << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'spring-boot'
    static_configs:
      - targets: ['auth-service:8080', 'customer-service:8081', 'api-gateway:8090']
    metrics_path: '/actuator/prometheus'
EOF
    
    print_success "Development tools configured"
}

# Create useful scripts
create_helper_scripts() {
    print_step "Creating helper scripts..."
    
    # Create logs viewer script
    cat > "$PROJECT_ROOT/scripts/logs.sh" << 'EOF'
#!/bin/bash
# View logs for SimpleCRM services
cd "$(dirname "$0")/../microservices"
if [ $# -eq 0 ]; then
    docker-compose -f docker-compose.m3.yml logs -f
else
    docker-compose -f docker-compose.m3.yml logs -f "$1"
fi
EOF
    
    # Create stop script
    cat > "$PROJECT_ROOT/scripts/stop.sh" << 'EOF'
#!/bin/bash
# Stop SimpleCRM services
cd "$(dirname "$0")/../microservices"
docker-compose -f docker-compose.m3.yml down
EOF
    
    # Create restart script
    cat > "$PROJECT_ROOT/scripts/restart.sh" << 'EOF'
#!/bin/bash
# Restart SimpleCRM services
cd "$(dirname "$0")/../microservices"
docker-compose -f docker-compose.m3.yml restart
EOF
    
    chmod +x "$PROJECT_ROOT/scripts/"*.sh
    
    print_success "Helper scripts created in scripts/ directory"
}

# Display service information
show_service_info() {
    print_header
    echo ""
    print_success "SimpleCRM is now running on your MacBook Pro M3!"
    echo ""
    echo -e "${CYAN}Service URLs:${NC}"
    echo "  🔐 Auth Service:      http://localhost:8080/api/v1"
    echo "  👥 Customer Service:  http://localhost:8081/api/v1"
    echo "  🛒 Product Service:   http://localhost:8082/api/v1"
    echo "  📦 Order Service:     http://localhost:8083/api/v1"
    echo "  💰 Sales Service:     http://localhost:8084/api/v1"
    echo "  🌐 API Gateway:       http://localhost:8090"
    echo ""
    echo -e "${CYAN}Monitoring:${NC}"
    echo "  📊 Prometheus:        http://localhost:9090"
    echo "  📈 Grafana:          http://localhost:3000 (admin/admin)"
    echo ""
    echo -e "${CYAN}Management Commands:${NC}"
    echo "  📋 View logs:         ./scripts/logs.sh [service-name]"
    echo "  🔄 Restart:          ./scripts/restart.sh"
    echo "  🛑 Stop:             ./scripts/stop.sh"
    echo ""
    echo -e "${CYAN}Docker Commands:${NC}"
    echo "  📊 System info:      docker system info"
    echo "  💾 System usage:     docker system df"
    echo "  🧹 Cleanup:          docker system prune"
    echo ""
    print_status "Optimized for ARM64 architecture with G1GC and container-aware JVM settings"
}

# Main execution flow
main() {
    print_header
    echo ""
    
    # Parse command line arguments
    BUILD_ONLY=false
    SKIP_BUILD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --build-only     Only build services, don't start them"
                echo "  --skip-build     Skip build step, only start services"
                echo "  --help           Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Create scripts directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/scripts"
    
    # Execute steps
    check_platform
    check_prerequisites
    check_docker_settings
    setup_environment
    setup_dev_tools
    create_helper_scripts
    
    if [ "$SKIP_BUILD" = false ]; then
        build_services
    fi
    
    if [ "$BUILD_ONLY" = false ]; then
        start_services
        health_check
        show_service_info
    else
        print_success "Build completed. Use --skip-build to start services."
    fi
}

# Execute main function with all arguments
main "$@"