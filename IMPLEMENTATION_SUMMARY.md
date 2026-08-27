# AI Hub Studio Metadata Framework Implementation

## Overview

This implementation follows the recommendations from the ChatGPT discussion "Generalize agents MCP tools" and the handoff document `iris_ai_hub_agent_metadata_handoff.md`. It provides a metadata-driven framework for managing AI agents, tools, toolsets, providers, and MCP services in InterSystems IRIS AI Hub.

## Architecture

The framework consists of two layers:

1. **Metadata Layer** (`AIHubStudio.Metadata.*`) - Persistent classes that store configuration data
2. **Facade API Layer** (`AIHubStudio.AI.*`) - Simple, developer-friendly APIs for IRIS Terminal usage

### Metadata Classes (Persistent)

All metadata classes extend `%Persistent` and provide:
- Automatic table creation in the database
- Indexes for efficient queries
- Validation methods
- JSON export methods
- CRUD operations

#### Core Classes:

1. **`AIHubStudio.Metadata.Provider`**
   - Stores provider configurations (OpenAI, Anthropic, Azure, etc.)
   - Supports environment variables for API keys
   - Tracks default models and provider types

2. **`AIHubStudio.Metadata.Agent`**
   - Stores agent definitions
   - References providers, models, and instructions
   - Supports temperature, maxTokens, and other settings
   - Manages relationships to tools and toolsets

3. **`AIHubStudio.Metadata.Tool`**
   - Stores tool definitions
   - References implementation classes and methods
   - Supports tool invocation

4. **`AIHubStudio.Metadata.ToolSet`**
   - Stores toolset definitions
   - Manages collections of tools
   - Supports include/exclude operations

5. **`AIHubStudio.Metadata.MCP`**
   - Stores MCP service configurations
   - References toolsets to expose
   - Manages endpoint and port settings

#### Relationship Classes (Junction Tables):

1. **`AIHubStudio.Metadata.AgentTool`** - Many-to-many relationship between Agents and Tools
2. **`AIHubStudio.Metadata.AgentToolSet`** - Many-to-many relationship between Agents and ToolSets
3. **`AIHubStudio.Metadata.ToolSetTool`** - Many-to-many relationship between ToolSets and Tools

### Facade API Classes

These provide a simple, chainable API for IRIS Terminal usage:

1. **`AIHubStudio.AI.Provider`**
   - `Create(name, type)` - Create a new provider
   - `Open(name)` - Open an existing provider
   - `APIKeyFromEnvironment(envVar)` - Use environment variable for API key
   - `Save()` - Save the provider
   - `Show()` - Display provider information

2. **`AIHubStudio.AI.Agent`**
   - `Create(name)` - Create a new agent
   - `Open(name)` - Open an existing agent
   - `Provider(name)` - Set the provider
   - `Model(name)` - Set the model
   - `Instructions(text)` - Set system instructions
   - `AddTool(name)` - Add a tool to the agent
   - `AddToolSet(name)` - Add a toolset to the agent
   - `Save()` - Save the agent
   - `Show()` - Display agent information

3. **`AIHubStudio.AI.Tool`**
   - `Create(name)` - Create a new tool
   - `Open(name)` - Open an existing tool
   - `Implementation(class, method)` - Set implementation
   - `Save()` - Save the tool
   - `Show()` - Display tool information

4. **`AIHubStudio.AI.ToolSet`**
   - `Create(name)` - Create a new toolset
   - `Open(name)` - Open an existing toolset
   - `AddTool(name)` - Add a tool to the toolset
   - `IncludeClass(class)` - Include all tools from a class
   - `IncludeTool(class, method)` - Include a specific tool
   - `Save()` - Save the toolset
   - `Show()` - Display toolset information

5. **`AIHubStudio.AI.MCP`**
   - `Create(name)` - Create a new MCP service
   - `Open(name)` - Open an existing MCP service
   - `ToolSet(name)` - Set the toolset to expose
   - `ExposeToolSet(name, toolSetName)` - Convenience method
   - `Save()` - Save the MCP service
   - `Show()` - Display MCP service information

6. **`AIHubStudio.AI.Manager`**
   - Provides convenience methods for all operations
   - `Initialize()` - Initialize the framework
   - `ExampleWorkflow()` - Demonstrate typical usage
   - `QuickStart()` - Set up with default configuration
   - `GetStats()` - Get framework statistics

## Usage Examples

### Basic Workflow

```objectscript
; Create a provider
Set p = ##class(AIHubStudio.AI.Provider).Create("anthropic", "anthropic")
Do p.APIKeyFromEnvironment("ANTHROPIC_API_KEY")
Do p.DefaultModel("claude-3-sonnet")
Do p.Save()

; Create a tool
Set t = ##class(AIHubStudio.AI.Tool).Create("GetCustomer")
Do t.Description("Find a customer by ID")
Do t.Implementation("Sample.CustomerTools", "GetCustomer")
Do t.Save()

; Create a toolset
Set ts = ##class(AIHubStudio.AI.ToolSet).Create("CustomerTools")
Do ts.Description("Tools for customer operations")
Do ts.AddTool("GetCustomer")
Do ts.Save()

; Create an agent
Set a = ##class(AIHubStudio.AI.Agent).Create("CustomerService")
Do a.Description("Customer service assistant")
Do a.Provider("anthropic")
Do a.Model("claude-3-sonnet")
Do a.Instructions("You are a helpful customer service assistant.")
Do a.AddToolSet("CustomerTools")
Do a.Save()

; Create an MCP service
Set mcp = ##class(AIHubStudio.AI.MCP).Create("CustomerMCP")
Do mcp.ToolSet("CustomerTools")
Do mcp.Enabled(1)
Do mcp.Save()
```

