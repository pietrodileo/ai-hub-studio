# 🔬 AI Hub Research & Discovery Document

**Project**: IRIS AI Hub Studio - Unified Platform for Bounty Program Round 2  
**Date**: July 2026  
**Status**: Research Phase  
**Author**: AI Assistant for Pietro Dileo

---

## 🎯 Research Objectives

1. **Discover** the actual implementation of AI Hub in IRIS
2. **Document** all available classes, methods, and APIs
3. **Create** working examples for each component
4. **Validate** our unified platform architecture

---

## 📋 Current Knowledge (Based on Bounty Description)

### Expected AI Hub Components

#### 1. %AI.Agent Framework
- **Purpose**: Base class for creating AI agents
- **Expected Features**:
  - Conversation management
  - Tool registration and execution
  - Skill system
  - Sub-agent support
  - Multi-model capabilities

#### 2. %AI.MCP Package
- **Purpose**: Model Context Protocol integration
- **Expected Features**:
  - MCP server registration
  - Data exposure (Globals, SQL, DocDB)
  - Security controls
  - Agent access to external data

#### 3. AI Hub Services
- **Expected Features**:
  - Agent discovery
  - Configuration management
  - REST/WebSocket APIs
  - Authentication and authorization

---

## 🔍 Research Tasks

### Phase 1: Environment Setup (Priority: HIGH)
- [ ] Set up IRIS community container with AI Hub
- [ ] Verify AI Hub package installation
- [ ] Discover available namespaces and classes

### Phase 2: Class Discovery (Priority: HIGH)
- [ ] Explore %AI package structure
- [ ] Document %AI.Agent class hierarchy
- [ ] Discover %AI.MCP classes
- [ ] Find utility classes and APIs

### Phase 3: API Documentation (Priority: HIGH)
- [ ] Document agent creation and management APIs
- [ ] Document tool registration and execution
- [ ] Document skill system
- [ ] Document MCP server registration
- [ ] Document data exposure APIs

### Phase 4: Example Creation (Priority: MEDIUM)
- [ ] Create minimal %AI.Agent subclass
- [ ] Implement basic tool
- [ ] Register and use MCP server
- [ ] Expose sample data via MCP

---

## 📁 Expected Class Structure (Hypotheses)

### %AI.Agent Package
```
%AI.Agent
├── %AI.Agent.cls                  # Base agent class
├── %AI.Agent.Manager.cls          # Agent management
├── %AI.Agent.Conversation.cls     # Conversation handling
├── %AI.Agent.Tool.cls              # Base tool class
├── %AI.Agent.Skill.cls             # Base skill class
└── %AI.Agent.Config.cls            # Configuration
```

### %AI.MCP Package
```
%AI.MCP
├── %AI.MCP.Server.cls              # MCP server base class
├── %AI.MCP.Bridge.cls              # IRIS-MCP bridge
├── %AI.MCP.Connector.cls           # Base connector
├── %AI.MCP.GlobalConnector.cls     # Global data connector
├── %AI.MCP.SQLConnector.cls        # SQL data connector
├── %AI.MCP.DocDBConnector.cls      # Document database connector
└── %AI.MCP.Security.cls            # Security controls
```

### %AI REST API
```
/AI/v1
├── /agents                        # Agent management
│   ├── GET    /list                # List available agents
│   ├── POST   /create              # Create new agent
│   ├── GET    /{id}                # Get agent details
│   └── POST   /{id}/chat           # Chat with agent
├── /tools                         # Tool management
│   ├── GET    /list                # List available tools
│   └── POST   /execute             # Execute tool
├── /mcp                           # MCP management
│   ├── GET    /servers             # List MCP servers
│   └── POST   /register            # Register MCP server
└── /config                        # Configuration
    └── GET    /                    # Get current configuration
```

---

## 🧪 Research Methodology

### 1. Class Discovery Commands
```objectscript
// List all %AI classes
Do ##class(%Library.Routine).List("%AI.*")

// Examine %AI.Agent class
Do ##class(%Dictionary.ClassDefinition).Open("%AI.Agent").View()

// List all methods of %AI.Agent
Set class = ##class(%Dictionary.ClassDefinition).Open("%AI.Agent")
Do class.Methods.Display()

// List all properties of %AI.Agent
Do class.Properties.Display()
```

### 2. Package Discovery
```objectscript
// Check if %AI package exists
Write $System.OBJ.CheckClassExists("%AI.Agent")

// List all packages
Do $System.OBJ.ListPackages()

// Check ZPM for AI Hub
ZPM "search AI"
```

### 3. API Discovery
```objectscript
// Check REST API endpoints
Set api = ##class(%Net.HTTPRequest).%New()
Set api.Server = "localhost"
Set api.Port = 52773
Set api.Https = 0
Set api.ContentType = "application/json"

// Try to access AI Hub API
Set response = api.Get("/AI/v1/agents/list")
Write response.Data
```

---

## 📝 Discovery Template

### Class: %AI.Agent

**Package**: %AI  
**Extends**: %RegisteredObject (hypothesis)  
**Purpose**: Base class for AI agents

#### Properties
| Property | Type | Description | Required |
|----------|------|-------------|----------|
| Name | %String | Agent name | Yes |
| Description | %String | Agent description | No |
| Model | %String | LLM model to use | Yes |
| SystemPrompt | %String | System prompt for agent | No |
| Tools | %List | List of available tools | No |
| Skills | %List | List of available skills | No |
| Config | %DynamicObject | Agent configuration | No |

