# IRIS AI Hub Agent Metadata Framework — Handoff

## Goal

Build a small IRIS/ObjectScript framework on top of InterSystems AI Hub that lets developers define and manage agents, providers, tools, toolsets, and MCP exposure **from the IRIS Terminal**, without initially generating `.cls` files.

The first implementation should be **metadata/table driven**. Class generation can be added later as an export/deployment feature.

Primary UX:

```objectscript
Set a=##class(AI.Agent).Create("Customer")
Do a.Provider("anthropic")
Do a.Model("claude-sonnet-4-5")
Do a.Instructions("You are a customer service assistant.")
Do a.Save()

Set t=##class(AI.Tool).Create("GetCustomer")
Do t.Description("Find a customer by ID")
Do t.Implementation("Sample.CustomerTools","GetCustomer")
Do t.Save()

Do a.AddTool("GetCustomer")
```

The framework should remain compatible with native AI Hub runtime classes.

---

## Key architectural decision

Do NOT initially generate application agent classes such as:

```objectscript
Class Sample.AI.Customer Extends %AI.Agent
```

Instead, persist definitions in IRIS classes/tables and have a runtime facade resolve those definitions into AI Hub runtime behavior.

Future optional deployment path:

```text
Metadata definitions
      |
      v
Generator
      |
      v
Sample.AI.Customer Extends %AI.Agent
Sample.AI.CustomerTools Extends %AI.ToolSet
Sample.AI.MCP.Customer Extends %AI.MCP.Service
```

This keeps V1 simple and avoids coupling the framework to ObjectScript source generation while AI Hub is still EAP.

---

## AI Hub facts confirmed during discussion

The repository/template uses native AI Hub classes.

Concrete agent pattern:

```objectscript
Class Sample.Agent Extends %AI.Agent
{
Parameter PROVIDER = "openai";
Parameter MODEL = "gpt-4o-mini";
Parameter TOOLSETS = "Sample.ToolSet";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
...
}
}
```

Toolsets are based on `%AI.ToolSet` and use XData definitions. Toolsets can include whole tool classes, individual tools, regex matches, and exclusions.

Conceptual examples supported by the SDK:

```xml
<ToolSet>
  <Include Class="Sample.AI.Tools.Math"/>
  <Include Class="Sample.AI.Tools.Orders" Tool="GetOrder"/>
  <Include Class="Sample.AI.Tools.Orders" Match="^(Get|List)"/>
  <Exclude Match="^Delete"/>
</ToolSet>
```

MCP service pattern:

```objectscript
Class Sample.MCP.Service.Calculator Extends %AI.MCP.Service
{
Parameter SPECIFICATION As STRING = "Sample.AI.ToolSet.BasicMath";
}
```

Existing ObjectScript methods can act as tools. Method signatures provide useful parameter/type information, e.g.:

```objectscript
Class Sample.CustomerTools Extends %AI.Tool
{
ClassMethod GetCustomer(id As %String) As %DynamicObject
{
    ...
}
}
```

AI Hub also has tool discovery facilities such as `%AI.ToolMgr`.

The EAP APIs may change, so keep our abstraction thin.

---

## Proposed persistent metadata model

Use persistent classes rather than manually created SQL tables.

### AI.Metadata.Provider

Suggested fields:

```objectscript
Class AI.Metadata.Provider Extends %Persistent
{
Property Name As %String(MAXLEN=100) [ Required ];
Property Type As %String(MAXLEN=100);
Property Endpoint As %String(MAXLEN=500);
Property CredentialName As %String(MAXLEN=200);
Property Enabled As %Boolean [ InitialExpression = 1 ];
}
```

Do NOT store raw API keys in agent metadata or generated classes.

Credential handling should be abstracted. Environment variables can be supported initially:

```objectscript
Do p.APIKeyFromEnvironment("ANTHROPIC_API_KEY")
```

Possible provider types:

- native AI Hub provider, e.g. `anthropic`
- `openai-compatible`, for providers such as DeepSeek/Mistral/etc. when applicable