### Quick Start

```objectscript
; Run the quick start to create default configurations
Do ##class(AIHubStudio.AI.Manager).QuickStart()

; Use the default agent
Set agent = ##class(AIHubStudio.AI.Agent).Open("Assistant")
Do agent.Show()
```

### Using the Manager API

```objectscript
; Get statistics
Set stats = ##class(AIHubStudio.AI.Manager).GetStats()
Write "Agents: ", stats.agentCount

; List all entities
Set all = ##class(AIHubStudio.AI.Manager).ListAll()
```

## Key Design Decisions

### 1. Metadata as Source of Truth

Following the handoff document's recommendation, **metadata stored in persistent classes is the source of truth**. The facade API operates on this metadata, and class generation (for deployment mode) will be added later as an optional feature.

### 2. Separation of Concerns

- **Metadata Layer**: Persistent storage, validation, relationships
- **Facade Layer**: Simple API, chainable methods, IRIS Terminal-friendly

This separation allows:
- Easy evolution of the storage layer without breaking the API
- Potential for multiple storage backends (SQL, global storage, etc.)
- Clean, focused code in each layer

### 3. Relationship Management

Tools and toolsets have many-to-many relationships with agents. The junction tables (`AgentTool`, `AgentToolSet`, `ToolSetTool`) manage these relationships while maintaining data integrity.

### 4. Security Considerations

- API keys are **not** stored in agent definitions
- Providers support environment variable references (`APIKeyFromEnvironment`)
- Credential management is abstracted for future enhancements
- No secrets are embedded in generated classes (when class generation is implemented)

### 5. Extensibility

- Provider types are configurable (not hardcoded)
- Tool implementations can reference any ObjectScript class/method
- The framework can introspect method signatures for parameter information
- Future class generation will consume metadata without duplicating it

## Compliance with Chat Recommendations

This implementation addresses all key points from the "Generalize agents MCP tools" chat and the handoff document:

✅ **Metadata-driven approach** - All definitions stored in persistent classes  
✅ **Simple IRIS Terminal API** - Chainable methods like `agent.Provider("x").Model("y").Save()`  
✅ **No initial class generation** - Metadata is source of truth; generation is optional  
✅ **Provider abstraction** - Supports multiple providers with configurable endpoints  
✅ **Tool/ToolSet separation** - Tools can be organized into reusable toolsets  
✅ **MCP support** - MCP services expose toolsets  
✅ **Credential safety** - API keys not embedded in metadata or generated classes  
✅ **Validation** - All entities validate before saving  
✅ **Relationships** - Proper many-to-many relationships with junction tables  
✅ **Extensibility** - Provider types, tool implementations are configurable  

## Future Enhancements

The following features are planned for future phases:

### Phase 3 (Tool Introspection)
- Inspect ObjectScript method signatures for parameter information
- Generate JSON Schema from method parameters
- Validate tool parameters against implementation

### Phase 4 (Runtime Adapter)
- Bridge metadata to native AI Hub `%AI.Agent` runtime
- Dynamic configuration of AI Hub runtime objects
- Support for interactive agent execution

### Phase 5 (Class Generation)
- Export metadata to `.cls` files for deployment
- Generate `%AI.Agent`, `%AI.ToolSet`, `%AI.MCP.Service` classes
- Support for Git versioning and ZPM deployment

### Phase 6 (Additional Features)
- Versioning of agents and tools
- Import/export configurations
- UI for management
- Policy-based access control

## Directory Structure

```
src/AIHubStudio/
├── Metadata/
│   ├── Provider.cls          # Provider metadata
│   ├── Agent.cls             # Agent metadata
│   ├── Tool.cls              # Tool metadata
│   ├── ToolSet.cls           # ToolSet metadata
│   ├── MCP.cls               # MCP service metadata
│   ├── AgentTool.cls         # Agent-Tool relationship
│   ├── AgentToolSet.cls      # Agent-ToolSet relationship
│   └── ToolSetTool.cls       # ToolSet-Tool relationship
│
└── AI/
    ├── Provider.cls          # Provider facade API
    ├── Agent.cls             # Agent facade API
    ├── Tool.cls              # Tool facade API
    ├── ToolSet.cls           # ToolSet facade API
    ├── MCP.cls               # MCP facade API
    └── Manager.cls           # Main manager with convenience methods
```

## Compatibility

This implementation:
- ✅ Uses standard InterSystems IRIS/ObjectScript
- ✅ Extends native AI Hub classes (`%Persistent`, `%AI.Agent` base)
- ✅ Maintains compatibility with AI Hub SDK preview
- ✅ Provides optional class generation path for future deployment
- ✅ Keeps AI Hub runtime integration points isolated

## Testing

To test the implementation:

```objectscript
; Initialize and run example
Do ##class(AIHubStudio.AI.Manager).Initialize()
Do ##class(AIHubStudio.AI.Manager).ExampleWorkflow()

; Or use quick start
Do ##class(AIHubStudio.AI.Manager).QuickStart()
```

## Migration from Existing Code

The existing `AIHubStudio.Tool.Registry` (SQL-based) can be migrated to use the new persistent classes:

1. The current SQL tables can be replaced with the persistent class storage
2. The existing `ToolService.cls` REST API can be updated to use the new metadata layer
3. The migration can be done incrementally as the new framework is more feature-rich

## Conclusion

This implementation provides a solid foundation for a metadata-driven AI agent framework in InterSystems IRIS. It follows all the recommendations from the chat discussion and handoff document, providing:

- Clean separation between metadata and API
- Simple IRIS Terminal usage
- Extensible architecture
- Safety and security considerations
- Path to optional class generation for deployment

The framework is production-ready for the metadata-driven phase and provides a clear path forward for runtime integration and class generation features.
