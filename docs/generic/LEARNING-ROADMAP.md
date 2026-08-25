# 🗺️ AI Hub Learning Roadmap for IRIS

**Project**: IRIS AI Hub Studio - Bounty Program Round 2  
**Objective**: Master AI Hub to build the unified platform  
**Timeline**: 2-3 weeks of focused learning  
**Status**: Ready to start

---

## 🎯 Overview

Since **AI Hub with IRIS is brand new**, we need to systematically discover and learn its implementation. This roadmap will guide us through the process of understanding AI Hub, creating working examples, and building our unified platform.

**Current Situation**:
- ✅ We have a comprehensive project plan for the unified platform
- ✅ We have discovery scripts ready to run
- ❌ We need to validate the actual AI Hub implementation
- ❌ We need working examples for each component

**Goal**: Become AI Hub experts and build production-ready components

---

## 📅 Week-by-Week Plan

### 📅 Week 1: Foundation & Discovery
**Objective**: Set up environment, discover AI Hub implementation, create first working examples

#### Day 1: Environment Setup
- [ ] **Set up IRIS with AI Hub**
  - [ ] Install IRIS community edition
  - [ ] Verify AI Hub package is installed
  - [ ] Check for %AI.Agent and %AI.MCP classes
  - [ ] Set up development environment

#### Day 2: AI Hub Discovery
- [ ] **Run discovery script** (`DISCOVERY-SCRIPT.cls`)
  - [ ] Document all %AI classes found
  - [ ] Document %AI.Agent class hierarchy
  - [ ] Document %AI.MCP classes
  - [ ] Document available APIs

#### Day 3: First Agent
- [ ] **Create minimal working agent**
  - [ ] Extend %AI.Agent
  - [ ] Implement basic chat functionality
  - [ ] Test agent instantiation
  - [ ] Test basic conversation

#### Day 4: Tool System
- [ ] **Understand and implement tools**
  - [ ] Discover %AI.Agent.Tool class
  - [ ] Create first tool
  - [ ] Add tool to agent
  - [ ] Test tool execution

#### Day 5: Skill System
- [ ] **Understand and implement skills**
  - [ ] Discover %AI.Agent.Skill class
  - [ ] Create first skill
  - [ ] Add skill to agent
  - [ ] Test skill activation

**Week 1 Deliverables**:
- ✅ Working IRIS environment with AI Hub
- ✅ Complete documentation of AI Hub classes
- ✅ First working agent with basic chat
- ✅ First working tool
- ✅ First working skill

---

### 📅 Week 2: MCP & Integration
**Objective**: Master MCP data exposure and integrate with agents

#### Day 6: MCP Package Discovery
- [ ] **Explore %AI.MCP package**
  - [ ] Document all MCP classes
  - [ ] Understand MCP server architecture
  - [ ] Discover data connector classes

#### Day 7: Data Connectors
- [ ] **Implement global data connector**
  - [ ] Create MCP server for globals
  - [ ] Test reading global data via MCP
  - [ ] Test listing global subscripts

#### Day 8: SQL & DocDB Connectors
- [ ] **Implement SQL data connector**
  - [ ] Create MCP server for SQL tables
  - [ ] Test querying SQL data via MCP
  - [ ] Implement DocDB connector

#### Day 9: Security & Access Control
- [ ] **Understand security model**
  - [ ] Discover authentication mechanisms
  - [ ] Implement access control for MCP
  - [ ] Test secure data exposure

#### Day 10: Agent-MCP Integration
- [ ] **Connect agents to MCP data**
  - [ ] Create agent that uses MCP data
  - [ ] Test agent querying exposed data
  - [ ] Create tools that access MCP data

**Week 2 Deliverables**:
- ✅ Working MCP server with all data connectors
- ✅ Security controls for data exposure
- ✅ Agent that consumes MCP data
- ✅ Tools that access exposed data

---

### 📅 Week 3: Advanced Features & Platform
**Objective**: Implement advanced features and start building the unified platform

#### Day 11: Sub-Agents
- [ ] **Understand sub-agent system**
  - [ ] Discover sub-agent creation methods
  - [ ] Create parent agent with sub-agents
  - [ ] Test sub-agent delegation