Do not hardcode the provider list; provider type/endpoint should be configurable.

---

### AI.Metadata.Agent

Suggested fields:

```objectscript
Class AI.Metadata.Agent Extends %Persistent
{
Property Name As %String(MAXLEN=100) [ Required ];
Property Description As %String(MAXLEN=500);
Property Provider As %String(MAXLEN=100);
Property Model As %String(MAXLEN=200);
Property Instructions As %String(MAXLEN=100000);
Property Enabled As %Boolean [ InitialExpression = 1 ];
}
```

Possible later fields:

- provider configuration JSON
- default temperature/options if supported
- version/status
- metadata/tags

Agent references toolsets/tools through relationship classes.

---

### AI.Metadata.Tool

Suggested fields:

```objectscript
Class AI.Metadata.Tool Extends %Persistent
{
Property Name As %String(MAXLEN=100) [ Required ];
Property Description As %String(MAXLEN=1000);
Property ImplementationClass As %String(MAXLEN=200);
Property ImplementationMethod As %String(MAXLEN=200);
Property Enabled As %Boolean [ InitialExpression = 1 ];
}
```

Do not initially duplicate method parameter definitions if an existing ObjectScript implementation is used. Later, introspect the implementation method signature.

---

### AI.Metadata.ToolSet

```objectscript
Class AI.Metadata.ToolSet Extends %Persistent
{
Property Name As %String(MAXLEN=100) [ Required ];
Property Description As %String(MAXLEN=1000);
Property Enabled As %Boolean [ InitialExpression = 1 ];
}
```

Relationship:

```objectscript
Class AI.Metadata.ToolSetTool Extends %Persistent
{
Property ToolSet As AI.Metadata.ToolSet;
Property Tool As AI.Metadata.Tool;
}
```

Future support for richer AI Hub semantics:

- Include whole class
- Include specific tool
- Include regex
- Exclude tool
- Exclude regex
- Policies

---

### AI.Metadata.AgentTool

```objectscript
Class AI.Metadata.AgentTool Extends %Persistent
{
Property Agent As AI.Metadata.Agent;
Property Tool As AI.Metadata.Tool;
}
```

Prefer a ToolSet relationship if AI Hub/runtime semantics make that the cleaner representation; direct AgentTool can be useful as a convenience.

---

### AI.Metadata.MCP

```objectscript
Class AI.Metadata.MCP Extends %Persistent
{
Property Name As %String(MAXLEN=100) [ Required ];
Property ToolSet As AI.Metadata.ToolSet;
Property Enabled As %Boolean [ InitialExpression = 1 ];
}
```

MCP exposes a ToolSet. Future generation can create:

```objectscript
Class Sample.AI.MCP.Customer Extends %AI.MCP.Service
{
Parameter SPECIFICATION As STRING = "Sample.AI.CustomerTools";
}
```

---

## Public facade API

Keep public classes separate from metadata persistence:

```text
AI.Agent
AI.Tool
AI.ToolSet
AI.Provider
AI.MCP
```

These are developer-facing convenience APIs over `AI.Metadata.*`.

### AI.Agent

Suggested API:

```objectscript
ClassMethod Create(name As %String) As AI.Agent
ClassMethod Open(name As %String) As AI.Agent
ClassMethod Exists(name As %String) As %Boolean
ClassMethod List() As %DynamicArray
ClassMethod Delete(name As %String) As %Status

Method Description(value As %String) As AI.Agent
Method Provider(value As %String) As AI.Agent
Method Model(value As %String) As AI.Agent
Method Instructions(value As %String) As AI.Agent
Method AddTool(toolName As %String) As %Status
Method AddToolSet(toolSetName As %String) As %Status
Method RemoveTool(toolName As %String) As %Status
Method Save() As %Status
Method Validate() As %Status
Method Show() As %Status

// Future:
Method Chat(prompt As %String) As %Status
Method Generate() As %Status
```

### AI.Tool

