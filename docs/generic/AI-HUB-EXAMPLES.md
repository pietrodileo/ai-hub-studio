# 🎓 AI Hub Practical Examples & Learning Guide

**Project**: IRIS AI Hub Studio  
**Purpose**: Hands-on examples to learn AI Hub implementation  
**Status**: Draft - To be validated against actual IRIS AI Hub

---

## 📚 Table of Contents

1. [Getting Started with AI Hub](#-getting-started-with-ai-hub)
2. [Creating Your First Agent](#-creating-your-first-agent)
3. [Working with Tools](#-working-with-tools)
4. [Using Skills](#-using-skills)
5. [MCP Data Exposure](#-mcp-data-exposure)
6. [Agent Communication](#-agent-communication)
7. [Sub-Agents](#-sub-agents)
8. [Multi-Model Support](#-multi-model-support)

---

## 🚀 Getting Started with AI Hub

### Prerequisites
```bash
# Start IRIS container with AI Hub
docker run -d --name iris-ai-hub \
  -p 52773:52773 \
  -p 53773:53773 \
  intersystemsdc/iris-community:latest

# Access IRIS terminal
docker exec -it iris-ai-hub iris session iris
```

### Verify AI Hub Installation
```objectscript
// Check if AI Hub is installed
Write $System.OBJ.CheckClassExists("%AI.Agent")

// List all %AI classes
Do ##class(%Library.Routine).List("%AI.*")

// Check version
Write ##class(%AI.Agent).Version()
```

---

## 🤖 Creating Your First Agent

### Minimal Agent Class
```objectscript
/// MyApp.MyFirstAgent.cls
Class MyApp.MyFirstAgent Extends %AI.Agent
{
    /// Agent name
    Property Name As %String [ InitialExpression = "MyFirstAgent" ];
    
    /// Agent description
    Property Description As %String [ InitialExpression = "My first AI agent for testing" ];
    
    /// System prompt
    Property SystemPrompt As %String [ InitialExpression = "You are a helpful AI assistant. Be concise and accurate." ];
    
    /// Model to use
    Property Model As %String [ InitialExpression = "gpt-4" ];
    
    /// Initialize agent
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Call parent constructor
        Quit ##super()
    }
    
    /// Custom initialization
    Method Initialize() As %Status
    {
        // Set up agent configuration
        Set ..Name = "MyFirstAgent"
        Set ..Description = "My first AI agent"
        Set ..SystemPrompt = "You are a helpful assistant..."
        Set ..Model = "gpt-4"
        
        // Add any initial tools or skills
        // Do ..AddTool("ToolName", "ToolClass")
        // Do ..AddSkill("SkillName", "SkillClass")
        
        Quit $$$OK
    }
}
```

### Register Agent
```objectscript
// Register the agent with AI Hub
Set agent = ##class(MyApp.MyFirstAgent).%New()
Set status = agent.Initialize()
If $$$ISERR(status) {
    Write "Error initializing agent: ", $System.Status.GetErrorText(status)
    Quit
}

// Register with manager (hypothesized API)
Set manager = ##class(%AI.Agent.Manager).%New()
Set regStatus = manager.RegisterAgent(agent)
If $$$ISERR(regStatus) {
    Write "Error registering agent: ", $System.Status.GetErrorText(regStatus)
    Quit
}

Write "Agent registered successfully!"
```

---

## 🛠️ Working with Tools

### Creating a Tool
```objectscript
/// MyApp.Tools.Calculator.cls
Class MyApp.Tools.Calculator Extends %AI.Agent.Tool
{
    /// Tool name
    Property Name As %String [ InitialExpression = "Calculator" ];
    
    /// Tool description
    Property Description As %String [ InitialExpression = "Performs mathematical calculations" ];
    
    /// Tool schema (for validation)
    Property Schema As %DynamicObject;
    
    /// Initialize tool
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Define tool schema
        Set ..Schema = {
            "type": "object",
            "properties": {
                "operation": {"type": "string", "enum": ["add", "subtract", "multiply", "divide"]},
                "a": {"type": "number"},
                "b": {"type": "number"}
            },
            "required": ["operation", "a", "b"]
        }
        Quit ##super()
    }
    
    /// Execute the tool
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        Set operation = input.operation
        Set a = input.a
        Set b = input.b
        Set result = 0
        
        If operation = "add" {
            Set result = a + b
        } Else If operation = "subtract" {
            Set result = a - b
        } Else If operation = "multiply" {
            Set result = a * b
        } Else If operation = "divide" {
            If b = 0 {
                Quit {"error": "Division by zero"}
            }
            Set result = a / b
        }
        
        Quit {"result": result, "operation": operation, "a": a, "b": b}
    }
}
```

### Adding Tool to Agent
```objectscript
// Create agent
Set agent = ##class(MyApp.MyFirstAgent).%New()

// Create and add calculator tool
Set calculator = ##class(MyApp.Tools.Calculator).%New()
Set status = agent.AddTool(calculator)
If $$$ISERR(status) {
    Write "Error adding tool: ", $System.Status.GetErrorText(status)
    Quit
}

// Or add by class name
Set status = agent.AddTool("Calculator", "MyApp.Tools.Calculator")
```

### Using Tool in Agent
```objectscript
// Agent automatically uses tools when appropriate
// The agent's Chat method will call tools as needed

Set agent = ##class(MyApp.MyFirstAgent).%New()
Set response = agent.Chat("What is 5 + 3?")
Write response
// Expected: The agent will use the Calculator tool and return 8
```

---

## 🧠 Using Skills

### Creating a Skill
```objectscript
/// MyApp.Skills.WebSearch.cls
Class MyApp.Skills.WebSearch Extends %AI.Agent.Skill
{
    /// Skill name
    Property Name As %String [ InitialExpression = "WebSearch" ];
    
    /// Skill description
    Property Description As %String [ InitialExpression = "Searches the web for information" ];
    
    /// Skill triggers (when to activate)
    Property Triggers As %List [ MultiDimensional ];
    
    /// Initialize skill
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Set up triggers
        Do ..Triggers.SetAt("search", "user mentions 'search', 'find', 'look up'")
        Do ..Triggers.SetAt("web", "user mentions 'web', 'internet', 'online'")
        Quit ##super()
    }
    
    /// Execute skill logic
    Method Execute(context As %DynamicObject) As %DynamicObject
    {
        // context contains:
        // - message: user message
        // - agent: reference to agent
        // - conversation: conversation history
        
        Set query = context.message
        
        // In a real implementation, this would call a web search API
        // For now, return mock data
        Set results = {
            "query": query,
            "results": [
                {"title": "Result 1", "url": "https://example.com/1", "snippet": "Relevant information..."},
                {"title": "Result 2", "url": "https://example.com/2", "snippet": "More relevant information..."}
            ]
        }
        
        Quit results
    }
}
```

### Adding Skill to Agent
```objectscript
Set agent = ##class(MyApp.MyFirstAgent).%New()
Set webSearch = ##class(MyApp.Skills.WebSearch).%New()
Set status = agent.AddSkill(webSearch)
```

---

## 🔌 MCP Data Exposure

### Setting Up MCP Server
```objectscript
/// MyApp.MCP.IrisDataServer.cls
Class MyApp.MCP.IrisDataServer Extends %AI.MCP.Server
{
    /// Server name
    Property Name As %String [ InitialExpression = "IrisDataServer" ];
    
    /// Server description
    Property Description As %String [ InitialExpression = "Exposes IRIS data via MCP" ];
    
    /// Initialize server
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Register data connectors
        Set connector = ##class(MyApp.MCP.GlobalConnector).%New()
        Do ..AddConnector(connector)
        
        Quit ##super()
    }
    
    /// Handle MCP requests
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        // Route request to appropriate connector
        Set connectorName = request.connector
        Set connector = ..GetConnector(connectorName)
        
        If connector = "" {
            Quit {"error": "Connector not found"}
        }
        
        Quit connector.HandleRequest(request)
    }
}
```

### Global Data Connector
```objectscript
/// MyApp.MCP.GlobalConnector.cls
Class MyApp.MCP.GlobalConnector Extends %AI.MCP.Connector
{
    /// Connector name
    Property Name As %String [ InitialExpression = "GlobalConnector" ];
    
    /// Supported global
    Property GlobalName As %String;
    
    /// Initialize connector
    Method %OnNew(globalName As %String) As %Status [ CodeMode = objectgenerator ]
    {
        Set ..GlobalName = globalName
        Quit ##super()
    }
    
    /// Handle data request
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        Set action = request.action
        Set subscripts = request.subscripts
        
        If action = "read" {
            // Read from global
            Set value = $Get(@(..GlobalName _ "("_ $ListToString(subscripts, ",") _ ")"))
            Quit {"action": "read", "value": value, "subscripts": subscripts}
        }
        
        If action = "list" {
            // List subscripts
            Set subscript = $Order(@(..GlobalName _ "("_ $ListToString(subscripts, ",") _ ")"),1)
            Set results = []
            While subscript '= "" {
                Do results.Push(subscript)
                Set subscript = $Order(@(..GlobalName _ "("_ $ListToString(subscripts, ",") _ "," _ subscript _ ")"),1)
            }
            Quit {"action": "list", "subscripts": results}
        }
        
        Quit {"error": "Unknown action: " _ action}
    }
}
```

### Registering MCP Server
```objectscript
// Create and register MCP server
Set server = ##class(MyApp.MCP.IrisDataServer).%New()

// Add global connector for specific global
Set globalConnector = ##class(MyApp.MCP.GlobalConnector).%New("^MyData")
Do server.AddConnector(globalConnector)

// Register server with MCP manager
Set mcpManager = ##class(%AI.MCP.Manager).%New()
Set status = mcpManager.RegisterServer(server)
```

---

## 💬 Agent Communication

### REST API Examples

#### List Available Agents
```bash
curl -X GET http://localhost:52773/AI/v1/agents/list \
  -H "Content-Type: application/json"
```

#### Chat with Agent
```bash
curl -X POST http://localhost:52773/AI/v1/agents/MyFirstAgent/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?", "conversationId": "conv123"}'
```

#### Execute Tool Directly
```bash
curl -X POST http://localhost:52773/AI/v1/tools/Calculator/execute \
  -H "Content-Type: application/json" \
  -d '{"operation": "add", "a": 5, "b": 3}'
```

### WebSocket API Examples

#### Connect to Agent
```javascript
const socket = new WebSocket('ws://localhost:53773/AI/v1/agents/MyFirstAgent/chat');

socket.onopen = () => {
    socket.send(JSON.stringify({
        action: "start",
        conversationId: "conv123"
    }));
};

socket.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('Agent response:', data);
};

// Send message
socket.send(JSON.stringify({
    action: "message",
    message: "What is 5 + 3?",
    conversationId: "conv123"
}));
```

---

## 🤖 Sub-Agents

### Creating Sub-Agent
```objectscript
/// MyApp.Agents.ResearchAgent.cls
Class MyApp.Agents.ResearchAgent Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "ResearchAgent" ];
    Property Description As %String [ InitialExpression = "Specialized agent for research tasks" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..SystemPrompt = "You are a research assistant. Provide detailed, well-researched answers."
        Quit ##super()
    }
}

/// In main agent
Method HandleComplexQuery(query As %String) As %String
{
    // Create sub-agent for research
    Set researchAgent = ..CreateSubAgent("MyApp.Agents.ResearchAgent")
    
    // Delegate research task
    Set researchResult = researchAgent.Chat(query)
    
    // Process result and provide final answer
    Set finalAnswer = "Based on research: " _ researchResult
    
    Quit finalAnswer
}
```

### Sub-Agent with Tools
```objectscript
// Main agent creates sub-agent with specific tools
Set subAgent = agent.CreateSubAgent("MyApp.Agents.ResearchAgent")

// Add tools to sub-agent
Set status = subAgent.AddTool("WebSearch", "MyApp.Tools.WebSearch")
Set status = subAgent.AddTool("Database", "MyApp.Tools.Database")

// Sub-agent inherits some tools from parent
Set status = subAgent.InheritToolsFromParent()
```

---

## 🌐 Multi-Model Support

### Model Configuration
```objectscript
// Configure agent with multiple models
Set agent = ##class(MyApp.MyFirstAgent).%New()

// Set primary model
Set agent.Model = "gpt-4"

// Add fallback models
Do agent.AddModel("gpt-3.5-turbo", 1)  // Priority 1
Do agent.AddModel("claude-3", 2)       // Priority 2

// Model selection strategy
Set agent.ModelSelection = "auto"  // or "manual", "fallback"
```

### Model-Specific Configuration
```objectscript
// Configure different models for different tasks
Set agent.ModelConfig = {
    "gpt-4": {
        "temperature": 0.7,
        "max_tokens": 4000,
        "cost_per_token": 0.03
    },
    "gpt-3.5-turbo": {
        "temperature": 0.9,
        "max_tokens": 2000,
        "cost_per_token": 0.0015
    }
}
```

---

## 📝 Complete Agent Example

### MyApp.Agents.DataAnalyst.cls
```objectscript
/// Complete agent with tools, skills, and MCP integration
Class MyApp.Agents.DataAnalyst Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "DataAnalyst" ];
    Property Description As %String [ InitialExpression = "Analyzes data from IRIS and provides insights" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Set up agent
        Set ..SystemPrompt = "You are a data analyst. Use the available tools to analyze data and provide insights."
        Set ..Model = "gpt-4"
        
        // Add tools
        Do ..AddTool("Calculator", "MyApp.Tools.Calculator")
        Do ..AddTool("DataQuery", "MyApp.Tools.DataQuery")
        Do ..AddTool("ChartGenerator", "MyApp.Tools.ChartGenerator")
        
        // Add skills
        Do ..AddSkill("DataAnalysis", "MyApp.Skills.DataAnalysis")
        Do ..AddSkill("StatisticalAnalysis", "MyApp.Skills.StatisticalAnalysis")
        
        // Configure MCP data access
        Do ..AddMCPServer("IrisDataServer", "MyApp.MCP.IrisDataServer")
        
        Quit ##super()
    }
    
    /// Custom method for data analysis
    Method AnalyzeData(query As %String, dataSource As %String) As %DynamicObject
    {
        // Use MCP to get data
        Set mcpData = ..GetMCPData(dataSource, query)
        
        // Use tools to process data
        Set processedData = ..ExecuteTool("DataQuery", {"data": mcpData, "query": query})
        
        // Use skills for analysis
        Set analysis = ..ExecuteSkill("DataAnalysis", {"data": processedData})
        
        // Generate insights
        Set insights = ..Chat("Based on this data: " _ $Replace(processedData, """, " ") _ 
                          ", provide insights and recommendations.")
        
        Quit {
            "data": processedData,
            "analysis": analysis,
            "insights": insights
        }
    }
}
```

---

## 🧪 Testing Your Agent

### Test Script
```objectscript
/// Test/MyAgentTest.cls
Class Test.MyAgentTest Extends %UnitTest.TestCase
{
    Method TestAgentCreation()
    {
        Set agent = ##class(MyApp.Agents.DataAnalyst).%New()
        Do ..AssertTrue($$$ISDEF(agent.Name), "Agent name should be defined")
        Do ..AssertEquals(agent.Name, "DataAnalyst", "Agent name should be DataAnalyst")
    }
    
    Method TestAgentChat()
    {
        Set agent = ##class(MyApp.Agents.DataAnalyst).%New()
        Set response = agent.Chat("Hello!")
        Do ..AssertTrue($Length(response) > 0, "Agent should respond to chat")
    }
    
    Method TestToolExecution()
    {
        Set agent = ##class(MyApp.Agents.DataAnalyst).%New()
        Set result = agent.ExecuteTool("Calculator", {"operation": "add", "a": 5, "b": 3})
        Do ..AssertEquals(result.result, 8, "Calculator should return correct result")
    }
    
    Method TestMCPDataAccess()
    {
        // First, set up test data
        Set ^TestData(1) = "Value1"
        Set ^TestData(2) = "Value2"
        
        // Create MCP server for test data
        Set server = ##class(MyApp.MCP.IrisDataServer).%New()
        Set connector = ##class(MyApp.MCP.GlobalConnector).%New("^TestData")
        Do server.AddConnector(connector)
        
        // Register server
        Set mcpManager = ##class(%AI.MCP.Manager).%New()
        Do mcpManager.RegisterServer(server)
        
        // Test data access
        Set agent = ##class(MyApp.Agents.DataAnalyst).%New()
        Set data = agent.GetMCPData("IrisDataServer", {"action": "read", "subscripts": [1]})
        Do ..AssertEquals(data.value, "Value1", "Should read correct value from global")
        
        // Clean up
        Kill ^TestData
    }
}

// Run tests
Do ##class(Test.MyAgentTest).%New().RunAll()
```

---

## 📚 Learning Resources

### Official Documentation (To Find)
- [ ] InterSystems AI Hub Documentation
- [ ] %AI.Agent Class Reference
- [ ] %AI.MCP Package Documentation
- [ ] AI Hub API Reference

### Community Resources
- [ ] Developer Community AI Hub discussions
- [ ] GitHub examples
- [ ] Open Exchange applications

### Recommended Learning Path
1. **Week 1**: Set up environment, create first agent
2. **Week 2**: Add tools and skills, test basic functionality
3. **Week 3**: Implement MCP data exposure
4. **Week 4**: Build complete applications

---

## 🎯 Next Steps

### Immediate Actions
1. **Set up IRIS with AI Hub**
2. **Run discovery commands** to find actual classes
3. **Validate examples** against real implementation
4. **Create working prototypes**

### Research Questions to Answer
- [ ] What is the exact class hierarchy for %AI.Agent?
- [ ] How are tools registered and executed?
- [ ] How does the skill system work?
- [ ] What MCP classes are available?
- [ ] What REST/WebSocket APIs are provided?

---

**Document Status**: Draft - Awaiting validation against actual IRIS AI Hub implementation  
**Next Update**: After environment setup and class discovery  
**Owner**: Pietro Dileo + AI Assistant