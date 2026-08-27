/// Class: AIHubStudio.AI.ToolSet
/// Description: Facade API for ToolSet management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Simple API for managing AI toolsets from IRIS Terminal

Class AIHubStudio.AI.ToolSet Extends %RegisteredObject
{

/// Property: Metadata
/// Description: Reference to the underlying metadata object
Property Metadata As AIHubStudio.Metadata.ToolSet;

/// Property: Name
/// Description: Name of the toolset
Property Name As %String;

/// Property: Description
/// Description: Description of the toolset
Property Description As %String;

/// Property: Enabled
/// Description: Whether the toolset is enabled
Property Enabled As %Boolean;

/// Property: IsNew
/// Description: Flag indicating if this is a new unsaved toolset
Property IsNew As %Boolean [ InitialExpression = 1 ];

/// Method: Create
/// Description: Static method to create a new toolset
ClassMethod Create(name As %String) As AIHubStudio.AI.ToolSet
{
    Set toolSet = ..%New()
    Set toolSet.Name = name
    Set toolSet.Enabled = 1
    Set toolSet.IsNew = 1
    Quit toolSet
}

/// Method: Open
/// Description: Static method to open an existing toolset
ClassMethod Open(name As %String) As AIHubStudio.AI.ToolSet
{
    Set metadata = ##class(AIHubStudio.Metadata.ToolSet).GetByName(name)
    If '$ISOBJECT(metadata) {
        Quit $$$NULLOREF
    }
    
    Set toolSet = ..%New()
    Set toolSet.Metadata = metadata
    Set toolSet.Name = metadata.Name
    Set toolSet.Description = metadata.Description
    Set toolSet.Enabled = metadata.Enabled
    Set toolSet.IsNew = 0
    
    Quit toolSet
}

/// Method: Exists
/// Description: Check if a toolset exists
ClassMethod Exists(name As %String) As %Boolean
{
    Quit ##class(AIHubStudio.Metadata.ToolSet).Exists(name)
}

/// Method: List
/// Description: List all toolsets
ClassMethod List() As %String
{
    Quit ##class(AIHubStudio.Metadata.ToolSet).ListAll()
}

/// Method: Delete
/// Description: Delete a toolset
ClassMethod Delete(name As %String) As %Status
{
    Set metadata = ##class(AIHubStudio.Metadata.ToolSet).GetByName(name)
    If '$ISOBJECT(metadata) {
        Return $$$ERROR($$$GeneralError, "ToolSet '_name_' not found")
    }
    
    Set sc = ##class(AIHubStudio.Metadata.ToolSet).%Delete(metadata.%Oid())
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: Description
/// Description: Set the toolset description
Method Description(value As %String) As AIHubStudio.AI.ToolSet
{
    Set ..Description = value
    If '..IsNew {
        Set ..Metadata.Description = value
    }
    Quit $this
}

/// Method: Enabled
/// Description: Set whether the toolset is enabled
Method Enabled(value As %Boolean) As AIHubStudio.AI.ToolSet
{
    Set ..Enabled = value
    If '..IsNew {
        Set ..Metadata.Enabled = value
    }
    Quit $this
}

/// Method: AddTool
/// Description: Add a tool to this toolset
Method AddTool(toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before adding tools")
    }
    Quit ..Metadata.AddTool(toolName)
}

/// Method: RemoveTool
/// Description: Remove a tool from this toolset
Method RemoveTool(toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before removing tools")
    }
    Quit ..Metadata.RemoveTool(toolName)
}

/// Method: IncludeClass
/// Description: Include all tools from a class
Method IncludeClass(className As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before including classes")
    }
    Quit ..Metadata.IncludeClass(className)
}

/// Method: IncludeTool
/// Description: Include a specific tool from a class
Method IncludeTool(className As %String, toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before including tools")
    }
    Quit ..Metadata.IncludeTool(className, toolName)
}

/// Method: IncludeMatch
/// Description: Include tools matching a pattern
Method IncludeMatch(className As %String, pattern As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before including matches")
    }
    Quit ..Metadata.IncludeMatch(className, pattern)
}

/// Method: Exclude
/// Description: Exclude a tool
Method Exclude(toolName As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before excluding tools")
    }
    Quit ..Metadata.Exclude(toolName)
}

/// Method: ExcludeMatch
/// Description: Exclude tools matching a pattern
Method ExcludeMatch(pattern As %String) As %Status
{
    If ..IsNew {
        Return $$$ERROR($$$GeneralError, "Save toolset before excluding matches")
    }
    Quit ..Metadata.ExcludeMatch(pattern)
}

/// Method: Save
/// Description: Save the toolset
Method Save() As %Status
{
    // Validate
    Set sc = ..Validate()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Sync properties to metadata
    If ..IsNew {
        Set ..Metadata = ##class(AIHubStudio.Metadata.ToolSet).%New()
    }
    
    Set ..Metadata.Name = ..Name
    Set ..Metadata.Description = ..Description
    Set ..Metadata.Enabled = ..Enabled
    
    Set sc = ..Metadata.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Set ..IsNew = 0
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate toolset configuration
Method Validate() As %Status
{
    If ..Name = "" {
        Return $$$ERROR($$$GeneralError, "ToolSet name is required")
    }
    
    Quit $$$OK
}

/// Method: Show
/// Description: Display toolset information
Method Show() As %Status
{
    Write !, "ToolSet: ", ..Name
    If ..Description '= "" {
        Write !, "Description: ", ..Description
    }
    Write !, "Enabled: ", ..Enabled
    
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
    }
    
    Quit $$$OK
}

/// Method: GetMetadata
/// Description: Get the underlying metadata object
Method GetMetadata() As AIHubStudio.Metadata.ToolSet
{
    Quit ..Metadata
}

/// Method: ToJSON
/// Description: Export toolset as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "description": (..Description),
        "enabled": (..Enabled)
    }
    
    // Add tools if we have metadata
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

}