```objectscript
ClassMethod Create(name As %String) As AI.Tool
ClassMethod Open(name As %String) As AI.Tool
ClassMethod List() As %DynamicArray
ClassMethod Delete(name As %String) As %Status

Method Description(value As %String) As AI.Tool
Method Implementation(className As %String, methodName As %String) As AI.Tool
Method Save() As %Status
Method Validate() As %Status
Method Show() As %Status
```

### AI.ToolSet

```objectscript
ClassMethod Create(name As %String) As AI.ToolSet
ClassMethod Open(name As %String) As AI.ToolSet
ClassMethod List() As %DynamicArray

Method AddTool(toolName As %String) As %Status
Method RemoveTool(toolName As %String) As %Status
Method IncludeClass(className As %String) As %Status
Method IncludeTool(className As %String, toolName As %String) As %Status
Method IncludeMatch(className As %String, pattern As %String) As %Status
Method Exclude(toolName As %String) As %Status
Method ExcludeMatch(pattern As %String) As %Status
Method Save() As %Status
Method Validate() As %Status
Method Show() As %Status
```

### AI.Provider

```objectscript
ClassMethod Create(name As %String, type As %String = "") As AI.Provider
ClassMethod Open(name As %String) As AI.Provider
ClassMethod Configure(name As %String, apiKey As %String) As %Status
ClassMethod ConfigureFromEnvironment(name As %String, envVar As %String) As %Status

Method Type(value As %String) As AI.Provider
Method Endpoint(value As %String) As AI.Provider
Method Credential(name As %String) As AI.Provider
Method APIKeyFromEnvironment(envVar As %String) As AI.Provider
Method Save() As %Status
Method Validate() As %Status
```

The exact credential mechanism must be mapped to the target AI Hub build before implementation. Avoid embedding secrets in persistent Agent records or generated classes.

### AI.MCP

```objectscript
ClassMethod Create(name As %String) As AI.MCP
ClassMethod Open(name As %String) As AI.MCP
ClassMethod ExposeToolSet(name As %String, toolSetName As %String) As %Status

Method ToolSet(name As %String) As AI.MCP
Method Save() As %Status
Method Validate() As %Status
Method Show() As %Status

// Future:
Method Generate() As %Status
```

---

## Desired IRIS Terminal workflow

Create provider:

```objectscript
Set p=##class(AI.Provider).Create("anthropic","anthropic")
Do p.APIKeyFromEnvironment("ANTHROPIC_API_KEY")
Do p.Save()
```

Create agent:

```objectscript
Set a=##class(AI.Agent).Create("Customer")
Do a.Description("Customer service assistant")
Do a.Provider("anthropic")
Do a.Model("claude-sonnet-4-5")
Do a.Instructions("You are a customer service assistant.")
Do a.Save()
```

Create tool:

```objectscript
Set t=##class(AI.Tool).Create("GetCustomer")
Do t.Description("Find a customer by ID")
Do t.Implementation("Sample.CustomerTools","GetCustomer")
Do t.Save()
```

Attach:

```objectscript
Do a.AddTool("GetCustomer")
```

Inspect:

```objectscript
Do a.Show()
```

Potential output:

```text
Agent: Customer
Provider: anthropic
Model: claude-sonnet-4-5

Instructions:
  You are a customer service assistant.

Tools:
  GetCustomer
    Sample.CustomerTools.GetCustomer
```

---

## Runtime architecture

Target architecture:

```text
                    IRIS Terminal / ObjectScript
                              |
                              v
                    AI.Agent / AI.Tool / ...
                              |
                              v
                       AI.Metadata.*
                              |
                              v
                       Runtime Resolver
                              |
                              v
                    InterSystems AI Hub
                              |
              +---------------+----------------+
              |               |                |
          %AI.Agent       %AI.ToolSet     %AI.MCP.Service
```

The first implementation should focus on metadata and CRUD/validation.

Runtime execution should only be added after confirming the exact extension points in the target AI Hub EAP build for dynamically supplying:

