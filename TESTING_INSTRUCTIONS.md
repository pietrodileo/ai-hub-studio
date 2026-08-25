# Testing My First Agent - End-to-End Starter

## Overview
This document provides instructions for testing the My First Agent implementation in IRIS AI Hub Studio.

## Prerequisites
- IRIS AI Hub Docker container running
- REST API accessible at `http://localhost:52773/api`

## Test Methods

### Method 1: Manual Testing with .http File
1. Open `test_starter_manual.http` in VS Code with the REST Client extension
2. Execute each request sequentially
3. Verify responses are correct

### Method 2: Automated Test Script
```bash
cd backend
node test_starter.js
```

### Method 3: Direct API Testing

#### 1. Get the Starter Guide
```bash
curl http://localhost:52773/api/starter/guide
```

#### 2. Get Available Templates
```bash
curl http://localhost:52773/api/starter/templates
```

#### 3. Get Specific Template
```bash
curl http://localhost:52773/api/starter/templates/hello_world
```

#### 4. Get Example Conversation
```bash
curl http://localhost:52773/api/starter/conversation/hello_world
```

#### 5. Create Agent from Template
```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "templateName": "hello_world",
    "agentName": "My First Agent",
    "description": "Created via starter guide"
}' http://localhost:52773/api/starter/create
```

#### 6. Verify Agent Creation
```bash
curl http://localhost:52773/api/agents/{agentId}
```

## Expected Results

### Starter Guide
- Should return a JSON object with:
  - Title and description
  - 5-step guide
  - List of available templates

### Templates
- Should return 3 templates:
  - Hello World Agent
  - Weather Bot
  - Math Helper

### Agent Creation
- Should return a success response with agentId
- Agent should be registered in the system
- Agent class should be created
- Required skills and tools should be registered

## Verification Steps
1. Check that all API endpoints return 200 OK status
2. Verify response data structure matches expected format
3. Confirm agent appears in the agent registry
4. Test agent functionality through the agent API

## Sample Test Flow
1. Get starter guide → Understand the process
2. Browse templates → Choose "Hello World Agent"
3. View example conversation → See expected behavior
4. Create agent → Get agent ID
5. Test agent → Verify it works
6. Enhance agent → Add skills/tools