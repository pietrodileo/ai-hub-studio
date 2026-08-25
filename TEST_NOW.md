# Testing My First Agent Implementation

## Prerequisites
Before testing, ensure you have:

1. **IRIS AI Hub Docker container running**
2. **REST API accessible** at `http://localhost:52773/api`
3. **jq installed** for JSON processing (optional, for pretty output)

## Testing Methods

### Method 1: Run the Automated Test Script
```bash
# Make sure you're in the project directory
cd "/Users/pietrodileo/Documents/Projects/InterSystems/Bounty Program/July-August 2026"

# Run the test script
./test_my_first_agent.sh
```

### Method 2: Manual Testing with curl

#### 1. Get the Starter Guide
```bash
curl http://localhost:52773/api/starter/guide | jq .
```

#### 2. Get Available Templates
```bash
curl http://localhost:52773/api/starter/templates | jq .
```

#### 3. Get Specific Template
```bash
curl http://localhost:52773/api/starter/templates/hello_world | jq .
```

#### 4. Get Example Conversation
```bash
curl http://localhost:52773/api/starter/conversation/hello_world | jq .
```

#### 5. Create Agent from Template
```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "templateName": "hello_world",
    "agentName": "My Test Agent",
    "description": "Test agent created via API"
}' http://localhost:52773/api/starter/create | jq .
```

#### 6. Send Message to Agent
```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "message": "Hello there!"
}' http://localhost:52773/api/agents/{agentId}/message | jq .
```

### Method 3: VS Code REST Client
1. Open `test_starter_manual.http` in VS Code
2. Install the REST Client extension if needed
3. Execute each request sequentially

## Expected Results

### Starter Guide
```json
{
  "title": "My First Agent - End-to-End Starter Guide",
  "description": "A guided experience to help you create your first AI agent...",
  "steps": [5 steps],
  "templates": [3 templates]
}
```

### Agent Creation
```json
{
  "agentId": "1",
  "status": "success",
  "message": "Agent created successfully"
}
```

### Agent Message
```json
{
  "agentId": "1",
  "message": "Hello there!",
  "response": "Hello there! How can I help you today?",
  "timestamp": "..."
}
```

## Troubleshooting

**If tests fail:**
1. Verify IRIS container is running: `docker ps`
2. Check port mapping: `docker port <container_name>`
3. Verify REST application is configured in IRIS
4. Check IRIS logs for errors: `docker logs <container_name>`

## Next Steps
After successful testing:
1. **Implement MCP Data Exposure Toolkit** - Next bounty feature
2. **Implement Generic Agent Test UI** - Comprehensive testing interface
3. **Enhance agent capabilities** - Add more tools and skills
4. **Create frontend components** - Build UI for the starter guide