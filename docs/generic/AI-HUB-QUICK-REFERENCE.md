# 📖 AI Hub Quick Reference Guide

**Project**: IRIS AI Hub Studio - Bounty Program Round 2  
**Purpose**: Quick lookup for AI Hub development  
**Based on**: Official InterSystems AI Hub EAP Documentation  

---

## 🎯 Quick Start

### 1. Create a Basic Agent

```objectscript
Class MyApp.MyAgent Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "MyAgent" ];
    Property Description As %String [ InitialExpression = "My first AI agent" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..SystemPrompt = "You are a helpful assistant."
        Set ..Model = "gpt-4"
        Quit ##super()
    }
}

// Use the agent
Set agent = ##class(MyApp.MyAgent).%New()
Set response = agent.Chat("Hello!")
Write response
```

### 2. Add a Tool to Agent

```objectscript
// Tool class
Class MyApp.Tools.Calculator Extends %AI.Agent.Tool
{
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        Quit {"result": input.a + input.b}
    }
}

// Add to agent
Set agent = ##class(MyApp.MyAgent).%New()
Do agent.AddTool("Calculator", "MyApp.Tools.Calculator")
```

### 3. Create MCP Server

```objectscript
Class MyApp.MCP.MyServer Extends %AI.MCP.Server
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Do ..AddConnector(##class(MyApp.MCP.GlobalConnector).%New("^MyData"))
        Quit ##super()
    }
}
```

---

## 🧩 Core Classes

### Agent Framework

| Class | Purpose | Key Methods |
|-------|---------|--------------|
| `%AI.Agent` | Base agent class | `Chat()`, `AddTool()`, `AddSkill()` |
| `%AI.Agent.Manager` | Agent management | `RegisterAgent()`, `GetAgent()` |
| `%AI.Agent.Conversation` | Conversation state | `AddMessage()`, `GetHistory()` |

### Tool System

| Class | Purpose | Key Methods |
|-------|---------|--------------|
| `%AI.Agent.Tool` | Base tool class | `Execute()`, `ValidateInput()` |
| `%AI.Agent.Tool.HTTP` | HTTP requests | `Execute()` (overridden) |
| `%AI.Agent.Tool.SQL` | SQL queries | `Execute()` (overridden) |
| `%AI.Agent.Tool.Global` | Global access | `Execute()` (overridden) |

### Skill System

| Class | Purpose | Key Methods |
|-------|---------|--------------|
| `%AI.Agent.Skill` | Base skill class | `ShouldTrigger()`, `Execute()` |
| `%AI.Agent.Skill.Extract` | Data extraction | `Execute()` (overridden) |
| `%AI.Agent.Skill.Transform` | Response transformation | `Execute()` (overridden) |

### MCP Integration

| Class | Purpose | Key Methods |
|-------|---------|--------------|
| `%AI.MCP.Server` | MCP server | `Start()`, `Stop()`, `HandleRequest()` |
| `%AI.MCP.Connector` | Data connector | `Initialize()`, `HandleRequest()` |
| `%AI.MCP.Client` | MCP client | `Connect()`, `CallTool()`, `ReadResource()` |
| `%AI.MCP.Resource` | MCP resource | `GetContent()` |

---

## 🔧 Common Patterns

### Agent with Tools and Skills

```objectscript
Class MyApp.SmartAgent Extends %AI.Agent
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Configure agent
        Set ..Name = "SmartAgent"
        Set ..Model = "gpt-4"
        Set ..SystemPrompt = "You are a smart assistant with access to tools."
        
        // Add tools
        Do ..AddTool("Calculator", "MyApp.Tools.Calculator")
        Do ..AddTool("WebSearch", "MyApp.Tools.WebSearch")
        
        // Add skills
        Do ..AddSkill("MathHelper", "MyApp.Skills.MathHelper")
        
        Quit ##super()
    }
}
```

### Stateful Tool

```objectscript
Class MyApp.Tools.DataCollector Extends %AI.Agent.Tool
{
    Property CollectedData As %DynamicObject;
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..CollectedData = {}
        Quit ##super()
    }
    
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        If input.action = "add" {
            Set ..CollectedData(input.key) = input.value
            Quit {"status": "added", "count": ..CollectedData.Count()}
        }
        
        If input.action = "get" {
            Quit {"data": ..CollectedData}
        }
        
        Quit {"error": "Unknown action"}
    }
}
```

