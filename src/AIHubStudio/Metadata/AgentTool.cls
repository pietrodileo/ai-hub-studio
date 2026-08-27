/// Class: AIHubStudio.Metadata.AgentTool
/// Description: Relationship between Agent and Tool (many-to-many)
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.AgentTool Extends %Persistent
{

/// Property: Agent
/// Description: Reference to the Agent
Property Agent As AIHubStudio.Metadata.Agent;

/// Property: Tool
/// Description: Reference to the Tool
Property Tool As AIHubStudio.Metadata.Tool;

/// Index: AgentIndex
/// Description: Index on Agent
Index AgentIndex On Agent;

/// Index: ToolIndex
/// Description: Index on Tool
Index ToolIndex On Tool;

/// Index: PrimaryKey
/// Description: Unique index on Agent and Tool
Index PrimaryKey On (Agent, Tool) [ Unique, PrimaryKey ];

/// Method: OnBeforeSave
/// Description: Validate before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    If '$ISOBJECT(..Agent) {
        Return $$$ERROR($$$GeneralError, "Agent is required")
    }
    If '$ISOBJECT(..Tool) {
        Return $$$ERROR($$$GeneralError, "Tool is required")
    }
    Quit $$$OK
}

/// Method: GetAgent
/// Description: Get the Agent object
Method GetAgent() As AIHubStudio.Metadata.Agent
{
    If '$ISOBJECT(..Agent) {
        Quit $$$NULLOREF
    }
    Quit ..Agent
}

/// Method: GetTool
/// Description: Get the Tool object
Method GetTool() As AIHubStudio.Metadata.Tool
{
    If '$ISOBJECT(..Tool) {
        Quit $$$NULLOREF
    }
    Quit ..Tool
}

Storage Default
{
<Data name="AgentToolDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Agent</Value>
</Value>
<Value name="3">
<Value>Tool</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.Meta6D8D.AgentToolD</DataLocation>
<DefaultData>AgentToolDefaultData</DefaultData>
<IdLocation>^AIHubStudio.Meta6D8D.AgentToolD</IdLocation>
<IndexLocation>^AIHubStudio.Meta6D8D.AgentToolI</IndexLocation>
<StreamLocation>^AIHubStudio.Meta6D8D.AgentToolS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
