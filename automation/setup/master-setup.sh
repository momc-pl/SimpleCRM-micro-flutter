#!/bin/bash

# Flutter Development Environment Master Setup Script
# DevOps Automation Specialist - Swarm Agent
# Version: 1.0.0
# Date: $(date +%Y-%m-%d)

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTOMATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AUTOMATION_DIR")"

# Default configuration
DEFAULT_FLUTTER_VERSION="stable"
DEFAULT_DART_VERSION="stable"
DEFAULT_ANDROID_SDK_VERSION="33"
DEFAULT_JAVA_VERSION="17"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
Flutter Development Environment Master Setup Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -f, --flutter-version   Flutter version to install (default: $DEFAULT_FLUTTER_VERSION)
    -d, --dart-version      Dart version to install (default: $DEFAULT_DART_VERSION)
    -a, --android-sdk       Android SDK version (default: $DEFAULT_ANDROID_SDK_VERSION)
    -j, --java-version      Java version (default: $DEFAULT_JAVA_VERSION)
    --skip-android          Skip Android SDK installation
    --skip-ios              Skip iOS development setup (macOS only)
    --skip-web              Skip web development setup
    --skip-desktop          Skip desktop development setup
    --config-only           Only run configuration setup
    --force                 Force reinstallation of existing tools

EXAMPLES:
    $0                      # Default installation
    $0 -v                   # Verbose installation
    $0 -f 3.16.0            # Install specific Flutter version
    $0 --skip-android       # Skip Android development setup
    $0 --config-only        # Only configure environment

EOF
}

# Parse command line arguments
parse_args() {
    VERBOSE=false
    FLUTTER_VERSION="$DEFAULT_FLUTTER_VERSION"
    DART_VERSION="$DEFAULT_DART_VERSION"
    ANDROID_SDK_VERSION="$DEFAULT_ANDROID_SDK_VERSION"
    JAVA_VERSION="$DEFAULT_JAVA_VERSION"
    SKIP_ANDROID=false
    SKIP_IOS=false
    SKIP_WEB=false
    SKIP_DESKTOP=false
    CONFIG_ONLY=false
    FORCE=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--flutter-version)
                FLUTTER_VERSION="$2"
                shift 2
                ;;
            -d|--dart-version)
                DART_VERSION="$2"
                shift 2
                ;;
            -a|--android-sdk)
                ANDROID_SDK_VERSION="$2"
                shift 2
                ;;
            -j|--java-version)
                JAVA_VERSION="$2"
                shift 2
                ;;
            --skip-android)
                SKIP_ANDROID=true
                shift
                ;;
            --skip-ios)
                SKIP_IOS=true
                shift
                ;;
            --skip-web)
                SKIP_WEB=true
                shift
                ;;
            --skip-desktop)
                SKIP_DESKTOP=true
                shift
                ;;
            --config-only)
                CONFIG_ONLY=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        DISTRO=$(lsb_release -si 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        OS="windows"
        DISTRO="windows"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    log_info "Detected OS: $OS ($DISTRO)"
}

# Check system requirements
check_requirements() {
    log_info "Checking system requirements..."
    
    # Check available disk space (minimum 5GB)
    if command -v df >/dev/null 2>&1; then
        AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
        if [[ $AVAILABLE_SPACE -lt 5 ]]; then
            log_error "Insufficient disk space. At least 5GB required, only ${AVAILABLE_SPACE}GB available."
            exit 1
        fi
    fi
    
    # Check memory (minimum 4GB)
    if command -v free >/dev/null 2>&1; then
        TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
        if [[ $TOTAL_MEM -lt 4 ]]; then
            log_warning "Low memory detected (${TOTAL_MEM}GB). Flutter development may be slow."
        fi
    fi
    
    log_success "System requirements check passed"
}

# Setup environment variables
setup_env_vars() {
    log_info "Setting up environment variables..."
    
    # Create environment configuration
    cat > "$PROJECT_ROOT/.env.flutter" << EOF
# Flutter Development Environment Configuration
# Generated by master-setup.sh on $(date)

# Flutter Configuration
FLUTTER_VERSION=$FLUTTER_VERSION
DART_VERSION=$DART_VERSION
FLUTTER_ROOT=\$HOME/flutter
DART_ROOT=\$HOME/flutter/bin/cache/dart-sdk

# Android Configuration
ANDROID_SDK_VERSION=$ANDROID_SDK_VERSION
ANDROID_HOME=\$HOME/Android/Sdk
ANDROID_SDK_ROOT=\$ANDROID_HOME
JAVA_HOME=\$HOME/java/$JAVA_VERSION

# Path additions
export PATH=\$FLUTTER_ROOT/bin:\$DART_ROOT/bin:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools:\$JAVA_HOME/bin:\$PATH

# Flutter Configuration
export PUB_CACHE=\$HOME/.pub-cache
export FLUTTER_SUPPRESS_ANALYTICS=true
export CHROME_EXECUTABLE=/usr/bin/google-chrome

# Development Configuration
export ENABLE_FLUTTER_DESKTOP=true
export FLUTTER_WEB_AUTO_DETECT=true
EOF

    # Source the environment file
    source "$PROJECT_ROOT/.env.flutter"
    
    log_success "Environment variables configured"
}

