/// Class: AIHubStudio.AI.Manager
/// Description: Main manager class for AI Hub Studio metadata-driven agent framework
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Provides a unified entry point for managing agents, tools, toolsets, and MCP services

Class AIHubStudio.AI.Manager
{

/// Method: Initialize
/// Description: Initialize the AI Hub Studio metadata framework
ClassMethod Initialize() As %Status
{
    Set sc = $$$OK
    
    // Initialize all metadata tables by creating them if needed
    Try {
        Set stats = ..GetStats()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    
    Quit sc
}

/// Method: CreateAgent
/// Description: Create a new agent (convenience method)
ClassMethod CreateAgent(name As %String) As AIHubStudio.AI.Agent
{
    Quit ##class(AIHubStudio.AI.Agent).Create(name)
}

/// Method: OpenAgent
/// Description: Open an existing agent (convenience method)
ClassMethod OpenAgent(name As %String) As AIHubStudio.AI.Agent
{
    Quit ##class(AIHubStudio.AI.Agent).Open(name)
}

/// Method: CreateTool
/// Description: Create a new tool (convenience method)
ClassMethod CreateTool(name As %String) As AIHubStudio.AI.Tool
{
    Quit ##class(AIHubStudio.AI.Tool).Create(name)
}

/// Method: OpenTool
/// Description: Open an existing tool (convenience method)
ClassMethod OpenTool(name As %String) As AIHubStudio.AI.Tool
{
    Quit ##class(AIHubStudio.AI.Tool).Open(name)
}

/// Method: CreateToolSet
/// Description: Create a new toolset (convenience method)
ClassMethod CreateToolSet(name As %String) As AIHubStudio.AI.ToolSet
{
    Quit ##class(AIHubStudio.AI.ToolSet).Create(name)
}

/// Method: OpenToolSet
/// Description: Open an existing toolset (convenience method)
ClassMethod OpenToolSet(name As %String) As AIHubStudio.AI.ToolSet
{
    Quit ##class(AIHubStudio.AI.ToolSet).Open(name)
}

/// Method: CreateProvider
/// Description: Create a new provider (convenience method)
ClassMethod CreateProvider(name As %String, type As %String = "") As AIHubStudio.AI.Provider
{
    Quit ##class(AIHubStudio.AI.Provider).Create(name, type)
}

/// Method: OpenProvider
/// Description: Open an existing provider (convenience method)
ClassMethod OpenProvider(name As %String) As AIHubStudio.AI.Provider
{
    Quit ##class(AIHubStudio.AI.Provider).Open(name)
}

/// Method: CreateMCP
/// Description: Create a new MCP service (convenience method)
ClassMethod CreateMCP(name As %String) As AIHubStudio.AI.MCP
{
    Quit ##class(AIHubStudio.AI.MCP).Create(name)
}

/// Method: OpenMCP
/// Description: Open an existing MCP service (convenience method)
ClassMethod OpenMCP(name As %String) As AIHubStudio.AI.MCP
{
    Quit ##class(AIHubStudio.AI.MCP).Open(name)
}

/// Method: ListAll
/// Description: List all entities (agents, tools, toolsets, providers, MCP services)
ClassMethod ListAll() As %DynamicObject
{
    Set result = {}
    Set result.providers = ##class(%DynamicArray).%FromJSON(##class(AIHubStudio.Metadata.Provider).ListAll())
    Set result.agents = ##class(%DynamicArray).%FromJSON(##class(AIHubStudio.Metadata.Agent).ListAll())
    Set result.tools = ##class(%DynamicArray).%FromJSON(##class(AIHubStudio.Metadata.Tool).ListAll())
    Set result.toolSets = ##class(%DynamicArray).%FromJSON(##class(AIHubStudio.Metadata.ToolSet).ListAll())
    Set result.mcpServices = ##class(%DynamicArray).%FromJSON(##class(AIHubStudio.Metadata.MCP).ListAll())
    Quit result
}

/// Method: GetStats
/// Description: Get statistics about the AI Hub Studio configuration
ClassMethod GetStats() As %DynamicObject
{
    Set stats = {
        "providerCount": (..CountRows("Provider")),
        "agentCount": (..CountRows("Agent")),
        "toolCount": (..CountRows("Tool")),
        "toolSetCount": (..CountRows("ToolSet")),
        "mcpServiceCount": (..CountRows("MCP"))
    }
    
    Quit stats
}

ClassMethod CountRows(entity As %String) As %Integer
{
    Set table = $SELECT(
        entity="Provider":"AIHubStudio_Metadata.Provider",
        entity="Agent":"AIHubStudio_Metadata.Agent",
        entity="Tool":"AIHubStudio_Metadata.Tool",
        entity="ToolSet":"AIHubStudio_Metadata.ToolSet",
        entity="MCP":"AIHubStudio_Metadata.MCP",
        1:"")
    If table = "" Quit 0
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT COUNT(*) AS RowCount FROM " _ table)
    If $$$ISERR(sc) Quit 0
    Set result = stmt.%Execute()
    If result.%Next() Quit result.RowCount
    Quit 0
}

/// Method: DeleteAll
/// Description: Delete all metadata (WARNING: Destructive operation!)
ClassMethod DeleteAll() As %Status
{
    // This is a destructive operation - requires explicit confirmation
    // For safety, this method is intentionally not implemented
    // Users should delete entities individually
    
    Return $$$ERROR($$$GeneralError, "DeleteAll is not implemented for safety. Delete entities individually.")
}

/// Method: ExampleWorkflow
/// Description: Demonstrate the typical workflow with an example
ClassMethod ExampleWorkflow() As %Status
{
    Write !, "=== AI Hub Studio Metadata Framework Example Workflow ==="
    Write !
    
    // Create a provider
    Write !, "1. Creating provider..."
    Set provider = ##class(AIHubStudio.AI.Provider).Create("anthropic", "anthropic")
    Do provider.APIKeyFromEnvironment("ANTHROPIC_API_KEY")
    Do provider.DefaultModel("claude-3-sonnet")
    Do provider.Save()
    Write !, "   Provider 'anthropic' created."
    
    // Create a toolset
    Write !, !, "2. Creating toolset..."
    Set toolSet = ##class(AIHubStudio.AI.ToolSet).Create("CustomerTools")
    Do toolSet.Description("Tools for customer service operations")
    Do toolSet.Save()
    Write !, "   ToolSet 'CustomerTools' created."
    
    // Create tools
    Write !, !, "3. Creating tools..."
    Set tool1 = ##class(AIHubStudio.AI.Tool).Create("GetCustomer")
    Do tool1.Description("Find a customer by ID")
    Do tool1.Implementation("Sample.CustomerTools", "GetCustomer")
    Do tool1.Save()
    Write !, "   Tool 'GetCustomer' created."
    
    Set tool2 = ##class(AIHubStudio.AI.Tool).Create("SearchCustomer")
    Do tool2.Description("Search for customers by name or email")
    Do tool2.Implementation("Sample.CustomerTools", "SearchCustomer")
    Do tool2.Save()
    Write !, "   Tool 'SearchCustomer' created."
    
    // Add tools to toolset
    Write !, !, "4. Adding tools to toolset..."
    Do toolSet.AddTool("GetCustomer")
    Do toolSet.AddTool("SearchCustomer")
    Write !, "   Tools added to 'CustomerTools' toolset."
    
    // Create an agent
    Write !, !, "5. Creating agent..."
    Set agent = ##class(AIHubStudio.AI.Agent).Create("CustomerService")
    Do agent.Description("Customer service assistant")
    Do agent.Provider("anthropic")
    Do agent.Model("claude-3-sonnet")
    Do agent.Instructions("You are a helpful customer service assistant. Always be polite and helpful.")
    Do agent.AddToolSet("CustomerTools")
    Do agent.Save()
    Write !, "   Agent 'CustomerService' created."
    
    // Create an MCP service
    Write !, !, "6. Creating MCP service..."
    Set mcp = ##class(AIHubStudio.AI.MCP).Create("CustomerMCP")
    Do mcp.Description("MCP service for customer operations")
    Do mcp.ToolSet("CustomerTools")
    Do mcp.Enabled(1)
    Do mcp.Save()
    Write !, "   MCP service 'CustomerMCP' created."
    
    // Display what we created
    Write !, !, "7. Displaying created entities..."
    Write !
    Do provider.Show()
    Write !
    Do agent.Show()
    Write !
    Do toolSet.Show()
    Write !
    Do mcp.Show()
    
    // Get statistics
    Write !, !, "8. Statistics:"
    Set stats = ..GetStats()
    Write !, "   Providers: ", stats.providerCount
    Write !, "   Agents: ", stats.agentCount
    Write !, "   Tools: ", stats.toolCount
    Write !, "   ToolSets: ", stats.toolSetCount
    Write !, "   MCP Services: ", stats.mcpServiceCount
    
    Quit $$$OK
}

/// Method: QuickStart
/// Description: Quick setup with minimal configuration
ClassMethod QuickStart() As %Status
{
    Write !, "=== AI Hub Studio Quick Start ==="
    Write !
    
    // Check if already initialized
    If ..CountRows("Provider") > 0 {
        Write !, "Metadata framework already has data. Skipping initialization."
        Quit $$$OK
    }
    
    // Create a default provider
    Write !, "Creating default 'openai' provider..."
    Set provider = ##class(AIHubStudio.AI.Provider).Create("openai", "openai")
    Do provider.APIKeyFromEnvironment("OPENAI_API_KEY")
    Do provider.DefaultModel("gpt-4o-mini")
    Do provider.Save()
    
    // Create a default toolset
    Write !, "Creating default 'BasicTools' toolset..."
    Set toolSet = ##class(AIHubStudio.AI.ToolSet).Create("BasicTools")
    Do toolSet.Description("Basic tools for common operations")
    Do toolSet.Save()
    
    // Create a calculator tool
    Write !, "Creating 'Calculator' tool..."
    Set tool = ##class(AIHubStudio.AI.Tool).Create("Calculator")
    Do tool.Description("Evaluate mathematical expressions")
    Do tool.Implementation("AIHubStudio.Tool.Calculator", "Evaluate")
    Do tool.Save()
    Do toolSet.AddTool("Calculator")
    
    // Create a default agent
    Write !, "Creating default 'Assistant' agent..."
    Set agent = ##class(AIHubStudio.AI.Agent).Create("Assistant")
    Do agent.Description("General purpose AI assistant")
    Do agent.Provider("openai")
    Do agent.Model("gpt-4o-mini")
    Do agent.Instructions("You are a helpful AI assistant. Answer questions to the best of your ability.")
    Do agent.Save()
    Do agent.AddTool("Calculator")
    
    Write !, !, "Quick start completed!"
    Write !, "You can now use the AI Hub Studio framework."
    Write !, !, "Example usage:"
    Write !, "  Set a = ##class(AIHubStudio.AI.Agent).Open(""Assistant"")"
    Write !, "  Do a.Show()"
    
    Quit $$$OK
}

}
