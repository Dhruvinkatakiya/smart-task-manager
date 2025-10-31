#!/bin/bash

# Smart Task Manager - Public URL Setup with Ngrok
# This exposes the entire full-stack application on a public URL

echo "🌐 Setting up public URL for Smart Task Manager..."
echo "=================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo -e "${RED}❌ ngrok is not installed!${NC}"
    echo -e "${YELLOW}Please install ngrok:${NC}"
    echo "  1. Visit: https://ngrok.com/download"
    echo "  2. Or use: brew install ngrok"
    exit 1
fi

# Check if ngrok is authenticated
if ! ngrok config check &> /dev/null; then
    echo -e "${YELLOW}⚠️  ngrok is not authenticated${NC}"
    echo -e "${BLUE}Please authenticate ngrok:${NC}"
    echo "  1. Visit: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "  2. Copy your authtoken"
    echo "  3. Run: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

# Check if port 9090 is in use (nginx should be running)
if ! lsof -i :9090 > /dev/null 2>&1; then
    echo -e "${RED}❌ Nginx is not running on port 9090!${NC}"
    echo -e "${YELLOW}Please start your application first:${NC}"
    echo "  ./start-fullstack.sh"
    exit 1
fi

echo -e "${GREEN}✓ All checks passed!${NC}"
echo -e "\n${BLUE}Starting ngrok tunnel for full-stack application...${NC}"
echo -e "${YELLOW}Exposing: http://localhost:9090 (Nginx Proxy)${NC}\n"

# Start ngrok
echo -e "${GREEN}=================================================="
echo -e "🚀 NGROK TUNNEL ACTIVE"
echo -e "==================================================${NC}\n"

ngrok http 9090 \
  --log=stdout \
  --log-level=info \
  --region=us

# Note: This will run until you press Ctrl+C