- PROVIDER
- MODEL
- TOOLSETS
- instructions
- provider credentials/configuration

Do not assume `%AI.Agent` parameters can all be overridden dynamically until verified.

---

## Provider strategy

Do not put API keys in generated classes.

Recommended conceptual model:

```text
Provider
  name = anthropic
  type = anthropic
  credential = ...
  endpoint = optional

Agent
  provider = anthropic
  model = claude-sonnet-4-5
```

For DeepSeek/Mistral/OpenRouter/etc., use a configurable provider type such as `openai-compatible` where supported:

```objectscript
Set p=##class(AI.Provider).Create("deepseek","openai-compatible")
Do p.Endpoint("https://api.deepseek.com/v1")
Do p.APIKeyFromEnvironment("DEEPSEEK_API_KEY")
Do p.Save()
```

Exact model names/endpoints and AI Hub provider support should be verified against the deployed AI Hub version before hardcoding defaults.

---

## Future class generation

Once metadata is stable:

```objectscript
Do ##class(AI.Agent).Generate("Customer")
```

could create:

```objectscript
Class Sample.AI.Customer Extends %AI.Agent
{
Parameter PROVIDER = "anthropic";
Parameter MODEL = "claude-sonnet-4-5";
Parameter TOOLSETS = "Sample.AI.CustomerTools";

XData INSTRUCTIONS [ MimeType = text/markdown ]
{
You are a customer service assistant.
}
}
```

ToolSet:

```objectscript
Class Sample.AI.CustomerTools Extends %AI.ToolSet
{
XData Definition [ MimeType = application/xml ]
{
<ToolSet Name="CustomerTools">
  ...
</ToolSet>
}
```

MCP:

```objectscript
Class Sample.AI.MCP.Customer Extends %AI.MCP.Service
{
Parameter SPECIFICATION As STRING = "Sample.AI.CustomerTools";
}
```

Generation is optional and should be treated as deployment/export, not the source of truth.

---

## Important design principles

1. Metadata is source of truth in V1.
2. Keep public facade APIs simple enough for IRIS Terminal.
3. Keep secrets out of Agent/Tool records and generated source.
4. Reuse native AI Hub `%AI.*` classes instead of replacing them.
5. Don't duplicate ObjectScript method parameter schemas unless necessary; introspect existing methods later.
6. ToolSets are the natural reusable unit shared by Agents and MCP.
7. Provider configuration should be independent from Agent definitions.
8. Keep provider types extensible; don't hardcode only OpenAI/Anthropic.
9. AI Hub is EAP; isolate version-specific runtime/credential behavior.
10. Add `.cls` generation only after the metadata model is stable.

---

## Suggested implementation order

### Phase 1
Implement:

- `AI.Metadata.Provider`
- `AI.Metadata.Agent`
- `AI.Metadata.Tool`
- `AI.Metadata.ToolSet`
- `AI.Metadata.AgentTool`
- `AI.Metadata.ToolSetTool`
- `AI.Metadata.MCP`

### Phase 2
Implement facade:

- `AI.Provider`
- `AI.Agent`
- `AI.Tool`
- `AI.ToolSet`
- `AI.MCP`

with Create/Open/Save/Delete/List/Show/Validate.

### Phase 3
Implement tool introspection:

- inspect ObjectScript class/method
- verify method exists
- inspect arguments
- derive JSON-schema-relevant types

### Phase 4
Implement runtime adapter to native AI Hub.

### Phase 5
Implement optional generator/export to native `%AI.Agent`, `%AI.ToolSet`, `%AI.MCP.Service` classes.

---

## Current conclusion

Start with the table version.

The key idea is:

**IRIS Terminal is the CLI; persistent metadata is the source of truth; `AI.*` is the developer API; `%AI.*` is the AI Hub runtime; class generation is a later deployment/export feature.**

This gives a flexible foundation for defining many agents with shared tools and providers without generating or modifying ObjectScript classes during normal development.
