#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Store the auth token
TOKEN=""

echo "Starting API Tests..."
echo "---------------------------------"

# Test Auth Service (8000)
echo "Testing Auth Service..."

# 1. Register User
echo "1. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test2@example.com", "password": "Test123!"}')

if echo "$REGISTER_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ Registration successful${NC}"
else
    echo -e "${RED}✗ Registration failed${NC}"
    echo "$REGISTER_RESPONSE"
fi

# 2. Login
echo -e "\n2. Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test2@example.com", "password": "Test123!"}')

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ Login successful${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
else
    echo -e "${RED}✗ Login failed${NC}"
    echo "$LOGIN_RESPONSE"
fi

# Test Board Service (8002)
echo -e "\nTesting Board Service..."

# 3. Create Board
echo "3. Testing Board Creation..."
BOARD_RESPONSE=$(curl -s -X POST http://localhost:8002/api/boards \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "Test Board", "description": "Test Board Description"}')

if echo "$BOARD_RESPONSE" | grep -q "_id"; then
    echo -e "${GREEN}✓ Board creation successful${NC}"
    BOARD_ID=$(echo "$BOARD_RESPONSE" | sed -n 's/.*"_id":"\([^"]*\)".*/\1/p')
else
    echo -e "${RED}✗ Board creation failed${NC}"
    echo "$BOARD_RESPONSE"
fi

# 4. Get Boards
echo -e "\n4. Testing Get Boards..."
GET_BOARDS_RESPONSE=$(curl -s -X GET http://localhost:8002/api/boards \
  -H "Authorization: Bearer $TOKEN")

if echo "$GET_BOARDS_RESPONSE" | grep -q "\[\|{"; then
    echo -e "${GREEN}✓ Get boards successful${NC}"
else
    echo -e "${RED}✗ Get boards failed${NC}"
    echo "$GET_BOARDS_RESPONSE"
fi

# Test Task Service (8001)
echo -e "\nTesting Task Service..."

# 5. Create Task
echo "5. Testing Task Creation..."
TASK_RESPONSE=$(curl -s -X POST http://localhost:8001/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"title\": \"Test Task\", \"description\": \"Test Task Description\", \"boardId\": \"$BOARD_ID\", \"status\": \"TODO\"}")

if echo "$TASK_RESPONSE" | grep -q "_id"; then
    echo -e "${GREEN}✓ Task creation successful${NC}"
    TASK_ID=$(echo "$TASK_RESPONSE" | sed -n 's/.*"_id":"\([^"]*\)".*/\1/p')
else
    echo -e "${RED}✗ Task creation failed${NC}"
    echo "$TASK_RESPONSE"
fi

# 6. Get Tasks for Board
echo -e "\n6. Testing Get Tasks for Board..."
GET_TASKS_RESPONSE=$(curl -s -X GET "http://localhost:8001/api/tasks?boardId=$BOARD_ID" \
  -H "Authorization: Bearer $TOKEN")

if echo "$GET_TASKS_RESPONSE" | grep -q "\[\|{"; then
    echo -e "${GREEN}✓ Get tasks successful${NC}"
else
    echo -e "${RED}✗ Get tasks failed${NC}"
    echo "$GET_TASKS_RESPONSE"
fi

# 7. Update Task Status
echo -e "\n7. Testing Task Status Update..."
UPDATE_TASK_RESPONSE=$(curl -s -X PATCH "http://localhost:8001/api/tasks/$TASK_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"status": "IN_PROGRESS"}')

if echo "$UPDATE_TASK_RESPONSE" | grep -q "_id"; then
    echo -e "${GREEN}✓ Task update successful${NC}"
else
    echo -e "${RED}✗ Task update failed${NC}"
    echo "$UPDATE_TASK_RESPONSE"
fi

# 8. Delete Task
echo -e "\n8. Testing Task Deletion..."
DELETE_TASK_RESPONSE=$(curl -s -X DELETE "http://localhost:8001/api/tasks/$TASK_ID" \
  -H "Authorization: Bearer $TOKEN")

if [ -z "$DELETE_TASK_RESPONSE" ] || echo "$DELETE_TASK_RESPONSE" | grep -q "success\|deleted"; then
    echo -e "${GREEN}✓ Task deletion successful${NC}"
else
    echo -e "${RED}✗ Task deletion failed${NC}"
    echo "$DELETE_TASK_RESPONSE"
fi

# 9. Delete Board
echo -e "\n9. Testing Board Deletion..."
DELETE_BOARD_RESPONSE=$(curl -s -X DELETE "http://localhost:8002/api/boards/$BOARD_ID" \
  -H "Authorization: Bearer $TOKEN")

if [ -z "$DELETE_BOARD_RESPONSE" ] || echo "$DELETE_BOARD_RESPONSE" | grep -q "success\|deleted"; then
    echo -e "${GREEN}✓ Board deletion successful${NC}"
else
    echo -e "${RED}✗ Board deletion failed${NC}"
    echo "$DELETE_BOARD_RESPONSE"
fi

echo -e "\n---------------------------------"
echo "API Tests Complete"