### MCP Server with Global Connector

```objectscript
Class MyApp.MCP.DataServer Extends %AI.MCP.Server
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Add global connector
        Set connector = ##class(%AI.MCP.Connector.Global).%New()
        Set connector.GlobalName = "^MyApp.Data"
        Do ..AddConnector(connector)
        
        // Add resource
        Set resource = ##class(%AI.MCP.Resource).%New()
        Set resource.URI = "data://myapp"
        Set resource.Name = "MyApp Data"
        Do ..AddResource(resource)
        
        Quit ##super()
    }
}
```

---

## 📡 API Reference

### REST API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/aihub/v1/agents` | List all agents |
| GET | `/aihub/v1/agents/{id}` | Get agent details |
| POST | `/aihub/v1/agents/{id}/chat` | Chat with agent |
| POST | `/aihub/v1/agents/{id}/chat/stream` | Stream chat |
| GET | `/aihub/v1/tools` | List all tools |
| POST | `/aihub/v1/tools/{id}/execute` | Execute tool |
| GET | `/aihub/v1/mcp/servers` | List MCP servers |
| GET | `/aihub/v1/mcp/servers/{id}/resources` | List resources |

### WebSocket API

**URL**: `ws://localhost:53773/aihub/v1/chat`

**Message Types**:
- `authenticate` - Authenticate with JWT token
- `conversation/start` - Start a new conversation
- `message/send` - Send a message
- `message/received` - Receive agent response
- `message/chunk` - Streaming response chunk
- `tool/call` - Tool execution notification
- `tool/result` - Tool execution result
- `error` - Error notification

---

## 🎯 Agent Configuration

### Properties

```objectscript
Set agent.Name = "MyAgent"
Set agent.Description = "My agent description"
Set agent.Model = "gpt-4"  // or "claude-3", etc.
Set agent.SystemPrompt = "You are a helpful assistant."
Set agent.Temperature = 0.7  // 0-2
Set agent.MaxTokens = 4000
```

### Methods

```objectscript
// Chat
Set response = agent.Chat("Hello!")

// Chat with conversation
Set response = agent.Chat("Hello!", "conv123")

// Chat with context
Set response = agent.Chat("Hello!", "conv123", {"userId": "user1"})

// Stream chat
Set status = agent.ChatStream("Hello!", , "conv123")

// Add tool
Do agent.AddTool("ToolName", "ToolClass")

// Add skill
Do agent.AddSkill("SkillName", "SkillClass")

// Execute tool directly
Set result = agent.ExecuteTool("ToolName", {"param": "value"})

// Get/Set state
Set state = agent.GetState()
Do agent.SetState({"key": "value"})
Do agent.UpdateState({"key": "newValue"})

// Create sub-agent
Set subAgent = agent.CreateSubAgent("SubAgentClass")
```

---

## 🛠️ Tool Configuration

### Properties

```objectscript
Set tool.Name = "MyTool"
Set tool.Description = "Tool description"
Set tool.Schema = {"type": "object", "properties": {...}}
Set tool.Timeout = 30  // seconds
Set tool.MaxRetries = 3
```

### Methods

```objectscript
// Execute tool
Set result = tool.Execute({"param": "value"})

// Validate input
Set validation = tool.ValidateInput({"param": "value"})

// State management
Set state = tool.GetState()
Do tool.SetState({"key": "value"})
Do tool.UpdateState({"key": "newValue"})
```

---

## 🔌 MCP Server Configuration

### Properties

```objectscript
Set server.Name = "MyServer"
Set server.Description = "Server description"
Set server.Version = "2024-11-05"
Set server.Capabilities = $ListFromString("tools", "resources")
```

### Methods

```objectscript
// Add connector
Do server.AddConnector(connector)

// Add tool
Do server.AddTool(tool)

// Add resource
Do server.AddResource(resource)

// Start/Stop server
Do server.Start()
Do server.Stop()

// Handle request
Set response = server.HandleRequest(request)
```

---

## 💾 State Management

### Conversation State

```objectscript
// Create conversation
Set conversation = ##class(%AI.Agent.Conversation).%New()
Set conversation.ConversationId = "conv123"
Set conversation.AgentId = "MyAgent"

// Add message
Do conversation.AddMessage("user", "Hello!")
Do conversation.AddMessage("assistant", "Hi there!")

// Get history
Set history = conversation.GetHistory()
Set recent = conversation.GetHistory(5)  // Last 5 messages

// Context management
Set context = conversation.GetContext()
Do conversation.UpdateContext({"key": "value"})
```

