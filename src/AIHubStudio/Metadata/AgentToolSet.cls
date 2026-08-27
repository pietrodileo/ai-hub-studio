/// Class: AIHubStudio.Metadata.AgentToolSet
/// Description: Relationship between Agent and ToolSet (many-to-many)
/// Author: IRIS AI Hub Studio Team
/// Version: 1.0.0

Class AIHubStudio.Metadata.AgentToolSet Extends %Persistent
{

/// Property: Agent
/// Description: Reference to the Agent
Property Agent As AIHubStudio.Metadata.Agent;

/// Property: ToolSet
/// Description: Reference to the ToolSet
Property ToolSet As AIHubStudio.Metadata.ToolSet;

/// Index: AgentIndex
/// Description: Index on Agent
Index AgentIndex On Agent;

/// Index: ToolSetIndex
/// Description: Index on ToolSet
Index ToolSetIndex On ToolSet;

/// Index: PrimaryKey
/// Description: Unique index on Agent and ToolSet
Index PrimaryKey On (Agent, ToolSet) [ Unique, PrimaryKey ];

/// Method: OnBeforeSave
/// Description: Validate before saving
Method %OnBeforeSave(insert As %Boolean) As %Status
{
    If '$ISOBJECT(..Agent) {
        Return $$$ERROR($$$GeneralError, "Agent is required")
    }
    If '$ISOBJECT(..ToolSet) {
        Return $$$ERROR($$$GeneralError, "ToolSet is required")
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

/// Method: GetToolSet
/// Description: Get the ToolSet object
Method GetToolSet() As AIHubStudio.Metadata.ToolSet
{
    If '$ISOBJECT(..ToolSet) {
        Quit $$$NULLOREF
    }
    Quit ..ToolSet
}

Storage Default
{
<Data name="AgentToolSetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Agent</Value>
</Value>
<Value name="3">
<Value>ToolSet</Value>
</Value>
</Data>
<DataLocation>^AIHubStudio.M6D8D.AgentToolSetD</DataLocation>
<DefaultData>AgentToolSetDefaultData</DefaultData>
<IdLocation>^AIHubStudio.M6D8D.AgentToolSetD</IdLocation>
<IndexLocation>^AIHubStudio.M6D8D.AgentToolSetI</IndexLocation>
<StreamLocation>^AIHubStudio.M6D8D.AgentToolSetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
