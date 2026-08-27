/// Class: AIHubStudio.Metadata.ToolSet
/// Description: Persistent toolset definition for AI Hub
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.ToolSet Extends %Persistent
{

/// Property: Name
/// Description: Unique name of the toolset
Property Name As %String(MAXLEN = 100) [ Required ];

/// Property: Description
/// Description: Description of the toolset
Property Description As %String(MAXLEN = 1000);

/// Property: Enabled
/// Description: Whether this toolset is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Property: CreatedAt
/// Description: When this toolset was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Property: UpdatedAt
/// Description: When this toolset was last updated
Property UpdatedAt As %TimeStamp;

/// Index: NameIndex
/// Description: Unique index on Name
Index NameIndex On Name [ Unique, PrimaryKey ];

/// Index: EnabledIndex
/// Description: Index on Enabled for filtering
Index EnabledIndex On Enabled;

/// Method: OnBeforeSave
/// Description: Update timestamp before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    Set sc = ..Validate()
    If $$$ISERR(sc) Quit sc
    Set ..UpdatedAt = $ZDATETIME($HOROLOG, 3)
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

/// Method: GetToolNames
/// Description: Get list of tool names in this toolset
Method GetToolNames() As %DynamicArray
{
    Set toolNames = []
    If ..%Id() = "" Quit toolNames
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT T.Name FROM AIHubStudio_Metadata.ToolSetTool TST JOIN AIHubStudio_Metadata.Tool T ON TST.Tool = T.ID WHERE TST.ToolSet = ? ORDER BY T.Name")
    If $$$ISERR(sc) Quit toolNames
    Set rs = stmt.%Execute(..%Id())
    While rs.%Next() {
        Do toolNames.%Push(rs.Name)
    }
    Quit toolNames
}

Method FindTool(toolId As %String) As AIHubStudio.Metadata.ToolSetTool
{
    Set link = $$$NULLOREF
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT ID FROM AIHubStudio_Metadata.ToolSetTool WHERE ToolSet = ? AND Tool = ?")
    If $$$ISERR(sc) Quit link
    Set rs = stmt.%Execute(..%Id(), toolId)
    If rs.%Next() {
        Set link = ##class(AIHubStudio.Metadata.ToolSetTool).%OpenId(rs.ID)
    }
    Quit link
}

/// Method: AddTool
/// Description: Add a tool to this toolset by name
Method AddTool(pToolName As %String) As %Status
{
    // Check if tool exists
    Set tool = ##class(AIHubStudio.Metadata.Tool).GetByName(pToolName)
    If '$ISOBJECT(tool) {
        Return $$$ERROR($$$GeneralError, "Tool '_pToolName_' not found")
    }
    
    // Check if already added
    Set existing = ..FindTool(tool.%Id())
    If $ISOBJECT(existing) {
        Quit $$$OK // Already exists
    }
    
    // Create new ToolSetTool relationship
    Set toolSetTool = ##class(AIHubStudio.Metadata.ToolSetTool).%New()
    Set toolSetTool.ToolSet = $this
    Set toolSetTool.Tool = tool
    Set sc = toolSetTool.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: RemoveTool
/// Description: Remove a tool from this toolset
Method RemoveTool(pToolName As %String) As %Status
{
    // Find and delete ToolSetTool relationship
    Set tool = ##class(AIHubStudio.Metadata.Tool).GetByName(pToolName)
    If '$ISOBJECT(tool) Quit $$$OK
    Set toolSetTool = ..FindTool(tool.%Id())
    If $ISOBJECT(toolSetTool) {
        Set sc = toolSetTool.%Delete()
        If $$$ISERR(sc) {
            Return sc
        }
    }
    
    Quit $$$OK
}

/// Method: IncludeClass
/// Description: Add all tools from a class to this toolset
Method IncludeClass(pClassName As %String) As %Status
{
    Set sc = $$$OK
    // Get all methods from the class that could be tools
    // This is a simplified implementation
    // In production, we'd use more sophisticated introspection
    
    Try {
        // For now, we'll just store the class name as a special tool entry
        // A real implementation would introspect the class and add each method
        
        // Create a placeholder tool for the class
        Set toolName = "Class_" _ pClassName
        Set tool = ##class(AIHubStudio.Metadata.Tool).GetByName(toolName)
        
        If '$ISOBJECT(tool) {
            // Create a new tool for the class
            Set tool = ##class(AIHubStudio.Metadata.Tool).%New()
            Set tool.Name = toolName
            Set tool.Description = "Tools from class " _ pClassName
            Set tool.ImplementationClass = pClassName
            Set tool.ImplementationMethod = ""
            Set sc = tool.%Save()
            $$$ThrowOnError(sc)
        }
        
        // Add the tool to this toolset
        Set sc = ..AddTool(toolName)
        $$$ThrowOnError(sc)
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

/// Method: IncludeTool
/// Description: Add a specific tool from a class to this toolset
Method IncludeTool(pClassName As %String, pToolName As %String) As %Status
{
    // Check if the tool exists
    Set tool = ##class(AIHubStudio.Metadata.Tool).GetByImplementation(pClassName, pToolName)
    
    If '$ISOBJECT(tool) {
        // Create a new tool
        Set tool = ##class(AIHubStudio.Metadata.Tool).%New()
        Set tool.Name = pClassName _ "." _ pToolName
        Set tool.Description = "Tool " _ pToolName _ " from class " _ pClassName
        Set tool.ImplementationClass = pClassName
        Set tool.ImplementationMethod = pToolName
        Set sc = tool.%Save()
        If $$$ISERR(sc) {
            Return sc
        }
    }
    
    // Add the tool to this toolset
    Set sc = ..AddTool(tool.Name)
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: IncludeMatch
/// Description: Add tools matching a pattern from a class
Method IncludeMatch(pClassName As %String, pPattern As %String) As %Status
{
    // This would introspect the class and add methods matching the pattern
    // For now, we'll just store the pattern as metadata
    // A real implementation would use regex matching on method names
    
    // For simplicity, we'll just include the class for now
    Quit ..IncludeClass(pClassName)
}

/// Method: Exclude
/// Description: Exclude a specific tool from this toolset
Method Exclude(pToolName As %String) As %Status
{
    Quit ..RemoveTool(pToolName)
}

/// Method: ExcludeMatch
/// Description: Exclude tools matching a pattern
Method ExcludeMatch(pPattern As %String) As %Status
{
    // Get all tools in this toolset
    Set toolNames = ..GetToolNames()
    
    // Remove tools matching the pattern
    // This is a simplified implementation
    For i = 0:1:(toolNames.%Size() - 1) {
        Set toolName = toolNames.%Get(i)
        If toolName [ pPattern {
            Do ..RemoveTool(toolName)
        }
    }
    
    Quit $$$OK
}

/// Method: ToJSON
/// Description: Export toolset as JSON
Method ToJSON() As %String
{
    Set obj = {
        "name": (..Name),
        "description": (..Description),
        "enabled": (..Enabled),
        "createdAt": (..CreatedAt),
        "updatedAt": (..UpdatedAt)
    }
    
    // Add tool names
    Set toolNames = ..GetToolNames()
    Set toolsArray = []
    For i = 0:1:(toolNames.%Size() - 1) {
        Do toolsArray.%Push(toolNames.%Get(i))
    }
    Set obj.tools = toolsArray
    
    Quit obj.%ToJSON()
}

/// Method: Show
/// Description: Display toolset information
Method Show() As %Status
{
    Write !, "ToolSet: ", ..Name
    Write !, "Description: ", ..Description
    Write !, "Enabled: ", ..Enabled
    Write !, "Created: ", ..CreatedAt
    Write !, "Updated: ", ..UpdatedAt
    
    // Show tools
    Set toolNames = ..GetToolNames()
    If toolNames.%Size() > 0 {
        Write !, !, "Tools:"
        For i = 0:1:(toolNames.%Size() - 1) {
            Write !, "  - ", toolNames.%Get(i)
        }
    }
    
    Quit $$$OK
}

/// ClassMethod: GetByName
/// Description: Get toolset by name
ClassMethod GetByName(pName As %String) As AIHubStudio.Metadata.ToolSet
{
    Set toolSet = $$$NULLOREF
    Try {
        Set toolSet = ##class(AIHubStudio.Metadata.ToolSet).NameIndexOpen(pName)
    } Catch ex {
        Set toolSet = $$$NULLOREF
    }
    Quit toolSet
}

/// ClassMethod: ListAll
/// Description: List all toolsets as JSON array
ClassMethod ListAll() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, Enabled FROM AIHubStudio_Metadata.ToolSet ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "enabled": (result.Enabled)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: ListEnabled
/// Description: List all enabled toolsets
ClassMethod ListEnabled() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description FROM AIHubStudio_Metadata.ToolSet WHERE Enabled = 1 ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: Exists
/// Description: Check if a toolset exists
ClassMethod Exists(pName As %String) As %Boolean
{
    Set toolSet = ..GetByName(pName)
    Quit $ISOBJECT(toolSet)
}

Storage Default
{
<Data name="ToolSetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>Enabled</Value>
</Value>
<Value name="5">
<Value>CreatedAt</Value>
</Value>
<Value name="6">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Metadata.ToolSetD</DataLocation>
<DefaultData>ToolSetDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Metadata.ToolSetD</IdLocation>
<IndexLocation>^AIHubStudio.Metadata.ToolSetI</IndexLocation>
<StreamLocation>^AIHubStudio.Metadata.ToolSetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