#### Methods
| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| %OnNew() |  | %Status | Constructor |
| Chat() | message: %String, conversationId: %String | %String | Send message to agent |
| AddTool() | toolName: %String, toolClass: %String | %Status | Add tool to agent |
| AddSkill() | skillName: %String, skillClass: %String | %Status | Add skill to agent |
| CreateSubAgent() | agentClass: %String, config: %DynamicObject | %AI.Agent | Create sub-agent |

#### Example Usage
```objectscript
// Create a new agent class
Class MyApp.MyAgent Extends %AI.Agent
{
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Set agent properties
        Set ..Name = "MyAgent"
        Set ..Description = "My first AI agent"
        Set ..Model = "gpt-4"
        Set ..SystemPrompt = "You are a helpful assistant..."
        
        // Add tools
        Do ..AddTool("FileTool", "MyApp.FileTool")
        Do ..AddTool("CalcTool", "MyApp.CalcTool")
        
        // Add skills
        Do ..AddSkill("WebSearch", "MyApp.WebSearchSkill")
        
        Quit $$$OK
    }
}

// Use the agent
Set agent = ##class(MyApp.MyAgent).%New()
Set response = agent.Chat("What is the capital of France?")
Write response
```

---

## 🎯 Next Steps

### Immediate Actions
1. **Set up IRIS environment** with AI Hub
2. **Run discovery commands** to document actual implementation
3. **Validate hypotheses** against real implementation
4. **Create working examples** for each component

### Research Priorities
1. **%AI.Agent class** - Core of our platform
2. **Tool system** - Essential for agent functionality
3. **MCP integration** - Key for data exposure
4. **REST/WebSocket APIs** - For frontend integration

---

## 📚 Resources to Investigate

### Official Documentation
- [ ] InterSystems AI Hub documentation
- [ ] %AI.Agent class reference
- [ ] %AI.MCP package documentation
- [ ] AI Hub API documentation

### Community Resources
- [ ] InterSystems Developer Community posts
- [ ] GitHub repositories with AI Hub examples
- [ ] Open Exchange applications using AI Hub
- [ ] DCN (Developer Community Network) discussions

### Example Projects
- [ ] Official AI Hub samples
- [ ] Community-created agents
- [ ] MCP server examples for IRIS

---

## 🔗 Useful Commands for Discovery

### In IRIS Terminal
```objectscript
// List all classes in %AI package
Do $System.OBJ.Inspect("%AI", .classes)
ZWrite classes

// Get class definition
Set def = ##class(%Dictionary.ClassDefinition).Open("%AI.Agent")
Do def.ExportToStream(.stream)
Do stream.OutputToFile("AI.Agent.cls")

// List all methods with signatures
Set class = ##class(%Dictionary.ClassDefinition).Open("%AI.Agent")
For i=1:1:class.Methods.Count() {
    Set method = class.Methods.GetAt(i)
    Write !, method.Name, "("
    For j=1:1:method.Parameters.Count() {
        Set param = method.Parameters.GetAt(j)
        Write param.Name, ":", param.Type
        If j < method.Parameters.Count() { Write ", " }
    }
    Write ") : ", method.ReturnType
}
```

### Using ZPM
```objectscript
// Search for AI-related packages
ZPM "search AI"

// Install AI Hub (if available)
ZPM "install ai-hub"

// List installed modules
ZPM "list"
```

---

## 📝 Research Findings (To Be Filled)

### %AI.Agent Class
- **Actual Package**: 
- **Actual Extends**: 
- **Key Properties**: 
- **Key Methods**: 
- **Configuration**: 

### %AI.MCP Package
- **Available Classes**: 
- **Server Registration**: 
- **Data Connectors**: 
- **Security**: 

### REST API
- **Base URL**: 
- **Authentication**: 
- **Endpoints**: 
- **WebSocket**: 

### WebSocket API
- **Connection**: 
- **Message Format**: 
- **Events**: 

---

## 🎓 Learning Checklist

- [ ] Understand %AI.Agent class hierarchy
- [ ] Create minimal working agent
- [ ] Implement and register a tool
- [ ] Add a skill to an agent
- [ ] Create a sub-agent
- [ ] Set up MCP server
- [ ] Expose global data via MCP
- [ ] Expose SQL data via MCP
- [ ] Use exposed data in an agent
- [ ] Connect to agent via REST API
- [ ] Connect to agent via WebSocket

---

## 🚀 Action Plan

### Week 1: Environment & Discovery
- [ ] Set up IRIS with AI Hub
- [ ] Document all %AI classes
- [ ] Create first working agent
- [ ] Document tool system

### Week 2: MCP & Integration
- [ ] Set up MCP server
- [ ] Expose sample data
- [ ] Document MCP APIs
- [ ] Create agent using MCP data

### Week 3: Platform Foundation
- [ ] Build Agent Test UI prototype
- [ ] Create MCP Toolkit prototype
- [ ] Build Starter Agent template
- [ ] Test integration between components

---

**Status**: Ready for research execution  
**Next Step**: Set up IRIS environment and begin class discovery  
**Owner**: Pietro Dileo + AI Assistant