# Install Flutter
install_flutter() {
    if [[ "$CONFIG_ONLY" == true ]]; then
        return 0
    fi
    
    log_info "Installing Flutter $FLUTTER_VERSION..."
    
    # Check if Flutter is already installed
    if command -v flutter >/dev/null 2>&1 && [[ "$FORCE" == false ]]; then
        CURRENT_VERSION=$(flutter --version | head -1 | cut -d' ' -f2)
        log_info "Flutter $CURRENT_VERSION is already installed"
        return 0
    fi
    
    # Install Flutter based on OS
    case $OS in
        linux)
            "$AUTOMATION_DIR/setup/install-flutter-linux.sh" -v "$FLUTTER_VERSION" ${FORCE:+--force}
            ;;
        macos)
            "$AUTOMATION_DIR/setup/install-flutter-macos.sh" -v "$FLUTTER_VERSION" ${FORCE:+--force}
            ;;
        windows)
            "$AUTOMATION_DIR/setup/install-flutter-windows.sh" -v "$FLUTTER_VERSION" ${FORCE:+--force}
            ;;
    esac
    
    # Configure Flutter
    flutter config --no-analytics
    flutter config --enable-web
    flutter config --enable-linux-desktop
    flutter config --enable-macos-desktop
    flutter config --enable-windows-desktop
    
    log_success "Flutter installation completed"
}

# Setup development environment
setup_development_environment() {
    log_info "Setting up development environment..."
    
    # Run platform-specific setup
    if [[ "$SKIP_ANDROID" == false ]]; then
        log_info "Setting up Android development environment..."
        "$AUTOMATION_DIR/setup/setup-android.sh" -v "$ANDROID_SDK_VERSION" -j "$JAVA_VERSION"
    fi
    
    if [[ "$OS" == "macos" && "$SKIP_IOS" == false ]]; then
        log_info "Setting up iOS development environment..."
        "$AUTOMATION_DIR/setup/setup-ios.sh"
    fi
    
    if [[ "$SKIP_WEB" == false ]]; then
        log_info "Setting up web development environment..."
        "$AUTOMATION_DIR/setup/setup-web.sh"
    fi
    
    if [[ "$SKIP_DESKTOP" == false ]]; then
        log_info "Setting up desktop development environment..."
        "$AUTOMATION_DIR/setup/setup-desktop.sh"
    fi
    
    log_success "Development environment setup completed"
}

# Install development tools
install_dev_tools() {
    if [[ "$CONFIG_ONLY" == true ]]; then
        return 0
    fi
    
    log_info "Installing development tools..."
    
    # Install VS Code extensions
    "$AUTOMATION_DIR/tools/install-vscode-extensions.sh"
    
    # Install Android Studio plugins
    "$AUTOMATION_DIR/tools/install-android-studio-plugins.sh"
    
    # Install other development tools
    "$AUTOMATION_DIR/tools/install-dev-tools.sh"
    
    log_success "Development tools installation completed"
}

# Run health checks
run_health_checks() {
    log_info "Running health checks..."
    
    "$AUTOMATION_DIR/monitoring/health-check.sh" --detailed
    
    log_success "Health checks completed"
}

# Setup project configuration
setup_project_config() {
    log_info "Setting up project configuration..."
    
    # Create project configuration
    "$AUTOMATION_DIR/config/create-project-config.sh" -p "$PROJECT_ROOT"
    
    # Setup development certificates
    "$AUTOMATION_DIR/config/setup-dev-certificates.sh"
    
    # Configure CI/CD templates
    "$AUTOMATION_DIR/config/setup-ci-cd.sh"
    
    log_success "Project configuration completed"
}

# Generate documentation
generate_documentation() {
    log_info "Generating documentation..."
    
    "$AUTOMATION_DIR/tools/generate-docs.sh" -o "$PROJECT_ROOT/docs/automation"
    
    log_success "Documentation generated"
}

# Main execution function
main() {
    log_info "Starting Flutter Development Environment Setup"
    log_info "Project: SimpleCRM Micro Flutter"
    log_info "Automation Version: 1.0.0"
    log_info "Date: $(date)"
    
    # Parse command line arguments
    parse_args "$@"
    
    # Setup execution
    detect_os
    check_requirements
    setup_env_vars
    install_flutter
    setup_development_environment
    install_dev_tools
    setup_project_config
    run_health_checks
    generate_documentation
    
    log_success "Flutter Development Environment Setup Completed Successfully!"
    log_info "Configuration file: $PROJECT_ROOT/.env.flutter"
    log_info "Documentation: $PROJECT_ROOT/docs/automation"
    log_info ""
    log_info "To activate the environment, run:"
    log_info "source $PROJECT_ROOT/.env.flutter"
    log_info ""
    log_info "To verify the installation, run:"
    log_info "flutter doctor"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi