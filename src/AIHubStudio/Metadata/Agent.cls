/// Class: AIHubStudio.Metadata.Agent
/// Description: Persistent agent definition for AI Hub
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.Agent Extends %Persistent
{

/// Property: Name
/// Description: Unique name of the agent
Property Name As %String(MAXLEN = 100) [ Required ];

/// Property: Package
/// Description: Package namespace for generated classes (optional)
Property Package As %String(MAXLEN = 200);

/// Property: Description
/// Description: Description of the agent's purpose
Property Description As %String(MAXLEN = 500);

/// Property: Provider
/// Description: Provider to use for this agent
Property Provider As %String(MAXLEN = 100);

/// Property: Model
/// Description: Model to use for this agent
Property Model As %String(MAXLEN = 200);

/// Property: Instructions
/// Description: System instructions for the agent
Property Instructions As %String(MAXLEN = 100000);

/// Property: Temperature
/// Description: Temperature setting (optional)
Property Temperature As %Float;

/// Property: MaxTokens
/// Description: Maximum tokens for responses (optional)
Property MaxTokens As %Integer;

/// Property: Enabled
/// Description: Whether this agent is enabled
Property Enabled As %Boolean [ InitialExpression = 1 ];

/// Property: CreatedAt
/// Description: When this agent was created
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

/// Property: UpdatedAt
/// Description: When this agent was last updated
Property UpdatedAt As %TimeStamp;

/// Index: NameIndex
/// Description: Unique index on Name
Index NameIndex On Name [ Unique, PrimaryKey ];

/// Index: ProviderIndex
/// Description: Index on Provider for filtering
Index ProviderIndex On Provider;

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
        If 'provider.Enabled {
            Return $$$ERROR($$$GeneralError, "Provider '_..Provider_' is disabled")
        }
    }
    
    Quit $$$OK
}

/// Method: GetProvider
/// Description: Get the provider object for this agent
Method GetProvider() As AIHubStudio.Metadata.Provider
{
    If ..Provider = "" {
        Quit $$$NULLOREF
    }
    Quit ##class(AIHubStudio.Metadata.Provider).GetByName(..Provider)
}

/// Method: GetToolNames
/// Description: Get list of tool names associated with this agent
Method GetToolNames() As %DynamicArray
{
    Set toolNames = []
    If ..%Id() = "" Quit toolNames
    Set sql = "SELECT DISTINCT T.Name FROM AIHubStudio_Metadata.AgentTool AgentToolLink " _
              "JOIN AIHubStudio_Metadata.Tool T ON AgentToolLink.Tool = T.ID WHERE AgentToolLink.Agent = ? " _
              "UNION SELECT DISTINCT T.Name FROM AIHubStudio_Metadata.AgentToolSet ATS " _
              "JOIN AIHubStudio_Metadata.ToolSetTool TST ON ATS.ToolSet = TST.ToolSet " _
              "JOIN AIHubStudio_Metadata.Tool T ON TST.Tool = T.ID WHERE ATS.Agent = ?"
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) Quit toolNames
    Set rs = stmt.%Execute(..%Id(), ..%Id())
    While rs.%Next() {
        Do toolNames.%Push(rs.Name)
    }
    Quit toolNames
}

Method GetToolSetNames() As %DynamicArray
{
    Set toolSetNames = []
    If ..%Id() = "" Quit toolSetNames
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TS.Name FROM AIHubStudio_Metadata.AgentToolSet ATS JOIN AIHubStudio_Metadata.ToolSet TS ON ATS.ToolSet = TS.ID WHERE ATS.Agent = ? ORDER BY TS.Name")
    If $$$ISERR(sc) Quit toolSetNames
    Set rs = stmt.%Execute(..%Id())
    While rs.%Next() {
        Do toolSetNames.%Push(rs.Name)
    }
    Quit toolSetNames
}

ClassMethod ArrayContains(values As %DynamicArray, value As %String) As %Boolean
{
    For i = 0:1:(values.%Size() - 1) {
        If values.%Get(i) = value 
        Return 1
    }
    Return 0
}

