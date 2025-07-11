#!/bin/bash

# SimpleCRM Microservices Build Script
# This script builds all microservices and creates Docker images

set -e  # Exit on any error

echo "🚀 Starting SimpleCRM Microservices Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        print_error "Maven is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    print_success "All prerequisites are met"
}

# Build shared library first
build_shared_lib() {
    print_status "Building shared library..."
    cd shared-lib
    
    if mvn clean install -DskipTests; then
        print_success "Shared library built successfully"
    else
        print_error "Failed to build shared library"
        exit 1
    fi
    
    cd ..
}

# Build a single service
build_service() {
    local service_name=$1
    print_status "Building $service_name..."
    
    cd "$service_name"
    
    # Clean and package
    if mvn clean package -DskipTests; then
        print_success "$service_name built successfully"
    else
        print_error "Failed to build $service_name"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Run tests for a service
test_service() {
    local service_name=$1
    print_status "Running tests for $service_name..."
    
    cd "$service_name"
    
    if mvn test; then
        print_success "$service_name tests passed"
    else
        print_warning "$service_name tests failed"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Build Docker image for a service
build_docker_image() {
    local service_name=$1
    print_status "Building Docker image for $service_name..."
    
    cd "$service_name"
    
    if docker build -t "simplecrm/$service_name:latest" .; then
        print_success "Docker image for $service_name built successfully"
    else
        print_error "Failed to build Docker image for $service_name"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Main build process
main() {
    # Parse command line arguments
    RUN_TESTS=false
    BUILD_DOCKER=false
    SKIP_SHARED_LIB=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --test)
                RUN_TESTS=true
                shift
                ;;
            --docker)
                BUILD_DOCKER=true
                shift
                ;;
            --skip-shared-lib)
                SKIP_SHARED_LIB=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --test           Run tests for all services"
                echo "  --docker         Build Docker images"
                echo "  --skip-shared-lib Skip building shared library"
                echo "  --help           Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # List of services to build
    SERVICES=("auth-service" "customer-service" "product-service" "api-gateway")
    
    # Build shared library first (unless skipped)
    if [ "$SKIP_SHARED_LIB" = false ]; then
        build_shared_lib
    else
        print_warning "Skipping shared library build"
    fi
    
    # Build all services
    print_status "Building microservices..."
    failed_builds=()
    
    for service in "${SERVICES[@]}"; do
        if [ -d "$service" ]; then
            if ! build_service "$service"; then
                failed_builds+=("$service")
            fi
        else
            print_warning "Service directory $service not found, skipping..."
        fi
    done
    
    # Run tests if requested
    if [ "$RUN_TESTS" = true ]; then
        print_status "Running tests for all services..."
        failed_tests=()
        
        for service in "${SERVICES[@]}"; do
            if [ -d "$service" ]; then
                if ! test_service "$service"; then
                    failed_tests+=("$service")
                fi
            fi
        done
        
        if [ ${#failed_tests[@]} -gt 0 ]; then
            print_warning "Tests failed for: ${failed_tests[*]}"
        else
            print_success "All tests passed!"
        fi
    fi
    
    # Build Docker images if requested
    if [ "$BUILD_DOCKER" = true ]; then
        print_status "Building Docker images..."
        failed_docker_builds=()
        
        for service in "${SERVICES[@]}"; do
            if [ -d "$service" ] && [ ! -f "$service/target/*.jar" ]; then
                print_warning "JAR file not found for $service, skipping Docker build"
                continue
            fi
            
            if [ -d "$service" ]; then
                if ! build_docker_image "$service"; then
                    failed_docker_builds+=("$service")
                fi
            fi
        done
        
        if [ ${#failed_docker_builds[@]} -gt 0 ]; then
            print_warning "Docker builds failed for: ${failed_docker_builds[*]}"
        else
            print_success "All Docker images built successfully!"
        fi
    fi
    
    # Summary
    echo ""
    print_status "Build Summary:"
    if [ ${#failed_builds[@]} -gt 0 ]; then
        print_error "Failed builds: ${failed_builds[*]}"
    else
        print_success "All services built successfully!"
    fi
    
    if [ "$RUN_TESTS" = true ] && [ ${#failed_tests[@]} -eq 0 ]; then
        print_success "All tests passed!"
    fi
    
    if [ "$BUILD_DOCKER" = true ] && [ ${#failed_docker_builds[@]} -eq 0 ]; then
        print_success "All Docker images built!"
    fi
    
    print_success "Build process completed!"
    
    # Instructions for next steps
    echo ""
    print_status "Next Steps:"
    echo "1. To start all services: docker-compose up -d"
    echo "2. To view logs: docker-compose logs -f [service-name]"
    echo "3. To stop services: docker-compose down"
    echo "4. API Gateway will be available at: http://localhost:8090"
}

# Run main function with all arguments
main "$@"