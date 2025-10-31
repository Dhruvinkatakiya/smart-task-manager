#!/bin/bash
###############################################################################
# Ngrok Tunnel Setup Script for Smart Task Manager
# Exposes local Kubernetes services to public internet for testing/demo
###############################################################################

set -e

echo "========================================="
echo "Smart Task Manager - Public Access Setup"
echo "========================================="
echo ""

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "ERROR: ngrok is not installed"
    echo "Install ngrok:"
    echo "   macOS: brew install ngrok/ngrok/ngrok"
    echo "   Linux: snap install ngrok"
    echo "   Or visit: https://ngrok.com/download"
    exit 1
fi

echo "Step 1: Setting up port forwarding for Kubernetes services..."
echo "-----------------------------------------------------------"

# Kill any existing port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

# Start port forwarding for all services
echo "  - Forwarding auth-service (8000:80)..."
kubectl port-forward -n default svc/auth-service 8000:80 > /dev/null 2>&1 &
AUTH_PID=$!

echo "  - Forwarding task-service (5001:80)..."
kubectl port-forward -n default svc/task-service 5001:80 > /dev/null 2>&1 &
TASK_PID=$!

echo "  - Forwarding board-service (8002:80)..."
kubectl port-forward -n default svc/board-service 8002:80 > /dev/null 2>&1 &
BOARD_PID=$!

# Wait for port forwards to be ready
sleep 3

# Verify services are accessible
echo ""
echo "Step 2: Verifying local services..."
echo "-----------------------------------------------------------"
if curl -s http://localhost:8000/api/auth/ > /dev/null 2>&1; then
    echo "  ✓ Auth service accessible at http://localhost:8000"
else
    echo "  ✗ Auth service not responding"
fi

if curl -s http://localhost:5001/ > /dev/null 2>&1; then
    echo "  ✓ Task service accessible at http://localhost:5001"
else
    echo "  ✗ Task service not responding"
fi

if curl -s http://localhost:8002/ > /dev/null 2>&1; then
    echo "  ✓ Board service accessible at http://localhost:8002"
else
    echo "  ✗ Board service not responding"
fi

echo ""
echo "Step 3: Starting nginx reverse proxy..."
echo "-----------------------------------------------------------"

# Start nginx with custom config if available
if [ -f "nginx-proxy.conf" ]; then
    nginx -c "$(pwd)/nginx-proxy.conf" -g "daemon off;" > /dev/null 2>&1 &
    NGINX_PID=$!
    echo "  ✓ Nginx proxy started on port 9090"
    NGROK_PORT=9090
else
    echo "  ! nginx-proxy.conf not found, using auth-service directly"
    NGROK_PORT=8000
fi

sleep 2

echo ""
echo "Step 4: Starting ngrok tunnel..."
echo "-----------------------------------------------------------"
echo "  Dashboard: http://localhost:4040"
echo ""
echo "IMPORTANT: Press Ctrl+C to stop all services"
echo "==========================================="
echo ""

# Start ngrok tunnel
ngrok http $NGROK_PORT --log=stdout

# Get public URL
PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'https://[^"]*' | head -1)

if [ -n "$PUBLIC_URL" ]; then
    echo ""
    echo "🎉 PUBLIC URL: $PUBLIC_URL"
    echo ""
    echo "🔗 Test endpoints:"
    echo "   Auth Service:  $PUBLIC_URL/api/auth"
    echo "   Task Service:  $PUBLIC_URL/api/tasks"
    echo "   Board Service: $PUBLIC_URL/api/boards"
    echo ""
    echo "📋 Sample cURL commands:"
    echo ""
    echo "# Register user:"
    echo "curl -X POST $PUBLIC_URL/api/auth/register \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -d '{\"name\":\"demo\",\"email\":\"demo@test.com\",\"password\":\"pass123\"}'"
    echo ""
    echo "Press Ctrl+C to stop ngrok tunnel"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Save URL to file for CI/CD
    echo "$PUBLIC_URL" > .ngrok_url
    
    # Keep running
    wait $NGROK_PID
else
    echo "❌ Failed to get ngrok public URL"
    echo "Check logs at /tmp/ngrok.log"
    kill $NGROK_PID 2>/dev/null || true
    exit 1
fi