Method FindAgentTool(toolId As %String) As AIHubStudio.Metadata.AgentTool
{
    Set link = $$$NULLOREF
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT ID FROM AIHubStudio_Metadata.AgentTool WHERE Agent = ? AND Tool = ?")
    If $$$ISERR(sc) Quit link
    Set rs = stmt.%Execute(..%Id(), toolId)
    If rs.%Next() {
        Set link = ##class(AIHubStudio.Metadata.AgentTool).%OpenId(rs.ID)
    }
    Quit link
}

Method FindAgentToolSet(toolSetId As %String) As AIHubStudio.Metadata.AgentToolSet
{
    Set link = $$$NULLOREF
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT ID FROM AIHubStudio_Metadata.AgentToolSet WHERE Agent = ? AND ToolSet = ?")
    If $$$ISERR(sc) Quit link
    Set rs = stmt.%Execute(..%Id(), toolSetId)
    If rs.%Next() {
        Set link = ##class(AIHubStudio.Metadata.AgentToolSet).%OpenId(rs.ID)
    }
    Quit link
}

/// Method: AddTool
/// Description: Add a tool to this agent by name
Method AddTool(pToolName As %String) As %Status
{
    // Check if tool exists
    Set tool = ##class(AIHubStudio.Metadata.Tool).GetByName(pToolName)
    If '$ISOBJECT(tool) {
        Return $$$ERROR($$$GeneralError, "Tool '_pToolName_' not found")
    }
    
    // Check if already added
    Set existing = ..FindAgentTool(tool.%Id())
    If $ISOBJECT(existing) {
        Quit $$$OK // Already exists
    }
    
    // Create new AgentTool relationship
    Set agentTool = ##class(AIHubStudio.Metadata.AgentTool).%New()
    Set agentTool.Agent = $this
    Set agentTool.Tool = tool
    Set sc = agentTool.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: RemoveTool
/// Description: Remove a tool from this agent
Method RemoveTool(pToolName As %String) As %Status
{
    // Find and delete AgentTool relationship
    Set tool = ##class(AIHubStudio.Metadata.Tool).GetByName(pToolName)
    If '$ISOBJECT(tool) Quit $$$OK
    Set agentTool = ..FindAgentTool(tool.%Id())
    If $ISOBJECT(agentTool) {
        Set sc = agentTool.%Delete()
        If $$$ISERR(sc) {
            Return sc
        }
    }
    
    Quit $$$OK
}

/// Method: AddToolSet
/// Description: Add a toolset to this agent
Method AddToolSet(pToolSetName As %String) As %Status
{
    // Check if toolset exists
    Set toolSet = ##class(AIHubStudio.Metadata.ToolSet).GetByName(pToolSetName)
    If '$ISOBJECT(toolSet) {
        Return $$$ERROR($$$GeneralError, "ToolSet '_pToolSetName_' not found")
    }
    
    // Check if already added
    Set existing = ..FindAgentToolSet(toolSet.%Id())
    If $ISOBJECT(existing) {
        Quit $$$OK // Already exists
    }
    
    // Create new AgentToolSet relationship
    Set agentToolSet = ##class(AIHubStudio.Metadata.AgentToolSet).%New()
    Set agentToolSet.Agent = $this
    Set agentToolSet.ToolSet = toolSet
    Set sc = agentToolSet.%Save()
    If $$$ISERR(sc) {
        Return sc
    }
    
    Quit $$$OK
}

/// Method: RemoveToolSet
/// Description: Remove a toolset from this agent
Method RemoveToolSet(pToolSetName As %String) As %Status
{
    // Find and delete AgentToolSet relationship
    Set toolSet = ##class(AIHubStudio.Metadata.ToolSet).GetByName(pToolSetName)
    If '$ISOBJECT(toolSet) Quit $$$OK
    Set agentToolSet = ..FindAgentToolSet(toolSet.%Id())
    If $ISOBJECT(agentToolSet) {
        Set sc = agentToolSet.%Delete()
        If $$$ISERR(sc) {
            Return sc
        }
    }
    
    Quit $$$OK
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
    
    // Add toolset names
    Set toolSetNames = ..GetToolSetNames()
    Set toolSetsArray = []
    For i = 0:1:(toolSetNames.%Size() - 1) {
        Do toolSetsArray.%Push(toolSetNames.%Get(i))
    }
    Set obj.toolSets = toolSetsArray
    
    Quit obj.%ToJSON()
}

