/// Class: AIHubStudio.AI.Agent
/// Description: Facade API for Agent management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Simple API for managing AI agents from IRIS Terminal

Class AIHubStudio.AI.Agent Extends %RegisteredObject
{

/// Property: Metadata
/// Description: Reference to the underlying metadata object
Property Metadata As AIHubStudio.Metadata.Agent;

/// Property: Name
/// Description: Name of the agent
Property Name As %String;

/// Property: Package
/// Description: Package namespace for generated classes
Property Package As %String;

/// Property: Description
/// Description: Description of the agent
Property Description As %String;

/// Property: Provider
/// Description: Provider to use for this agent
Property Provider As %String;

/// Property: Model
/// Description: Model to use for this agent
Property Model As %String;

/// Property: Instructions
/// Description: System instructions for the agent
Property Instructions As %String;

/// Property: Temperature
/// Description: Temperature setting
Property Temperature As %Float;

/// Property: MaxTokens
/// Description: Maximum tokens for responses
Property MaxTokens As %Integer;

/// Property: Enabled
/// Description: Whether the agent is enabled
Property Enabled As %Boolean;

/// Property: IsNew
/// Description: Flag indicating if this is a new unsaved agent
Property IsNew As %Boolean [ InitialExpression = 1 ];

/// Method: Create
/// Description: Static method to create a new agent
ClassMethod Create(name As %String) As AIHubStudio.AI.Agent
{
    Set agent = ..%New()
    Set agent.Name = name
    Set agent.Enabled = 1
    Set agent.IsNew = 1
    Quit agent
}

/// Method: Open
/// Description: Static method to open an existing agent
ClassMethod Open(name As %String) As AIHubStudio.AI.Agent
{
    Set metadata = ##class(AIHubStudio.Metadata.Agent).GetByName(name)
    If '$ISOBJECT(metadata) {
        Quit $$$NULLOREF
    }
    
    Set agent = ..%New()
    Set agent.Metadata = metadata
    Set agent.Name = metadata.Name
    Set agent.Package = metadata.Package
    Set agent.Description = metadata.Description
    Set agent.Provider = metadata.Provider
    Set agent.Model = metadata.Model
    Set agent.Instructions = metadata.Instructions
    Set agent.Temperature = metadata.Temperature
    Set agent.MaxTokens = metadata.MaxTokens
    Set agent.Enabled = metadata.Enabled
    Set agent.IsNew = 0
    
    Quit agent
}

/// Method: Exists
/// Description: Check if an agent exists
ClassMethod Exists(name As %String) As %Boolean
{
    Quit ##class(AIHubStudio.Metadata.Agent).Exists(name)
}

/// Method: List
/// Description: List all agents
ClassMethod List() As %String
{
    Quit ##class(AIHubStudio.Metadata.Agent).ListAll()
}

/// Method: Delete
/// Description: Delete an agent
ClassMethod Delete(name As %String) As %Status
{
    Set metadata = ##class(AIHubStudio.Metadata.Agent).GetByName(name)
    If '$ISOBJECT(metadata) {
        Return $$$ERROR($$$GeneralError, "Agent '_name_' not found")
    }
    
    Set sc = metadata.%Delete()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: Description
/// Description: Set the agent description
Method Description(value As %String) As AIHubStudio.AI.Agent
{
    Set ..Description = value
    If '..IsNew {
        Set ..Metadata.Description = value
    }
    Quit $this
}

/// Method: Package
/// Description: Set the package namespace
Method Package(value As %String) As AIHubStudio.AI.Agent
{
    Set ..Package = value
    If '..IsNew {
        Set ..Metadata.Package = value
    }
    Quit $this
}

/// Method: Provider
/// Description: Set the provider for this agent
Method Provider(value As %String) As AIHubStudio.AI.Agent
{
    Set ..Provider = value
    If '..IsNew {
        Set ..Metadata.Provider = value
    }
    Quit $this
}

/// Method: Model
/// Description: Set the model for this agent
Method Model(value As %String) As AIHubStudio.AI.Agent
{
    Set ..Model = value
    If '..IsNew {
        Set ..Metadata.Model = value
    }
    Quit $this
}

/// Method: Instructions
/// Description: Set the instructions for this agent
Method Instructions(value As %String) As AIHubStudio.AI.Agent
{
    Set ..Instructions = value
    If '..IsNew {
        Set ..Metadata.Instructions = value
    }
    Quit $this
}

/// Method: Temperature
/// Description: Set the temperature
Method Temperature(value As %Float) As AIHubStudio.AI.Agent
{
    Set ..Temperature = value
    If '..IsNew {
        Set ..Metadata.Temperature = value
    }
    Quit $this
}

/// Method: MaxTokens
/// Description: Set the max tokens
Method MaxTokens(value As %Integer) As AIHubStudio.AI.Agent
{
    Set ..MaxTokens = value
    If '..IsNew {
        Set ..Metadata.MaxTokens = value
    }
    Quit $this
}

