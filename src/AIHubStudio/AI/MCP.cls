/// Class: AIHubStudio.AI.MCP
/// Description: Facade API for MCP service management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Simple API for managing MCP services from IRIS Terminal

Class AIHubStudio.AI.MCP Extends %RegisteredObject
{

/// Property: Metadata
/// Description: Reference to the underlying metadata object
Property Metadata As AIHubStudio.Metadata.MCP;

/// Property: Name
/// Description: Name of the MCP service
Property Name As %String;

/// Property: Description
/// Description: Description of the MCP service
Property Description As %String;

/// Property: ToolSet
/// Description: ToolSet exposed by this MCP service
Property ToolSet As %String;

/// Property: Enabled
/// Description: Whether the MCP service is enabled
Property Enabled As %Boolean;

/// Property: Endpoint
/// Description: MCP endpoint path
Property Endpoint As %String;

/// Property: Port
/// Description: Port for MCP service
Property Port As %Integer;

/// Property: IsNew
/// Description: Flag indicating if this is a new unsaved MCP service
Property IsNew As %Boolean [ InitialExpression = 1 ];

/// Method: Create
/// Description: Static method to create a new MCP service
ClassMethod Create(name As %String) As AIHubStudio.AI.MCP
{
    Set mcp = ..%New()
    Set mcp.Name = name
    Set mcp.Enabled = 1
    Set mcp.IsNew = 1
    Quit mcp
}

/// Method: Open
/// Description: Static method to open an existing MCP service
ClassMethod Open(name As %String) As AIHubStudio.AI.MCP
{
    Set metadata = ##class(AIHubStudio.Metadata.MCP).GetByName(name)
    If '$ISOBJECT(metadata) {
        Quit $$$NULLOREF
    }
    
    Set mcp = ..%New()
    Set mcp.Metadata = metadata
    Set mcp.Name = metadata.Name
    Set mcp.Description = metadata.Description
    Set mcp.ToolSet = metadata.ToolSet
    Set mcp.Enabled = metadata.Enabled
    Set mcp.Endpoint = metadata.Endpoint
    Set mcp.Port = metadata.Port
    Set mcp.IsNew = 0
    
    Quit mcp
}

/// Method: Exists
/// Description: Check if an MCP service exists
ClassMethod Exists(name As %String) As %Boolean
{
    Quit ##class(AIHubStudio.Metadata.MCP).Exists(name)
}

/// Method: List
/// Description: List all MCP services
ClassMethod List() As %String
{
    Quit ##class(AIHubStudio.Metadata.MCP).ListAll()
}

/// Method: Delete
/// Description: Delete an MCP service
ClassMethod Delete(name As %String) As %Status
{
    Set metadata = ##class(AIHubStudio.Metadata.MCP).GetByName(name)
    If '$ISOBJECT(metadata) {
        Return $$$ERROR($$$GeneralError, "MCP service '_name_' not found")
    }
    
    Set sc = metadata.%Delete()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: Description
/// Description: Set the MCP service description
Method Description(value As %String) As AIHubStudio.AI.MCP
{
    Set ..Description = value
    If '..IsNew {
        Set ..Metadata.Description = value
    }
    Quit $this
}

/// Method: ToolSet
/// Description: Set the toolset for this MCP service
Method ToolSet(value As %String) As AIHubStudio.AI.MCP
{
    Set ..ToolSet = value
    If '..IsNew {
        Set ..Metadata.ToolSet = value
    }
    Quit $this
}

/// Method: Enabled
/// Description: Set whether the MCP service is enabled
Method Enabled(value As %Boolean) As AIHubStudio.AI.MCP
{
    Set ..Enabled = value
    If '..IsNew {
        Set ..Metadata.Enabled = value
    }
    Quit $this
}

/// Method: Endpoint
/// Description: Set the MCP endpoint
Method Endpoint(value As %String) As AIHubStudio.AI.MCP
{
    Set ..Endpoint = value
    If '..IsNew {
        Set ..Metadata.Endpoint = value
    }
    Quit $this
}

/// Method: Port
/// Description: Set the MCP port
Method Port(value As %Integer) As AIHubStudio.AI.MCP
{
    Set ..Port = value
    If '..IsNew {
        Set ..Metadata.Port = value
    }
    Quit $this
}

/// Method: Save
/// Description: Save the MCP service
Method Save() As %Status
{
    // Validate
    Set sc = ..Validate()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Sync properties to metadata
    If ..IsNew {
        Set ..Metadata = ##class(AIHubStudio.Metadata.MCP).%New()
    }
    
    Set ..Metadata.Name = ..Name
    Set ..Metadata.Description = ..Description
    Set ..Metadata.ToolSet = ..ToolSet
    Set ..Metadata.Enabled = ..Enabled
    Set ..Metadata.Endpoint = ..Endpoint
    Set ..Metadata.Port = ..Port
    
    Set sc = ..Metadata.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Set ..IsNew = 0
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate MCP service configuration
Method Validate() As %Status
{
    If ..Name = "" {
        Return $$$ERROR($$$GeneralError, "MCP service name is required")
    }
    
    // Check if toolset exists (if specified)
    If ..ToolSet '= "" {
        Set toolSet = ##class(AIHubStudio.Metadata.ToolSet).GetByName(..ToolSet)
        If '$ISOBJECT(toolSet) {
            Return $$$ERROR($$$GeneralError, "ToolSet '_..ToolSet_' not found")
        }
    }
    
    Quit $$$OK
}

/// Method: Show
/// Description: Display MCP service information
Method Show() As %Status
{
    Write !, "MCP Service: ", ..Name
    If ..Description '= "" {
        Write !, "Description: ", ..Description
    }
    Write !, "ToolSet: ", ..ToolSet
    Write !, "Enabled: ", ..Enabled
    If ..Endpoint '= "" {
        Write !, "Endpoint: ", ..Endpoint
    }
    If ..Port > 0 {
        Write !, "Port: ", ..Port
    }
    
    // Show exposed tools
    Set metadata = ..GetMetadata()
    If $ISOBJECT(metadata) {
        Set toolNames = metadata.GetToolNames()
        If toolNames.%Size() > 0 {
            Write !, !, "Exposed Tools:"
            For i = 0:1:(toolNames.%Size() - 1) {
                Write !, "  - ", toolNames.%Get(i)
            }
        }
    }
    
    Quit $$$OK
}

/// Method: GetMetadata
/// Description: Get the underlying metadata object
Method GetMetadata() As AIHubStudio.Metadata.MCP
{
    Quit ..Metadata
}

/// Method: ToJSON
/// Description: Export MCP service as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "description": (..Description),
        "toolSet": (..ToolSet),
        "enabled": (..Enabled),
        "endpoint": (..Endpoint),
        "port": (..Port)
    }
    
    // Add exposed tools if we have metadata
    If $ISOBJECT(..Metadata) {
        Set toolNames = ..Metadata.GetToolNames()
        Set toolsArray = []
        For i = 0:1:(toolNames.%Size() - 1) {
            Do toolsArray.%Push(toolNames.%Get(i))
        }
        Set obj.tools = toolsArray
    }
    
    Quit obj.%ToJSON()
}

/// Method: ExposeToolSet
/// Description: Convenience method to create an MCP service that exposes a toolset
ClassMethod ExposeToolSet(name As %String, toolSetName As %String) As %Status
{
    // Create or get the MCP service
    Set mcp = ##class(AIHubStudio.AI.MCP).Create(name)
    Do mcp.ToolSet(toolSetName)
    Do mcp.Enabled(1)
    
    // Save it
    Set sc = mcp.Save()
    Quit sc
}

}
