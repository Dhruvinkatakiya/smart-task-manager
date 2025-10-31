#!/bin/bash
###############################################################################
# Comprehensive API Testing Script
# Tests all endpoints with proper flow and validation
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="${BASE_URL:-http://localhost}"
TEST_EMAIL="test_$(date +%s)@example.com"
TEST_PASSWORD="SecurePass123"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Smart Task Manager - API Testing Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Base URL: ${YELLOW}$BASE_URL${NC}"
echo -e "Test Email: ${YELLOW}$TEST_EMAIL${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_code=$5
    local headers=$6
    
    echo -n "Testing: $name... "
    
    local response
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $headers \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $headers)
    fi
    
    local body=$(echo "$response" | sed '$d')
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $status_code)"
        ((TESTS_PASSED++))
        echo "$body"
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_code, got $status_code)"
        ((TESTS_FAILED++))
        echo "$body"
    fi
    echo ""
}

# Extract value from JSON response
extract_json() {
    local json=$1
    local key=$2
    echo "$json" | grep -o "\"$key\":\"[^\"]*\"" | sed "s/\"$key\":\"\([^\"]*\)\"/\1/"
}

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  1. AUTH SERVICE TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Test 1: Health check
test_endpoint "Auth Service Health" "GET" "/api/auth/" "" "200" ""

# Test 2: Register user
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"Test User\",\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

echo "Testing: User Registration... "
if echo "$REGISTER_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
    TOKEN=$(extract_json "$REGISTER_RESPONSE" "token")
    USER_ID=$(extract_json "$REGISTER_RESPONSE" "_id")
    echo "Token: ${TOKEN:0:20}..."
    echo "User ID: $USER_ID"
else
    echo -e "${RED}✗ FAIL${NC}"
    ((TESTS_FAILED++))
    echo "$REGISTER_RESPONSE"
fi
echo ""

# Test 3: Login
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

echo "Testing: User Login... "
if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
    TOKEN=$(extract_json "$LOGIN_RESPONSE" "token")
else
    echo -e "${RED}✗ FAIL${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 4: Get current user
test_endpoint "Get Current User" "GET" "/api/auth/me" "" "200" "-H \"Authorization: Bearer $TOKEN\""

# Test 5: Invalid login
test_endpoint "Invalid Login (Should Fail)" "POST" "/api/auth/login" \
    "{\"email\":\"$TEST_EMAIL\",\"password\":\"wrongpassword\"}" "401" ""

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  2. BOARD SERVICE TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Test 6: Create board
CREATE_BOARD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/boards" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"name\":\"Test Board\",\"description\":\"Testing board creation\"}")

echo "Testing: Create Board... "
if echo "$CREATE_BOARD_RESPONSE" | grep -q "_id"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
    BOARD_ID=$(extract_json "$CREATE_BOARD_RESPONSE" "_id")
    echo "Board ID: $BOARD_ID"
else
    echo -e "${RED}✗ FAIL${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 7: Get all boards
test_endpoint "Get All Boards" "GET" "/api/boards" "" "200" "-H \"Authorization: Bearer $TOKEN\""

# Test 8: Get specific board
if [ -n "$BOARD_ID" ]; then
    test_endpoint "Get Specific Board" "GET" "/api/boards/$BOARD_ID" "" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Test 9: Update board
if [ -n "$BOARD_ID" ]; then
    test_endpoint "Update Board" "PUT" "/api/boards/$BOARD_ID" \
        "{\"name\":\"Updated Board\",\"description\":\"Updated description\"}" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  3. TASK SERVICE TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Test 10: Create task
CREATE_TASK_RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"title\":\"Test Task\",\"description\":\"Testing task creation\",\"status\":\"todo\",\"boardId\":\"$BOARD_ID\"}")

echo "Testing: Create Task... "
if echo "$CREATE_TASK_RESPONSE" | grep -q "_id"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
    TASK_ID=$(extract_json "$CREATE_TASK_RESPONSE" "_id")
    echo "Task ID: $TASK_ID"
else
    echo -e "${RED}✗ FAIL${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# Test 11: Get all tasks
test_endpoint "Get All Tasks" "GET" "/api/tasks" "" "200" "-H \"Authorization: Bearer $TOKEN\""

# Test 12: Get tasks by board
if [ -n "$BOARD_ID" ]; then
    test_endpoint "Get Tasks by Board" "GET" "/api/tasks?boardId=$BOARD_ID" "" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Test 13: Get specific task
if [ -n "$TASK_ID" ]; then
    test_endpoint "Get Specific Task" "GET" "/api/tasks/$TASK_ID" "" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Test 14: Update task
if [ -n "$TASK_ID" ]; then
    test_endpoint "Update Task Status" "PUT" "/api/tasks/$TASK_ID" \
        "{\"status\":\"in-progress\"}" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Test 15: Update task again
if [ -n "$TASK_ID" ]; then
    test_endpoint "Update Task to Done" "PUT" "/api/tasks/$TASK_ID" \
        "{\"status\":\"done\",\"title\":\"Completed Task\"}" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  4. CLEANUP & NEGATIVE TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Test 16: Unauthorized access
test_endpoint "Unauthorized Access (Should Fail)" "GET" "/api/boards" "" "401" ""

# Test 17: Invalid token
test_endpoint "Invalid Token (Should Fail)" "GET" "/api/tasks" "" "401" "-H \"Authorization: Bearer invalid_token\""

# Test 18: Delete task
if [ -n "$TASK_ID" ]; then
    test_endpoint "Delete Task" "DELETE" "/api/tasks/$TASK_ID" "" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Test 19: Delete board
if [ -n "$BOARD_ID" ]; then
    test_endpoint "Delete Board" "DELETE" "/api/boards/$BOARD_ID" "" "200" "-H \"Authorization: Bearer $TOKEN\""
fi

# Final Report
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  TEST SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo ""
    exit 1
fi
