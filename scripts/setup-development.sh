#!/bin/bash

# Pulse Trading Signals - Development Setup Script
# This script sets up your local development environment

set -e  # Exit on any error

echo "🚀 Setting up Pulse Trading Signals development environment..."

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

# Detect operating system
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    MINGW*)     MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

print_status "Detected OS: ${MACHINE}"

# Check if running on supported OS
if [[ "$MACHINE" != "Linux" && "$MACHINE" != "Mac" ]]; then
    print_error "This script currently supports Linux and macOS only."
    print_status "For Windows, please use WSL2 or follow manual setup instructions."
    exit 1
fi

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    print_status "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
else
    FLUTTER_VERSION=$(flutter --version | head -1)
    print_success "Flutter found: $FLUTTER_VERSION"
fi

# Check if Dart is installed (should come with Flutter)
if ! command -v dart &> /dev/null; then
    print_warning "Dart command not found. This might be normal if using Flutter's bundled Dart."
else
    DART_VERSION=$(dart --version)
    print_success "Dart found: $DART_VERSION"
fi

# Create .env file if it doesn't exist
print_status "Setting up environment configuration..."

if [[ ! -f ".env" ]]; then
    if [[ -f ".env.example" ]]; then
        cp .env.example .env
        print_success "Created .env file from .env.example"
        print_warning "Please edit .env file with your actual API keys and configuration"
    else
        print_error ".env.example file not found"
        exit 1
    fi
else
    print_status ".env file already exists"
fi

# Download and setup PocketBase
print_status "Setting up PocketBase..."

# Create pocketbase directory if it doesn't exist
mkdir -p pocketbase/pb_data

# Check if PocketBase binary exists
POCKETBASE_VERSION="0.22.20"
POCKETBASE_DIR="pocketbase"

if [[ "$MACHINE" == "Linux" ]]; then
    POCKETBASE_ARCHIVE="pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip"
    POCKETBASE_URL="https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/${POCKETBASE_ARCHIVE}"
elif [[ "$MACHINE" == "Mac" ]]; then
    # Detect if Apple Silicon or Intel
    if [[ "$(uname -m)" == "arm64" ]]; then
        POCKETBASE_ARCHIVE="pocketbase_${POCKETBASE_VERSION}_darwin_arm64.zip"
    else
        POCKETBASE_ARCHIVE="pocketbase_${POCKETBASE_VERSION}_darwin_amd64.zip"
    fi
    POCKETBASE_URL="https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/${POCKETBASE_ARCHIVE}"
fi

if [[ ! -f "${POCKETBASE_DIR}/pocketbase" ]]; then
    print_status "Downloading PocketBase ${POCKETBASE_VERSION}..."
    
    # Download PocketBase
    curl -L -o "/tmp/${POCKETBASE_ARCHIVE}" "${POCKETBASE_URL}"
    
    # Extract to pocketbase directory
    unzip "/tmp/${POCKETBASE_ARCHIVE}" -d "${POCKETBASE_DIR}/"
    
    # Make executable
    chmod +x "${POCKETBASE_DIR}/pocketbase"
    
    # Clean up
    rm "/tmp/${POCKETBASE_ARCHIVE}"
    
    print_success "PocketBase downloaded and extracted"
else
    print_status "PocketBase binary already exists"
fi

# Install Flutter dependencies
print_status "Installing Flutter dependencies..."
flutter pub get

if [[ $? -eq 0 ]]; then
    print_success "Flutter dependencies installed"
else
    print_error "Failed to install Flutter dependencies"
    exit 1
fi

# Generate code (for json_serializable, etc.)
print_status "Generating Dart code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

if [[ $? -eq 0 ]]; then
    print_success "Code generation completed"
else
    print_warning "Code generation had issues (this might be normal if no generators are configured yet)"
fi

# Flutter doctor check
print_status "Running Flutter doctor..."
flutter doctor -v

# Create development scripts
print_status "Creating development helper scripts..."

# Create run-pocketbase.sh script
cat > scripts/run-pocketbase.sh << 'EOF'
#!/bin/bash
# Start PocketBase server for development

echo "🗄️  Starting PocketBase server..."

# Load environment variables
if [[ -f ".env" ]]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set default admin credentials if not provided
ADMIN_EMAIL=${POCKETBASE_ADMIN_EMAIL:-"admin@pulse.com"}
ADMIN_PASSWORD=${POCKETBASE_ADMIN_PASSWORD:-"admin123456"}

echo "Admin Email: $ADMIN_EMAIL"
echo "Admin Password: [HIDDEN]"
echo ""
echo "🌐 PocketBase Admin UI will be available at: http://localhost:8090/_/"
echo "📡 API Base URL: http://localhost:8090/api/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start PocketBase with auto-create admin
cd pocketbase
./pocketbase serve --http=0.0.0.0:8090 \
  --encryptionEnv=PB_ENCRYPTION_KEY \
  --dev
EOF

chmod +x scripts/run-pocketbase.sh

# Create run-flutter.sh script
cat > scripts/run-flutter.sh << 'EOF'
#!/bin/bash
# Start Flutter development server

echo "📱 Starting Flutter development server..."

# Check which device to run on
DEVICE_ARG=""
if [[ "$1" == "web" ]]; then
    DEVICE_ARG="-d chrome"
    echo "Running on Web (Chrome)"