### State Persistence

```objectscript
// Save conversation
Set status = ##class(%AI.Agent.StateManager).SaveConversation(conversation)

// Load conversation
Set conversation = ##class(%AI.Agent.StateManager).LoadConversation("conv123")

// Delete conversation
Set status = ##class(%AI.Agent.StateManager).DeleteConversation("conv123")

// List conversations
Set conversations = ##class(%AI.Agent.StateManager).ListConversations()
```

---

## 📝 Configuration File

```json
{
  "agents": {
    "MyAgent": {
      "class": "MyApp.MyAgent",
      "model": "gpt-4",
      "temperature": 0.7,
      "maxTokens": 4000,
      "systemPrompt": "You are a helpful assistant.",
      "tools": ["Calculator", "WebSearch"],
      "skills": ["MathHelper"]
    }
  },
  "models": {
    "gpt-4": {
      "provider": "openai",
      "apiKey": "${OPENAI_API_KEY}",
      "baseUrl": "https://api.openai.com/v1",
      "timeout": 60
    }
  },
  "mcp": {
    "servers": {
      "DataServer": {
        "class": "MyApp.MCP.DataServer",
        "connectors": [
          {"type": "global", "globalName": "^MyData"}
        ]
      }
    }
  }
}
```

---

## 🚀 Common Tasks

### 1. Create Agent with Tools

```objectscript
Class MyApp.AgentWithTools Extends %AI.Agent
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Name = "AgentWithTools"
        Set ..Model = "gpt-4"
        
        // Add tools
        Do ..AddTool("Calculator", "MyApp.Tools.Calculator")
        Do ..AddTool("DataQuery", "MyApp.Tools.DataQuery")
        
        Quit ##super()
    }
}
```

### 2. Create Stateful Tool

```objectscript
Class MyApp.Tools.Counter Extends %AI.Agent.Tool
{
    Property Count As %Integer;
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..Count = 0
        Set ..Schema = {
            "type": "object",
            "properties": {
                "action": {"type": "string", "enum": ["increment", "decrement", "get", "reset"]}
            },
            "required": ["action"]
        }
        Quit ##super()
    }
    
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        If input.action = "increment" {
            Set ..Count = ..Count + 1
            Quit {"count": ..Count}
        }
        
        If input.action = "decrement" {
            Set ..Count = ..Count - 1
            Quit {"count": ..Count}
        }
        
        If input.action = "get" {
            Quit {"count": ..Count}
        }
        
        If input.action = "reset" {
            Set ..Count = 0
            Quit {"count": ..Count}
        }
        
        Quit {"error": "Unknown action"}
    }
}
```

### 3. Create MCP Server for SQL Data

```objectscript
Class MyApp.MCP.SQLServer Extends %AI.MCP.Server
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set connector = ##class(%AI.MCP.Connector.SQL).%New()
        Set connector.Namespace = "USER"
        Set connector.TableName = "MyApp.MyTable"
        Do ..AddConnector(connector)
        
        Quit ##super()
    }
}
```

### 4. Create Agent with Sub-Agents

```objectscript
Class MyApp.ParentAgent Extends %AI.Agent
{
    Method HandleComplexTask(task As %String) As %String
    {
        // Create sub-agent
        Set subAgent = ..CreateSubAgent("MyApp.ResearchAgent")
        
        // Configure sub-agent
        Do subAgent.SetConfig({"task": task})
        
        // Delegate task
        Set result = subAgent.Chat(task)
        
        // Process result
        Quit "Based on research: " _ result
    }
}
```

### 5. REST API Chat

```bash
# Chat with agent
curl -X POST http://localhost:52773/aihub/v1/agents/MyAgent/chat \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!", "conversationId": "conv123"}'

# Execute tool
curl -X POST http://localhost:52773/aihub/v1/tools/Calculator/execute \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"input": {"a": 5, "b": 3}}'
```

### 6. WebSocket Chat