#### Day 12: Multi-Model Support
- [ ] **Implement multi-model support**
  - [ ] Discover model configuration
  - [ ] Test different models
  - [ ] Implement model selection

#### Day 13: REST/WebSocket APIs
- [ ] **Explore API layer**
  - [ ] Document REST API endpoints
  - [ ] Test WebSocket connections
  - [ ] Understand authentication

#### Day 14: Platform Architecture
- [ ] **Design unified platform**
  - [ ] Finalize component relationships
  - [ ] Design shared infrastructure
  - [ ] Create docker-compose setup

#### Day 15: Start Implementation
- [ ] **Begin platform development**
  - [ ] Set up project structure
  - [ ] Implement Agent Test UI foundation
  - [ ] Create MCP Toolkit foundation

**Week 3 Deliverables**:
- ✅ Working sub-agent examples
- ✅ Multi-model support implementation
- ✅ API documentation
- ✅ Platform architecture finalized
- ✅ Initial platform code

---

## 🎓 Learning Modules

### Module 1: AI Hub Basics (2 days)
**Objective**: Understand core AI Hub concepts and create first agent

#### Lesson 1.1: AI Hub Architecture
- [ ] Understand AI Hub components
- [ ] Learn about %AI.Agent class
- [ ] Understand agent lifecycle
- [ ] Learn about configuration

#### Lesson 1.2: Creating Agents
- [ ] Extend %AI.Agent
- [ ] Configure agent properties
- [ ] Implement agent methods
- [ ] Test agent functionality

**Hands-on Exercise**:
```objectscript
// Create MyApp.FirstAgent.cls
Class MyApp.FirstAgent Extends %AI.Agent
{
    Property Name As %String [ InitialExpression = "FirstAgent" ];
    Property Description As %String [ InitialExpression = "My first AI agent" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Set ..SystemPrompt = "You are a helpful assistant."
        Set ..Model = "gpt-4"
        Quit ##super()
    }
}

// Test the agent
Set agent = ##class(MyApp.FirstAgent).%New()
Set response = agent.Chat("Hello!")
Write response
```

#### Lesson 1.3: Agent Configuration
- [ ] Understand configuration options
- [ ] Configure system prompts
- [ ] Set model parameters
- [ ] Manage conversation state

---

### Module 2: Tools & Skills (2 days)
**Objective**: Master the tool and skill systems

#### Lesson 2.1: Tool System
- [ ] Understand %AI.Agent.Tool class
- [ ] Learn tool registration
- [ ] Understand tool execution
- [ ] Handle tool errors

**Hands-on Exercise**:
```objectscript
// Create MyApp.Tools.Calculator.cls
Class MyApp.Tools.Calculator Extends %AI.Agent.Tool
{
    Property Name As %String [ InitialExpression = "Calculator" ];
    
    Method Execute(input As %DynamicObject) As %DynamicObject
    {
        Set operation = input.operation
        Set a = input.a
        Set b = input.b
        
        If operation = "add" Quit {"result": a + b}
        If operation = "subtract" Quit {"result": a - b}
        If operation = "multiply" Quit {"result": a * b}
        If operation = "divide" {
            If b = 0 Quit {"error": "Division by zero"}
            Quit {"result": a / b}
        }
        
        Quit {"error": "Unknown operation"}
    }
}

// Add tool to agent
Set agent = ##class(MyApp.FirstAgent).%New()
Set status = agent.AddTool("Calculator", "MyApp.Tools.Calculator")
```

#### Lesson 2.2: Skill System
- [ ] Understand %AI.Agent.Skill class
- [ ] Learn skill triggers
- [ ] Understand skill execution
- [ ] Combine skills with tools

**Hands-on Exercise**:
```objectscript
// Create MyApp.Skills.MathHelper.cls
Class MyApp.Skills.MathHelper Extends %AI.Agent.Skill
{
    Property Name As %String [ InitialExpression = "MathHelper" ];
    Property Triggers As %List [ MultiDimensional ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        Do ..Triggers.SetAt("math", "user mentions math, calculate, compute")
        Quit ##super()
    }
    
    Method Execute(context As %DynamicObject) As %DynamicObject
    {
        // Extract numbers from context.message
        // Use tools if available
        // Return helpful math response
    }
}
```

