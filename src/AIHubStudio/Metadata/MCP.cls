/// Class: AIHubStudio.Metadata.MCP
/// Description: Persistent MCP service configuration for AI Hub
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.MCP Extends %Persistent
{

/// Property: Name
/// Description: Unique name of the MCP service
Property Name As %String(MAXLEN = 100) [ Required ];

/// Property: Description
/// Description: Description of the MCP service
Property Description As %String(MAXLEN = 1000);

/// Property: ToolSet
/// Description: ToolSet exposed by this MCP service
Property ToolSet As %String(MAXLEN = 100);

/// Property: Enabled
/// Description: Whether this MCP service is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Property: Endpoint
/// Description: MCP endpoint path (optional)
Property Endpoint As %String(MAXLEN = 500);

/// Property: Port
/// Description: Port for MCP service (optional)
Property Port As %Integer;

/// Property: CreatedAt
/// Description: When this MCP service was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Property: UpdatedAt
/// Description: When this MCP service was last updated
Property UpdatedAt As %TimeStamp;

/// Index: NameIndex
/// Description: Unique index on Name
Index NameIndex On Name [ Unique, PrimaryKey ];

/// Index: ToolSetIndex
/// Description: Index on ToolSet for filtering
Index ToolSetIndex On ToolSet;

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
/// Description: Validate MCP configuration
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

/// Method: GetToolSet
/// Description: Get the ToolSet object for this MCP service
Method GetToolSet() As AIHubStudio.Metadata.ToolSet
{
    If ..ToolSet = "" {
        Quit $$$NULLOREF
    }
    Quit ##class(AIHubStudio.Metadata.ToolSet).GetByName(..ToolSet)
}

/// Method: GetToolNames
/// Description: Get list of tool names exposed by this MCP service
Method GetToolNames() As %DynamicArray
{
    Set toolNames = []
    
    // Get toolset
    Set toolSet = ..GetToolSet()
    If $ISOBJECT(toolSet) {
        Set toolNames = toolSet.GetToolNames()
    }
    
    Quit toolNames
}

/// Method: SetToolSet
/// Description: Set the toolset for this MCP service
Method SetToolSet(pToolSetName As %String) As %Status
{
    // Validate toolset exists
    Set toolSet = ##class(AIHubStudio.Metadata.ToolSet).GetByName(pToolSetName)
    If '$ISOBJECT(toolSet) {
        Return $$$ERROR($$$GeneralError, "ToolSet '_pToolSetName_' not found")
    }
    
    Set ..ToolSet = pToolSetName
    Quit $$$OK
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
        "port": (..Port),
        "createdAt": (..CreatedAt),
        "updatedAt": (..UpdatedAt)
    }
    
    Quit obj.%ToJSON()
}

/// Method: Show
/// Description: Display MCP service information
Method Show() As %Status
{
    Write !, "MCP Service: ", ..Name
    Write !, "Description: ", ..Description
    Write !, "ToolSet: ", ..ToolSet
    Write !, "Enabled: ", ..Enabled
    Write !, "Endpoint: ", ..Endpoint
    Write !, "Port: ", ..Port
    Write !, "Created: ", ..CreatedAt
    Write !, "Updated: ", ..UpdatedAt
    
    // Show tools from toolset
    Set toolNames = ..GetToolNames()
    If toolNames.%Size() > 0 {
        Write !, !, "Exposed Tools:"
        For i = 0:1:(toolNames.%Size() - 1) {
            Write !, "  - ", toolNames.%Get(i)
        }
    }
    
    Quit $$$OK
}

/// ClassMethod: GetByName
/// Description: Get MCP service by name
ClassMethod GetByName(pName As %String) As AIHubStudio.Metadata.MCP
{
    Set mcp = $$$NULLOREF
    Try {
        Set mcp = ##class(AIHubStudio.Metadata.MCP).NameIndexOpen(pName)
    } Catch ex {
        Set mcp = $$$NULLOREF
    }
    Quit mcp
}

/// ClassMethod: ListAll
/// Description: List all MCP services as JSON array
ClassMethod ListAll() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, ToolSet, Enabled, Endpoint, Port FROM AIHubStudio_Metadata.MCP ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "toolSet": (result.ToolSet),
            "enabled": (result.Enabled),
            "endpoint": (result.Endpoint),
            "port": (result.Port)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: ListEnabled
/// Description: List all enabled MCP services
ClassMethod ListEnabled() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, ToolSet, Endpoint, Port FROM AIHubStudio_Metadata.MCP WHERE Enabled = 1 ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "toolSet": (result.ToolSet),
            "endpoint": (result.Endpoint),
            "port": (result.Port)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: Exists
/// Description: Check if an MCP service exists
ClassMethod Exists(pName As %String) As %Boolean
{
    Set mcp = ..GetByName(pName)
    Quit $ISOBJECT(mcp)
}

Storage Default
{
<Data name="MCPDefaultData">
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
<Value>ToolSet</Value>
</Value>
<Value name="5">
<Value>Enabled</Value>
</Value>
<Value name="6">
<Value>Endpoint</Value>
</Value>
<Value name="7">
<Value>Port</Value>
</Value>
<Value name="8">
<Value>CreatedAt</Value>
</Value>
<Value name="9">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Metadata.MCPD</DataLocation>
<DefaultData>MCPDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Metadata.MCPD</IdLocation>
<IndexLocation>^AIHubStudio.Metadata.MCPI</IndexLocation>
<StreamLocation>^AIHubStudio.Metadata.MCPS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
