/// Class: AIHubStudio.AI.Tool
/// Description: Facade API for Tool management
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0
/// Purpose: Simple API for managing AI tools from IRIS Terminal

Class AIHubStudio.AI.Tool Extends %RegisteredObject
{

/// Property: Metadata
/// Description: Reference to the underlying metadata object
Property Metadata As AIHubStudio.Metadata.Tool;

/// Property: Name
/// Description: Name of the tool
Property Name As %String;

/// Property: Description
/// Description: Description of the tool
Property Description As %String;

/// Property: ImplementationClass
/// Description: Class that implements this tool
Property ImplementationClass As %String;

/// Property: ImplementationMethod
/// Description: Method in the implementation class
Property ImplementationMethod As %String;

/// Property: Enabled
/// Description: Whether the tool is enabled
Property Enabled As %Boolean;

/// Property: IsNew
/// Description: Flag indicating if this is a new unsaved tool
Property IsNew As %Boolean [ InitialExpression = 1 ];

/// Method: Create
/// Description: Static method to create a new tool
ClassMethod Create(name As %String) As AIHubStudio.AI.Tool
{
    Set tool = ..%New()
    Set tool.Name = name
    Set tool.Enabled = 1
    Set tool.IsNew = 1
    Quit tool
}

/// Method: Open
/// Description: Static method to open an existing tool
ClassMethod Open(name As %String) As AIHubStudio.AI.Tool
{
    Set metadata = ##class(AIHubStudio.Metadata.Tool).GetByName(name)
    If '$ISOBJECT(metadata) {
        Quit $$$NULLOREF
    }
    
    Set tool = ..%New()
    Set tool.Metadata = metadata
    Set tool.Name = metadata.Name
    Set tool.Description = metadata.Description
    Set tool.ImplementationClass = metadata.ImplementationClass
    Set tool.ImplementationMethod = metadata.ImplementationMethod
    Set tool.Enabled = metadata.Enabled
    Set tool.IsNew = 0
    
    Quit tool
}

/// Method: Exists
/// Description: Check if a tool exists
ClassMethod Exists(name As %String) As %Boolean
{
    Quit ##class(AIHubStudio.Metadata.Tool).Exists(name)
}

/// Method: List
/// Description: List all tools
ClassMethod List() As %String
{
    Quit ##class(AIHubStudio.Metadata.Tool).ListAll()
}

/// Method: Delete
/// Description: Delete a tool
ClassMethod Delete(name As %String) As %Status
{
    Set metadata = ##class(AIHubStudio.Metadata.Tool).GetByName(name)
    If '$ISOBJECT(metadata) {
        Return $$$ERROR($$$GeneralError, "Tool '_name_' not found")
    }
    
    Set sc = metadata.%Delete()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: Description
/// Description: Set the tool description
Method Description(value As %String) As AIHubStudio.AI.Tool
{
    Set ..Description = value
    If '..IsNew {
        Set ..Metadata.Description = value
    }
    Quit $this
}

/// Method: Implementation
/// Description: Set the implementation class and method
Method Implementation(className As %String, methodName As %String) As AIHubStudio.AI.Tool
{
    Set ..ImplementationClass = className
    Set ..ImplementationMethod = methodName
    If '..IsNew {
        Set ..Metadata.ImplementationClass = className
        Set ..Metadata.ImplementationMethod = methodName
    }
    Quit $this
}

/// Method: Enabled
/// Description: Set whether the tool is enabled
Method Enabled(value As %Boolean) As AIHubStudio.AI.Tool
{
    Set ..Enabled = value
    If '..IsNew {
        Set ..Metadata.Enabled = value
    }
    Quit $this
}

/// Method: Save
/// Description: Save the tool
Method Save() As %Status
{
    // Validate
    Set sc = ..Validate()
    If $$$ISERR(sc) {
        Return sc
    }
    
    // Sync properties to metadata
    If ..IsNew {
        Set ..Metadata = ##class(AIHubStudio.Metadata.Tool).%New()
    }
    
    Set ..Metadata.Name = ..Name
    Set ..Metadata.Description = ..Description
    Set ..Metadata.ImplementationClass = ..ImplementationClass
    Set ..Metadata.ImplementationMethod = ..ImplementationMethod
    Set ..Metadata.Enabled = ..Enabled
    
    Set sc = ..Metadata.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Set ..IsNew = 0
    Quit $$$OK
}

/// Method: Validate
/// Description: Validate tool configuration
Method Validate() As %Status
{
    Set sc = $$$OK
    If ..Name = "" {
        Quit $$$ERROR($$$GeneralError, "Tool name is required")
    }
    Try {
        If ..ImplementationClass '= "" {
            If '##class(%Dictionary.CompiledClass).%ExistsId(..ImplementationClass) {
                Set sc = $$$ERROR($$$GeneralError, "Implementation class '" _ ..ImplementationClass _ "' not found or not accessible")
            } ElseIf ..ImplementationMethod '= "" {
                Set methodId = ..ImplementationClass _ "||" _ ..ImplementationMethod
                If '##class(%Dictionary.CompiledMethod).%ExistsId(methodId) {
                    Set sc = $$$ERROR($$$GeneralError, "Method '" _ ..ImplementationMethod _ "' not found in class '" _ ..ImplementationClass _ "'")
                }
            }
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

/// Method: Show
/// Description: Display tool information
Method Show() As %Status
{
    Write !, "Tool: ", ..Name
    If ..Description '= "" {
        Write !, "Description: ", ..Description
    }
    Write !, "Implementation: "
    If ..ImplementationClass '= "" {
        Write ..ImplementationClass
        If ..ImplementationMethod '= "" {
            Write "." _ ..ImplementationMethod
        }
    } Else {
        Write "(not configured)"
    }
    Write !, "Enabled: ", ..Enabled
    
    Quit $$$OK
}

/// Method: GetMetadata
/// Description: Get the underlying metadata object
Method GetMetadata() As AIHubStudio.Metadata.Tool
{
    Quit ..Metadata
}

/// Method: ToJSON
/// Description: Export tool as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "description": (..Description),
        "implementationClass": (..ImplementationClass),
        "implementationMethod": (..ImplementationMethod),
        "enabled": (..Enabled)
    }
    
    Quit obj.%ToJSON()
}

/// Method: Invoke
/// Description: Invoke the tool with parameters
Method Invoke(pParams As %DynamicObject) As %DynamicObject
{
    If '..IsNew && $ISOBJECT(..Metadata) {
        Quit ..Metadata.Invoke(pParams)
    }
    
    // For new unsaved tools, we can't invoke yet
    Quit {"error": "Tool must be saved before invocation"}
}

/// Method: GetToolInfo
/// Description: Get comprehensive tool information
Method GetToolInfo() As %DynamicObject
{
    If '..IsNew && $ISOBJECT(..Metadata) {
        Quit ..Metadata.GetToolInfo()
    }
    
    Set info = {
        "name": (..Name),
        "description": (..Description),
        "implementationClass": (..ImplementationClass),
        "implementationMethod": (..ImplementationMethod),
        "enabled": (..Enabled)
    }
    
    // Try to introspect parameters
    If ..ImplementationClass '= "" && ..ImplementationMethod '= "" {
        Try {
            // This would be enhanced with actual introspection
            Set info.parameters = []
            Set info.parameterSchema = {}
        } Catch ex {
            // Ignore introspection errors
        }
    }
    
    Quit info
}

}