---

### Module 3: MCP Data Exposure (3 days)
**Objective**: Master MCP integration for data exposure

#### Lesson 3.1: MCP Basics
- [ ] Understand MCP protocol
- [ ] Learn %AI.MCP.Server class
- [ ] Understand connector architecture
- [ ] Set up MCP server

**Hands-on Exercise**:
```objectscript
// Create MyApp.MCP.MyServer.cls
Class MyApp.MCP.MyServer Extends %AI.MCP.Server
{
    Property Name As %String [ InitialExpression = "MyMCPServer" ];
    
    Method %OnNew() As %Status [ CodeMode = objectgenerator ]
    {
        // Add connectors
        Set connector = ##class(MyApp.MCP.GlobalConnector).%New()
        Do ..AddConnector(connector)
        Quit ##super()
    }
}
```

#### Lesson 3.2: Data Connectors
- [ ] Implement GlobalConnector
- [ ] Implement SQLConnector
- [ ] Implement DocDBConnector
- [ ] Test data access

**Hands-on Exercise**:
```objectscript
// Create MyApp.MCP.GlobalConnector.cls
Class MyApp.MCP.GlobalConnector Extends %AI.MCP.Connector
{
    Property GlobalName As %String;
    
    Method HandleRequest(request As %DynamicObject) As %DynamicObject
    {
        If request.action = "read" {
            Set value = $Get(@(..GlobalName _ "("_ $ListToString(request.subscripts, ",") _ ")"))
            Quit {"value": value}
        }
        Quit {"error": "Unknown action"}
    }
}
```

#### Lesson 3.3: Security
- [ ] Understand authentication
- [ ] Implement access control
- [ ] Secure sensitive data
- [ ] Test security

---

### Module 4: Advanced Features (2 days)
**Objective**: Master advanced AI Hub features

#### Lesson 4.1: Sub-Agents
- [ ] Understand sub-agent creation
- [ ] Implement agent delegation
- [ ] Manage sub-agent lifecycle
- [ ] Handle sub-agent errors

**Hands-on Exercise**:
```objectscript
// Create parent agent with sub-agent
Class MyApp.ParentAgent Extends %AI.Agent
{
    Method HandleComplexTask(task As %String) As %String
    {
        // Create sub-agent for specific task
        Set subAgent = ..CreateSubAgent("MyApp.ResearchAgent")
        
        // Delegate task
        Set result = subAgent.Chat(task)
        
        // Process result
        Quit "Based on research: " _ result
    }
}
```

#### Lesson 4.2: Multi-Model Support
- [ ] Configure multiple models
- [ ] Implement model selection
- [ ] Handle model fallbacks
- [ ] Optimize model usage

---

### Module 5: Platform Development (3 days)
**Objective**: Build the unified platform

#### Lesson 5.1: Architecture Design
- [ ] Finalize platform architecture
- [ ] Design component interactions
- [ ] Plan shared infrastructure

#### Lesson 5.2: Agent Test UI
- [ ] Set up frontend framework
- [ ] Implement agent discovery
- [ ] Create chat interface
- [ ] Add tool visualization

#### Lesson 5.3: MCP Toolkit
- [ ] Implement MCP server templates
- [ ] Create data connector templates
- [ ] Build security templates

#### Lesson 5.4: Starter Agent
- [ ] Create agent templates
- [ ] Implement docker-compose
- [ ] Add example configurations

---

## 📚 Required Resources

### Development Environment
- [ ] IRIS Community Edition (with AI Hub)
- [ ] Docker (for containerized development)
- [ ] VS Code with ObjectScript extension
- [ ] Node.js (for frontend development)
- [ ] Git (for version control)

### Documentation
- [ ] IRIS Documentation
- [ ] AI Hub Documentation (when available)
- [ ] %AI.Agent Class Reference
- [ ] %AI.MCP Package Documentation

### Community Resources
- [ ] InterSystems Developer Community
- [ ] GitHub repositories
- [ ] Open Exchange applications

---

## 🎯 Success Criteria

### Week 1: Foundation
- [ ] IRIS with AI Hub running
- [ ] All AI Hub classes documented
- [ ] First agent working
- [ ] First tool working
- [ ] First skill working