/// Method: Show
/// Description: Display agent information
Method Show() As %Status
{
    Write !, "Agent: ", ..Name
    Write !, "Description: ", ..Description
    Write !, "Provider: ", ..Provider
    Write !, "Model: ", ..Model
    Write !, "Enabled: ", ..Enabled
    Write !, "Created: ", ..CreatedAt
    Write !, "Updated: ", ..UpdatedAt
    
    If ..Instructions '= "" {
        Write !, !, "Instructions:"
        Write !, ..Instructions
    }
    
    // Show tools
    Set toolNames = ..GetToolNames()
    If toolNames.%Size() > 0 {
        Write !, !, "Tools:"
        For i = 0:1:(toolNames.%Size() - 1) {
            Write !, "  - ", toolNames.%Get(i)
        }
    }
    
    // Show toolsets
    Set toolSetNames = ..GetToolSetNames()
    If toolSetNames.%Size() > 0 {
        Write !, !, "ToolSets:"
        For i = 0:1:(toolSetNames.%Size() - 1) {
            Write !, "  - ", toolSetNames.%Get(i)
        }
    }
    
    Quit $$$OK
}

/// ClassMethod: GetByName
/// Description: Get agent by name
ClassMethod GetByName(pName As %String) As AIHubStudio.Metadata.Agent
{
    Set agent = $$$NULLOREF
    Try {
        Set agent = ##class(AIHubStudio.Metadata.Agent).NameIndexOpen(pName)
    } Catch ex {
        Set agent = $$$NULLOREF
    }
    Quit agent
}

/// ClassMethod: ListAll
/// Description: List all agents as JSON array
ClassMethod ListAll() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, Provider, Model, Enabled, CreatedAt FROM AIHubStudio_Metadata.Agent ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "provider": (result.Provider),
            "model": (result.Model),
            "enabled": (result.Enabled),
            "createdAt": (result.CreatedAt)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: ListEnabled
/// Description: List all enabled agents
ClassMethod ListEnabled() As %String
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set status = stmt.%Prepare("SELECT Name, Description, Provider, Model FROM AIHubStudio_Metadata.Agent WHERE Enabled = 1 ORDER BY Name")
    If $$$ISERR(status) {
        Quit "[]"
    }
    
    Set result = stmt.%Execute()
    Set jsonArray = []
    
    While result.%Next() {
        Set obj = {
            "name": (result.Name),
            "description": (result.Description),
            "provider": (result.Provider),
            "model": (result.Model)
        }
        Do jsonArray.%Push(obj)
    }
    
    Quit jsonArray.%ToJSON()
}

/// ClassMethod: Exists
/// Description: Check if an agent exists
ClassMethod Exists(pName As %String) As %Boolean
{
    Set agent = ..GetByName(pName)
    Quit $ISOBJECT(agent)
}

Storage Default
{
<Data name="AgentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Package</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>Provider</Value>
</Value>
<Value name="6">
<Value>Model</Value>
</Value>
<Value name="7">
<Value>Instructions</Value>
</Value>
<Value name="8">
<Value>Temperature</Value>
</Value>
<Value name="9">
<Value>MaxTokens</Value>
</Value>
<Value name="10">
<Value>Enabled</Value>
</Value>
<Value name="11">
<Value>CreatedAt</Value>
</Value>
<Value name="12">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Metadata.AgentD</DataLocation>
<DefaultData>AgentDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Metadata.AgentD</IdLocation>
<IndexLocation>^AIHubStudio.Metadata.AgentI</IndexLocation>
<StreamLocation>^AIHubStudio.Metadata.AgentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
