#!/bin/bash

# Flutter SDK Installation Script
# Flutter Environment Specialist Agent - Swarm ID: swarm-development-hierachical-1752155283037
# This script installs Flutter SDK with proper versioning and PATH configuration

set -e

# Configuration
FLUTTER_VERSION="3.24.3"
INSTALL_DIR="$HOME/flutter"
FLUTTER_HOME="$INSTALL_DIR"
FLUTTER_BIN="$FLUTTER_HOME/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is already installed
check_existing_flutter() {
    if command -v flutter &> /dev/null; then
        CURRENT_VERSION=$(flutter --version | head -n 1 | cut -d' ' -f2)
        warning "Flutter is already installed (version $CURRENT_VERSION)"
        read -p "Do you want to reinstall Flutter $FLUTTER_VERSION? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Skipping Flutter installation"
            return 1
        fi
    fi
    return 0
}

# Install system dependencies
install_dependencies() {
    log "Installing system dependencies..."
    
    # Update package list
    sudo apt-get update -qq
    
    # Install required packages
    sudo apt-get install -y \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        file \
        build-essential \
        cmake \
        pkg-config \
        libgtk-3-dev \
        liblzma-dev \
        libstdc++6 \
        fonts-droid-fallback \
        ttf-wqy-zenhei \
        clang \
        ninja-build \
        libgtk-3-dev \
        libblkid-dev \
        liblzma-dev
    
    success "System dependencies installed"
}

# Download and install Flutter SDK
install_flutter_sdk() {
    log "Downloading Flutter SDK version $FLUTTER_VERSION..."
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Remove existing Flutter installation if present
    if [ -d "flutter" ]; then
        rm -rf flutter
    fi
    
    # Download Flutter SDK
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz"
    wget -q --show-progress "$FLUTTER_URL" -O flutter.tar.xz
    
    # Extract Flutter SDK
    log "Extracting Flutter SDK..."
    tar -xf flutter.tar.xz
    rm flutter.tar.xz
    
    # Move to final location
    if [ "$INSTALL_DIR" != "$HOME" ]; then
        mv flutter/* .
        rmdir flutter
    fi
    
    success "Flutter SDK installed to $FLUTTER_HOME"
}

# Configure PATH and environment variables
configure_environment() {
    log "Configuring environment variables..."
    
    # Backup existing shell configuration
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Remove existing Flutter PATH entries
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# Flutter SDK/d' "$HOME/.bashrc"
        sed -i '/export PATH.*flutter/d' "$HOME/.bashrc"
        sed -i '/export FLUTTER_HOME/d' "$HOME/.bashrc"
    fi
    
    # Add Flutter to PATH
    cat >> "$HOME/.bashrc" << EOF

# Flutter SDK
export FLUTTER_HOME="$FLUTTER_HOME"
export PATH="\$FLUTTER_HOME/bin:\$PATH"
EOF
    
    # Also add to current session
    export FLUTTER_HOME="$FLUTTER_HOME"
    export PATH="$FLUTTER_HOME/bin:$PATH"
    
    # Create symlink for system-wide access (optional)
    if [ -w "/usr/local/bin" ]; then
        sudo ln -sf "$FLUTTER_BIN/flutter" /usr/local/bin/flutter
        sudo ln -sf "$FLUTTER_BIN/dart" /usr/local/bin/dart
    fi
    
    success "Environment configured"
}

# Verify Flutter installation
verify_installation() {
    log "Verifying Flutter installation..."
    
    # Source the updated bashrc
    export FLUTTER_HOME="$FLUTTER_HOME"
    export PATH="$FLUTTER_HOME/bin:$PATH"
    
    # Check Flutter version
    if command -v flutter &> /dev/null; then
        INSTALLED_VERSION=$(flutter --version | head -n 1 | cut -d' ' -f2)
        success "Flutter $INSTALLED_VERSION is installed and accessible"
        
        # Run flutter doctor to check setup
        log "Running Flutter doctor..."
        flutter doctor --android-licenses --suppress-analytics > /dev/null 2>&1 || true
        flutter doctor
        
        return 0
    else
        error "Flutter installation verification failed"
        return 1
    fi
}

# Enable Flutter analytics (optional)
configure_analytics() {
    log "Configuring Flutter analytics..."
    
    # Disable analytics by default for automated setup
    flutter config --no-analytics > /dev/null 2>&1 || true
    
    success "Flutter analytics configured"
}

# Main installation function
main() {
    log "Starting Flutter SDK installation..."
    log "Flutter version: $FLUTTER_VERSION"
    log "Installation directory: $FLUTTER_HOME"
    
    # Check if reinstallation is needed
    if ! check_existing_flutter; then
        exit 0
    fi
    
    # Install dependencies
    install_dependencies
    
    # Install Flutter SDK
    install_flutter_sdk
    
    # Configure environment
    configure_environment
    
    # Configure analytics
    configure_analytics
    
    # Verify installation
    if verify_installation; then
        success "Flutter SDK installation completed successfully!"
        log "Please run 'source ~/.bashrc' or restart your terminal to use Flutter"
        log "Or run 'export PATH=\"$FLUTTER_HOME/bin:\$PATH\"' in your current session"
        
        # Display next steps
        echo
        echo "Next steps:"
        echo "1. Run 'flutter doctor' to check your setup"
        echo "2. Install Android Studio for Android development"
        echo "3. Configure IDE plugins (VS Code Flutter extension)"
        echo "4. Create your first Flutter project with 'flutter create myapp'"
        
        return 0
    else
        error "Flutter SDK installation failed"
        return 1
    fi
}

# Run main function
main "$@"