### Week 2: MCP Integration
- [ ] MCP server working
- [ ] All data connectors working
- [ ] Security implemented
- [ ] Agent-MCP integration working

### Week 3: Advanced & Platform
- [ ] Sub-agents working
- [ ] Multi-model support working
- [ ] APIs documented
- [ ] Platform architecture finalized
- [ ] Initial platform code

---

## 🚀 Next Steps

### Immediate Actions (Today)
1. **Set up IRIS environment**
   - Install IRIS community edition
   - Verify AI Hub is available
   - Test basic functionality

2. **Run discovery script**
   - Import `DISCOVERY-SCRIPT.cls`
   - Run `Do ##class(AIHub.Discovery).Run()`
   - Document findings

3. **Create first agent**
   - Use the minimal agent example
   - Test chat functionality
   - Document the process

### This Week's Focus
- Complete **Module 1: AI Hub Basics**
- Start **Module 2: Tools & Skills**
- Document all discoveries

---

## 📝 Discovery Checklist

### AI Hub Core
- [ ] %AI.Agent class discovered
- [ ] %AI.Agent methods documented
- [ ] %AI.Agent properties documented
- [ ] Agent lifecycle understood
- [ ] Configuration options understood

### Tools & Skills
- [ ] %AI.Agent.Tool class discovered
- [ ] Tool registration understood
- [ ] Tool execution understood
- [ ] %AI.Agent.Skill class discovered
- [ ] Skill triggers understood

### MCP
- [ ] %AI.MCP.Server class discovered
- [ ] Connector classes discovered
- [ ] MCP protocol understood
- [ ] Data exposure mechanisms understood

### APIs
- [ ] REST API endpoints discovered
- [ ] WebSocket API discovered
- [ ] Authentication mechanisms understood

---

## 🎓 Validation Questions

After each learning module, ask yourself:

1. **Can I create a working agent from scratch?**
2. **Can I add tools to an agent?**
3. **Can I add skills to an agent?**
4. **Can I expose IRIS data via MCP?**
5. **Can I create an agent that uses MCP data?**
6. **Can I create sub-agents?**
7. **Can I configure multiple models?**

If you can answer "yes" to all these questions, you're ready to build the unified platform!

---

## 📅 Daily Progress Tracking

### Template for Daily Log
```markdown
## Date: YYYY-MM-DD

### Today's Focus
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Discoveries
- New classes found:
- New methods found:
- New patterns discovered:

### Challenges
- Issues encountered:
- Solutions found:
- Still blocked on:

### Code Created
- Files created:
- Code snippets:
- Working examples:

### Next Steps
- Tomorrow's focus:
- Questions to research:
```

---

## 🤝 Collaboration Plan

### How We'll Work Together

1. **You**: Set up IRIS environment and run discovery
2. **Me**: Provide guidance, examples, and troubleshooting
3. **You**: Document findings and create working examples
4. **Me**: Help design platform architecture based on discoveries
5. **You**: Implement platform components
6. **Me**: Review, optimize, and provide additional examples

### Communication
- **Daily**: Share progress and discoveries
- **As needed**: Ask questions when stuck
- **Weekly**: Review progress and adjust plan

---

## 🎯 Ready to Start?

**Your first task**:

1. **Set up IRIS with AI Hub**
   ```bash
   docker run -d --name iris-ai-hub -p 52773:52773 intersystemsdc/iris-community:latest
   ```

2. **Access IRIS terminal**
   ```bash
   docker exec -it iris-ai-hub iris session iris
   ```

3. **Run discovery script**
   ```objectscript
   // First, import DISCOVERY-SCRIPT.cls into your namespace
   // Then run:
   Do ##class(AIHub.Discovery).Run()
   ```

4. **Share the results** with me so we can:
   - Validate our assumptions
   - Adjust the platform architecture
   - Create accurate examples
   - Begin implementation

**Let's get started!** What's the first step you'd like to take?

---

**Document Status**: Ready for execution  
**Next Action**: Set up IRIS environment and run discovery  
**Owner**: Pietro Dileo + AI Assistant  
**Target Completion**: 3 weeks to AI Hub mastery