/// Method: Enabled
/// Description: Set whether the agent is enabled
Method Enabled(value As %Boolean) As AIHubStudio.AI.Agent
{
    Set ..Enabled = value
    If '..IsNew {
        Set ..Metadata.Enabled = value
    }
    Quit $this
}

/// Method: AddTool
/// Description: Add a tool to this agent
Method AddTool(toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save agent before adding tools")
    }
    Quit ..Metadata.AddTool(toolName)
}

/// Method: AddToolSet
/// Description: Add a toolset to this agent
Method AddToolSet(toolSetName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save agent before adding toolsets")
    }
    Quit ..Metadata.AddToolSet(toolSetName)
}

/// Method: RemoveTool
/// Description: Remove a tool from this agent
Method RemoveTool(toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save agent before removing tools")
    }
    Quit ..Metadata.RemoveTool(toolName)
}

/// Method: RemoveToolSet
/// Description: Remove a toolset from this agent
Method RemoveToolSet(toolSetName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save agent before removing toolsets")
    }
    Quit ..Metadata.RemoveToolSet(toolSetName)
}

/// Method: Save
/// Description: Save the agent
Method Save() As %Status
{
    // Validate
    Set sc = ..Validate()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Sync properties to metadata
    If ..IsNew {
        Set ..Metadata = ##class(AIHubStudio.Metadata.Agent).%New()
    }
    
    Set ..Metadata.Name = ..Name
    Set ..Metadata.Package = ..Package
    Set ..Metadata.Description = ..Description
    Set ..Metadata.Provider = ..Provider
    Set ..Metadata.Model = ..Model
    Set ..Metadata.Instructions = ..Instructions
    Set ..Metadata.Temperature = ..Temperature
    Set ..Metadata.MaxTokens = ..MaxTokens
    Set ..Metadata.Enabled = ..Enabled
    
    Set sc = ..Metadata.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Set ..IsNew = 0
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate agent configuration
Method Validate() As %Status
{
    If ..Name = "" {
        Return $$$ERROR($$$GeneralError, "Agent name is required")
    }
    
    // Check if provider exists (if specified)
    If ..Provider '= "" {
        Set provider = ##class(AIHubStudio.Metadata.Provider).GetByName(..Provider)
        If '$ISOBJECT(provider) {
            Return $$$ERROR($$$GeneralError, "Provider '_..Provider_' not found")
        }
    }
    
    Quit $$$OK
}

/// Method: Show
/// Description: Display agent information
Method Show() As %Status
{
    Write !, "Agent: ", ..Name
    If ..Package '= "" {
        Write !, "Package: ", ..Package
    }
    If ..Description '= "" {
        Write !, "Description: ", ..Description
    }
    Write !, "Provider: ", ..Provider
    Write !, "Model: ", ..Model
    Write !, "Enabled: ", ..Enabled
    
    If ..Instructions '= "" {
        Write !, !, "Instructions:"
        Write !, ..Instructions
    }
    
    // Show tools
    Set metadata = ..GetMetadata()
    If $ISOBJECT(metadata) {
        Set toolNames = metadata.GetToolNames()
        If toolNames.%Size() > 0 {
            Write !, !, "Tools:"
            For i = 0:1:(toolNames.%Size() - 1) {
                Write !, "  - ", toolNames.%Get(i)
            }
        }
        
        // Show toolsets
        Set toolSetNames = metadata.GetToolSetNames()
        If toolSetNames.%Size() > 0 {
            Write !, !, "ToolSets:"
            For i = 0:1:(toolSetNames.%Size() - 1) {
                Write !, "  - ", toolSetNames.%Get(i)
            }
        }
    }
    
    Quit $$$OK
}

/// Method: GetMetadata
/// Description: Get the underlying metadata object
Method GetMetadata() As AIHubStudio.Metadata.Agent
{
    Quit ..Metadata
}

/// Method: ToJSON
/// Description: Export agent as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "package": (..Package),
        "description": (..Description),
        "provider": (..Provider),
        "model": (..Model),
        "instructions": (..Instructions),
        "enabled": (..Enabled)
    }
    
    // Add tools and toolsets if we have metadata
    If $ISOBJECT(..Metadata) {
        Set toolNames = ..Metadata.GetToolNames()
        Set toolsArray = []
        For i = 0:1:(toolNames.%Size() - 1) {
            Do toolsArray.%Push(toolNames.%Get(i))
        }
        Set obj.tools = toolsArray
        
        Set toolSetNames = ..Metadata.GetToolSetNames()
        Set toolSetsArray = []
        For i = 0:1:(toolSetNames.%Size() - 1) {
            Do toolSetsArray.%Push(toolSetNames.%Get(i))
        }
        Set obj.toolSets = toolSetsArray
    }
    
    Quit obj.%ToJSON()
}

/// Method: GetProviderInfo
/// Description: Get provider information for this agent
Method GetProviderInfo() As %DynamicObject
{
    If ..Provider = "" {
        Quit {}
    }
    
    Set provider = ##class(AIHubStudio.Metadata.Provider).GetByName(..Provider)
    If $ISOBJECT(provider) {
        Quit provider.GetProviderInfo()
    }
    
    Quit {}
}

}
