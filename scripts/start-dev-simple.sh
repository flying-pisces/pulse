#!/bin/bash

# Simple development startup script for Pulse Trading Signals
# This starts PocketBase and gives instructions for Flutter

set -e

echo "🚀 Starting Pulse Development Environment"
echo ""

# Check if we're in the right directory
if [[ ! -f "pubspec.yaml" ]]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check if .env file exists
if [[ ! -f ".env" ]]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    if [[ -f ".env.example" ]]; then
        cp .env.example .env
        echo "✅ Created .env file"
        echo ""
        echo "📝 Please edit .env file with your API keys before running the app:"
        echo "   - POCKETBASE_URL (default: http://localhost:8090)"
        echo "   - ALPACA_API_KEY and ALPACA_SECRET_KEY (optional for testing)"
        echo "   - Other API keys as needed"
        echo ""
    else
        echo "❌ .env.example file not found"
        exit 1
    fi
fi

# Check if PocketBase binary exists
if [[ ! -f "pocketbase/pocketbase" ]]; then
    echo "❌ PocketBase binary not found"
    echo "Please run: ./scripts/setup-development.sh"
    exit 1
fi

# Kill any existing PocketBase process
if lsof -ti :8090 >/dev/null 2>&1; then
    echo "🛑 Stopping existing PocketBase process on port 8090..."
    lsof -ti :8090 | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# Start PocketBase
echo "🗄️  Starting PocketBase server..."
echo ""

cd pocketbase

# Set admin credentials (edit these as needed)
ADMIN_EMAIL="admin@pulse.com"
ADMIN_PASSWORD="admin123456"

echo "📊 PocketBase Information:"
echo "  🌐 Admin UI: http://localhost:8090/_/"
echo "  📡 API Base: http://localhost:8090/api/"
echo "  👤 Admin Email: $ADMIN_EMAIL"
echo "  🔑 Admin Password: [See .env file]"
echo ""
echo "🔧 To run Flutter app, open a new terminal and run:"
echo "  flutter run -d chrome    # For web development"
echo "  flutter run -d macos     # For macOS app"
echo "  flutter run              # For connected device"
echo ""
echo "Press Ctrl+C to stop PocketBase server"
echo ""

# Start PocketBase with development settings
./pocketbase serve --http=0.0.0.0:8090 --dev