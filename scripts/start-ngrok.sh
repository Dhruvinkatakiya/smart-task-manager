#!/bin/bash
###############################################################################
# Quick Ngrok Setup - Copy and paste these commands one by one
###############################################################################

# STEP 1: Get your ngrok authtoken
# Visit: https://dashboard.ngrok.com/get-started/your-authtoken
# Copy your token and run:
# ngrok authtoken YOUR_TOKEN_HERE

# STEP 2: Start ngrok tunnel
ngrok http 8000

# That's it! 
# You'll see output like:
#   Forwarding  https://xxxx-xx-xx.ngrok-free.app -> http://localhost:8000
#
# Copy the HTTPS URL and use it to access your application!

###############################################################################
# TESTING YOUR PUBLIC URL
###############################################################################

# Replace YOUR_NGROK_URL with the URL from ngrok output

# Test 1: Health Check
# curl https://YOUR_NGROK_URL/api/auth/

# Test 2: Register User
# curl -X POST https://YOUR_NGROK_URL/api/auth/register \
#   -H "Content-Type: application/json" \
#   -d '{"email":"demo@test.com","password":"demo123"}'

# Test 3: Login
# curl -X POST https://YOUR_NGROK_URL/api/auth/login \
#   -H "Content-Type: application/json" \
#   -d '{"email":"demo@test.com","password":"demo123"}'

# Copy the JWT token from login response and use it below:

# Test 4: Create Task
# curl -X POST https://YOUR_NGROK_URL/api/tasks \
#   -H "Content-Type: application/json" \
#   -H "Authorization: Bearer YOUR_JWT_TOKEN" \
#   -d '{"title":"Public Task","description":"Created via ngrok","status":"todo"}'