```javascript
const socket = new WebSocket('ws://localhost:53773/aihub/v1/chat');

socket.onopen = () => {
    socket.send(JSON.stringify({
        type: 'authenticate',
        token: 'your-token'
    }));
};

socket.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('Received:', data);
};

// Start conversation
socket.send(JSON.stringify({
    type: 'conversation/start',
    agentId: 'MyAgent',
    conversationId: 'conv123'
}));

// Send message
socket.send(JSON.stringify({
    type: 'message/send',
    conversationId: 'conv123',
    message: 'Hello!'
}));
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Agent not found | Class not extending %AI.Agent | Extend %AI.Agent |
| Tool execution failed | Input validation error | Check input against schema |
| MCP server not responding | Server not started | Call server.Start() |
| State not persisted | State manager not configured | Configure state manager |
| Authentication failed | Invalid token | Check JWT token |
| Connection timeout | Network issue | Check network connectivity |

### Debug Commands

```objectscript
// Enable debug logging
Set config = ##class(%AI.Agent.Config).%New()
Set config.LogLevel = "debug"
Do config.Save()

// Inspect agent state
Write $Method(%JSON.Encoder, "Encode", agent.GetState())

// List all agents
Set agents = ##class(%AI.Agent.Manager).ListAgents()
Write $Method(%JSON.Encoder, "Encode", agents)

// Test MCP connection
Set client = ##class(%AI.MCP.Client).%New()
Set status = client.Connect("http://localhost:8080/mcp")
```

---

## 📚 Key Concepts

### 1. Agents
- **Purpose**: AI entities that can chat, use tools, and have skills
- **Lifecycle**: Created → Configured → Used → Destroyed
- **State**: Maintain conversation context and agent-specific state

### 2. Tools
- **Purpose**: Reusable functions that agents can call
- **Types**: HTTP, SQL, Global, Custom
- **State**: Can be stateful or stateless
- **Validation**: Input validation against schema

### 3. Skills
- **Purpose**: Specialized capabilities that modify agent behavior
- **Triggers**: Activated based on conversation context
- **Execution**: Run before/after agent response
- **State**: Can maintain state across invocations

### 4. MCP Servers
- **Purpose**: Expose data and tools via Model Context Protocol
- **Connectors**: Bridge between IRIS data and MCP
- **Resources**: Data sources exposed via MCP
- **Tools**: Functions exposed via MCP

### 5. State Management
- **Conversation State**: Message history and context
- **Agent State**: Agent-specific persistent state
- **Tool State**: Tool-specific state
- **Persistence**: Save/load state to/from storage

---

## 🎯 Development Checklist

### Agent Development
- [ ] Extend %AI.Agent
- [ ] Set Name, Description, Model
- [ ] Configure SystemPrompt
- [ ] Add tools with AddTool()
- [ ] Add skills with AddSkill()
- [ ] Test with Chat()

### Tool Development
- [ ] Extend %AI.Agent.Tool
- [ ] Implement Execute() method
- [ ] Define input schema
- [ ] Add to agent with AddTool()
- [ ] Test execution

### Skill Development
- [ ] Extend %AI.Agent.Skill
- [ ] Define triggers
- [ ] Implement Execute() method
- [ ] Add to agent with AddSkill()
- [ ] Test triggering

### MCP Server Development
- [ ] Extend %AI.MCP.Server
- [ ] Add connectors
- [ ] Add resources
- [ ] Add tools
- [ ] Start server
- [ ] Test connectivity

---

## 🔗 Quick Links

### Official Documentation
- [AI Hub GitHub](https://github.com/intersystems-community/ai-hub-eap/tree/master)
- [Part 1: Agents](https://community.intersystems.com/post/introduction-ai-hub-part-1-agents-objectscript)
- [Part 2: MCP Servers](https://community.intersystems.com/post/introduction-ai-hub-part-2-custom-mcp-servers)
- [Part 3: Stateful Tools](https://community.intersystems.com/post/intro-ai-hub-part-3-stateful-tools)

### Community
- [Developer Community](https://community.intersystems.com/)
- [Open Exchange](https://openexchange.intersystems.com/)

---

## 📝 Notes

- **All classes extend from %AI.Agent, %AI.Agent.Tool, or %AI.MCP.Server**
- **Tools must implement Execute() method**
- **Skills must implement ShouldTrigger() and Execute() methods**
- **MCP servers must implement HandleRequest() method**
- **State is automatically managed but can be customized**
- **Configuration can be done via code or JSON config files**

---

**Document Information**
- **Version**: 1.0
- **Purpose**: Quick reference for AI Hub development
- **Based on**: Official InterSystems AI Hub EAP Documentation
- **Status**: Ready for development phase