elif [[ "$1" == "ios" ]]; then
    DEVICE_ARG="-d ios"
    echo "Running on iOS Simulator"
elif [[ "$1" == "android" ]]; then
    DEVICE_ARG="-d android"
    echo "Running on Android Emulator"
else
    echo "Running on default device"
    echo "Usage: $0 [web|ios|android]"
fi

# Run Flutter
flutter run $DEVICE_ARG --hot
EOF

chmod +x scripts/run-flutter.sh

# Create development startup script
cat > scripts/start-development.sh << 'EOF'
#!/bin/bash
# Start complete development environment

echo "🚀 Starting Pulse Trading Signals development environment..."

# Check if PocketBase is already running
if lsof -i :8090 >/dev/null 2>&1; then
    echo "⚠️  PocketBase appears to be already running on port 8090"
    echo "   Stop it first or use a different port"
    exit 1
fi

echo ""
echo "This will start:"
echo "  1. PocketBase backend server (port 8090)"
echo "  2. Flutter development server"
echo ""
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Start PocketBase in the background
echo "🗄️  Starting PocketBase server..."
./scripts/run-pocketbase.sh &
POCKETBASE_PID=$!

# Wait a moment for PocketBase to start
sleep 3

# Check if PocketBase started successfully
if ! lsof -i :8090 >/dev/null 2>&1; then
    echo "❌ Failed to start PocketBase server"
    exit 1
fi

echo "✅ PocketBase server started (PID: $POCKETBASE_PID)"
echo ""

# Start Flutter
echo "📱 Starting Flutter development server..."
./scripts/run-flutter.sh

# Clean up: Kill PocketBase when script exits
trap "echo '🛑 Stopping PocketBase server...'; kill $POCKETBASE_PID 2>/dev/null" EXIT
EOF

chmod +x scripts/start-development.sh

print_success "Development helper scripts created"

# Create setup validation script
print_status "Creating setup validation..."

cat > scripts/validate-setup.sh << 'EOF'
#!/bin/bash
# Validate development setup

echo "🔍 Validating Pulse Trading Signals setup..."

ERRORS=0

# Check Flutter installation
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: $(flutter --version | head -1)"
else
    echo "❌ Flutter: Not installed"
    ERRORS=$((ERRORS + 1))
fi

# Check if .env exists
if [[ -f ".env" ]]; then
    echo "✅ Environment: .env file exists"
else
    echo "❌ Environment: .env file missing"
    ERRORS=$((ERRORS + 1))
fi

# Check PocketBase binary
if [[ -f "pocketbase/pocketbase" ]]; then
    POCKETBASE_VERSION=$(./pocketbase/pocketbase version 2>/dev/null | head -1 || echo "unknown")
    echo "✅ PocketBase: $POCKETBASE_VERSION"
else
    echo "❌ PocketBase: Binary not found"
    ERRORS=$((ERRORS + 1))
fi

# Check Flutter dependencies
if [[ -f "pubspec.lock" ]]; then
    echo "✅ Dependencies: Flutter packages installed"
else
    echo "❌ Dependencies: Run 'flutter pub get'"
    ERRORS=$((ERRORS + 1))
fi

# Check for common issues
echo ""
echo "🔍 System checks:"

# Check if required ports are available
if lsof -i :8090 >/dev/null 2>&1; then
    echo "⚠️  Port 8090: In use (stop other services using this port)"
else
    echo "✅ Port 8090: Available"
fi

if lsof -i :3000 >/dev/null 2>&1; then
    echo "⚠️  Port 3000: In use (might conflict with Flutter web)"
else
    echo "✅ Port 3000: Available"
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "🎉 Setup validation passed! You're ready to develop."
    echo ""
    echo "Next steps:"
    echo "  1. Edit .env file with your API keys"
    echo "  2. Run: ./scripts/start-development.sh"
    echo "  3. Visit http://localhost:8090/_/ to set up PocketBase admin"
else
    echo "❌ Setup validation failed with $ERRORS errors"
    echo "Please fix the issues above before continuing"
    exit 1
fi
EOF

chmod +x scripts/validate-setup.sh

print_success "Setup validation script created"

# Final setup completion
print_success "Development environment setup completed! 🎉"

echo ""
print_status "📋 What was set up:"
echo "  ✅ PocketBase backend server (v${POCKETBASE_VERSION})"
echo "  ✅ Flutter dependencies installed"
echo "  ✅ Environment configuration (.env file)"
echo "  ✅ Development helper scripts"
echo ""

print_status "📝 Next steps:"
echo "  1. Edit .env file with your actual API keys:"
echo "     - Alpaca API keys for market data"
echo "     - Google/Apple OAuth credentials (optional)"
echo "     - Firebase configuration (optional)"
echo ""
echo "  2. Validate your setup:"
echo "     ./scripts/validate-setup.sh"
echo ""
echo "  3. Start development environment:"
echo "     ./scripts/start-development.sh"
echo ""
echo "  4. Access PocketBase admin panel:"
echo "     http://localhost:8090/_/"
echo ""

print_status "🔗 Useful links:"
echo "  - PocketBase docs: https://pocketbase.io/docs/"
echo "  - Flutter docs: https://docs.flutter.dev/"
echo "  - Alpaca API docs: https://alpaca.markets/docs/"
echo ""

print_warning "⚠️  Important: Make sure to configure your .env file before running the application!"

echo ""
print_success "Setup complete! Happy coding! 🚀"