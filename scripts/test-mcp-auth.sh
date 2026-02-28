#!/bin/bash
# Local MCP Device Authorization Test Script
# This script helps test the OAuth 2.0 Device Authorization flow locally

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "🔐 MCP Device Authorization Test Setup"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_prereq() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ $1 found${NC}"
    return 0
}

echo "Checking prerequisites..."
check_prereq "go" || exit 1
check_prereq "node" || exit 1
check_prereq "npm" || exit 1

# Check MongoDB
echo -n "Checking MongoDB... "
if docker ps --filter name=mongo 2>/dev/null | grep -q mongo; then
    echo -e "${GREEN}✓ Docker MongoDB running${NC}"
elif mongod --version &>/dev/null && pgrep mongod &>/dev/null; then
    echo -e "${GREEN}✓ Local MongoDB running${NC}"
else
    echo -e "${YELLOW}⚠️  MongoDB not running${NC}"
    echo "Starting MongoDB with Docker..."
    docker run -d --name mongodb-test -p 27017:27017 mongo:latest 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "📋 Test Instructions"
echo "=========================================="
echo ""
echo "You need 3 terminal windows:"
echo ""
echo "Terminal 1 - Backend:"
echo "  cd $PROJECT_ROOT/backend"
echo "  cp .env.test .env"
echo "  go run cmd/server/main.go"
echo ""
echo "Terminal 2 - Frontend:"
echo "  cd $PROJECT_ROOT/frontend"
echo "  npm run dev"
echo ""
echo "Terminal 3 - MCP Client:"
echo "  cd $PROJECT_ROOT/backend/mcp-bridge"
echo "  ./bin/mcp-client login"
echo ""
echo "=========================================="
echo "🔧 Quick Commands"
echo "=========================================="
echo ""
echo "# Build MCP Client (if not built):"
echo "cd $PROJECT_ROOT/backend/mcp-bridge && go build -o bin/mcp-client ./cmd/mcp-client"
echo ""
echo "# Test login flow:"
echo "$PROJECT_ROOT/backend/mcp-bridge/bin/mcp-client login --no-browser"
echo ""
echo "# Check status:"
echo "$PROJECT_ROOT/backend/mcp-bridge/bin/mcp-client status"
echo ""
echo "# List devices:"
echo "$PROJECT_ROOT/backend/mcp-bridge/bin/mcp-client devices list"
echo ""
