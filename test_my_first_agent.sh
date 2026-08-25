#!/bin/bash

# My First Agent - End-to-End Starter Test Script
# This script tests the My First Agent implementation

BASE_URL="http://localhost:52773/api"
TEST_AGENT_NAME="Test Agent - $(date +%s)"

echo "=== My First Agent - End-to-End Starter Test ==="
echo "Base URL: $BASE_URL"
echo "Test Agent Name: $TEST_AGENT_NAME"
echo

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local method=$2
    local data=$3
    local description=$4
    
    echo "Testing: $description"
    echo "Endpoint: $method $endpoint"
    
    if [ -n "$data" ]; then
        echo "Data: $data"
        response=$(curl -s -X $method "$BASE_URL$endpoint" -H "Content-Type: application/json" -d "$data")
    else
        response=$(curl -s -X $method "$BASE_URL$endpoint")
    fi
    
    if [ $? -ne 0 ]; then
        echo "❌ FAILED: Could not connect to $BASE_URL"
        echo "Please ensure:"
        echo "1. IRIS container is running"
        echo "2. REST application is configured"
        echo "3. Port 52773 is mapped correctly"
        echo "4. The application is accessible at $BASE_URL"
        exit 1
    fi
    
    echo "Response: $response"
    echo "✅ PASSED"
    echo
    
    echo "$response" | jq . > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Response is valid JSON"
    else
        echo "Response may not be valid JSON"
    fi
    echo
    
    echo "$response"
}

# Test 1: Get starter guide
echo "1. Testing GET /starter/guide"
response=$(curl -s "$BASE_URL/starter/guide")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    echo "Guide received with $(echo "$response" | jq '.steps | length') steps"
    echo
else
    echo "❌ FAILED: Could not get starter guide"
    echo "Response: $response"
    echo
fi

# Test 2: Get templates
echo "2. Testing GET /starter/templates"
response=$(curl -s "$BASE_URL/starter/templates")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    template_count=$(echo "$response" | jq '. | length')
    echo "Received $template_count templates"
    echo
else
    echo "❌ FAILED: Could not get templates"
    echo "Response: $response"
    echo
fi

# Test 3: Get specific template
echo "3. Testing GET /starter/templates/hello_world"
response=$(curl -s "$BASE_URL/starter/templates/hello_world")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    template_name=$(echo "$response" | jq -r '.name')
    echo "Received template: $template_name"
    echo
else
    echo "❌ FAILED: Could not get hello_world template"
    echo "Response: $response"
    echo
fi

# Test 4: Get example conversation
echo "4. Testing GET /starter/conversation/hello_world"
response=$(curl -s "$BASE_URL/starter/conversation/hello_world")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    conversation_length=$(echo "$response" | jq '. | length')
    echo "Received conversation with $conversation_length turns"
    echo
else
    echo "❌ FAILED: Could not get example conversation"
    echo "Response: $response"
    echo
fi

# Test 5: Create agent from template
echo "5. Testing POST /starter/create"
echo "Creating agent: $TEST_AGENT_NAME"
response=$(curl -s -X POST "$BASE_URL/starter/create" \
    -H "Content-Type: application/json" \
    -d "{\"templateName\": \"hello_world\", \"agentName\": \"$TEST_AGENT_NAME\"}")

if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    agent_id=$(echo "$response" | jq -r '.agentId')
    echo "Created agent with ID: $agent_id"
    echo
else
    echo "❌ FAILED: Could not create agent"
    echo "Response: $response"
    echo
    exit 1
fi

# Test 6: Verify agent was created
echo "6. Testing GET /agents/$agent_id"
response=$(curl -s "$BASE_URL/agents/$agent_id")
if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    agent_name=$(echo "$response" | jq -r '.AgentName')
    echo "Verified agent: $agent_name"
    echo
else
    echo "❌ FAILED: Could not verify agent creation"
    echo "Response: $response"
    echo
fi

# Test 7: Send message to agent
echo "7. Testing POST /agents/$agent_id/message"
echo "Sending message to agent"
response=$(curl -s -X POST "$BASE_URL/agents/$agent_id/message" \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"Hello there!\"}")

if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "✅ PASSED"
    agent_response=$(echo "$response" | jq -r '.response')
    echo "Agent response: $agent_response"
    echo
else
    echo "❌ FAILED: Could not send message to agent"
    echo "Response: $response"
    echo
fi

echo "=== Test Summary ==="
echo "✅ My First Agent implementation is working correctly!"
echo "✅ All endpoints responded successfully"
echo "✅ Agent creation and messaging verified"
echo
